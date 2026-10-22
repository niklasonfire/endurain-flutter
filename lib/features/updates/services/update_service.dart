import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/updates/models/downloaded_update.dart';
import 'package:endurain/features/updates/models/installed_update_info.dart';
import 'package:endurain/features/updates/models/update_release.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Owns unauthenticated GitHub requests and verified update cache files.
/// This intentionally bypasses the authenticated Endurain ApiClient: backend
/// session credentials must never be sent to the public distribution host.
/// Each route gets one instance so cancellation never closes another route's
/// requests. A completed download returns an immutable, uniquely named APK.
class UpdateService {
  UpdateService({
    required this.repository,
    http.Client Function()? clientFactory,
    Future<Directory> Function()? cacheDirectory,
  }) : _clientFactory = clientFactory ?? http.Client.new,
       _cacheDirectory = cacheDirectory ?? getTemporaryDirectory;

  static const requestTimeout = Duration(seconds: 30);
  static const cacheRetention = Duration(hours: 24);
  static const maxMetadataBytes = 2 * 1024 * 1024;
  static const maxRedirects = 6;
  final String repository;
  final http.Client Function() _clientFactory;
  final Future<Directory> Function() _cacheDirectory;
  http.Client? _activeClient;
  int _generation = 0;
  static int _cacheSequence = 0;
  bool _current(int generation) => generation == _generation;

  Future<void> cleanStaleCache() async {
    final directory = Directory('${(await _cacheDirectory()).path}/updates');
    if (directory.existsSync()) {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File &&
            DateTime.now().difference(entity.lastModifiedSync()) >
                cacheRetention) {
          await entity.delete();
        }
      }
    }
  }

  Future<UpdateRelease?> check(
    UpdateChannel channel,
    InstalledUpdateInfo installed,
  ) async {
    final generation = _generation;
    final client = _clientFactory();
    _activeClient = client;
    try {
      final endpoint = channel == UpdateChannel.stable
          ? 'latest'
          : 'tags/nightly';
      final document = await _json(
        client,
        Uri.parse(
          'https://api.github.com/repos/$repository/releases/$endpoint',
        ),
      );
      if (!_current(generation)) return null;
      final assets = document['assets'];
      if (assets is! List) throw const AppException(AppErrorCode.updateInvalid);
      final manifests = assets
          .where((asset) => asset is Map && asset['name'] == 'update.json')
          .toList();
      if (manifests.length != 1) {
        throw const AppException(AppErrorCode.updateUnavailable);
      }
      final uri = Uri.tryParse(
        manifests.single['browser_download_url']?.toString() ?? '',
      );
      if (uri == null ||
          !isRepositoryDownload(uri, repository) ||
          uri.pathSegments[4] != document['tag_name'] ||
          uri.pathSegments.last != 'update.json') {
        throw const AppException(AppErrorCode.updateInvalid);
      }
      final manifest = await _json(client, uri);
      if (!_current(generation)) return null;
      final candidate = UpdateRelease.parse(
        document,
        manifest,
        channel,
        installed,
        repository: repository,
      );
      if (!_current(generation)) return null;
      return candidate;
    } finally {
      client.close();
      if (identical(_activeClient, client)) _activeClient = null;
    }
  }

  Future<DownloadedUpdate?> download(
    UpdateRelease candidate, {
    required void Function(int) onProgress,
  }) async {
    final generation = _generation;
    final client = _clientFactory();
    _activeClient = client;
    File? partial;
    IOSink? sink;
    var receivedBytes = 0;
    try {
      final dir = await Directory('${(await _cacheDirectory()).path}/updates')
          .create(recursive: true);
      if (!_current(generation)) return null;
      final downloadId =
          '${DateTime.now().microsecondsSinceEpoch}-${_cacheSequence++}-${candidate.versionCode}';
      partial = File('${dir.path}/$downloadId.part');
      sink = partial.openWrite();
      final response = await _get(client, candidate.downloadUri);
      if (response.contentLength != null &&
          response.contentLength != candidate.size) {
        throw const AppException(AppErrorCode.updateIntegrity);
      }
      await for (final bytes in response.stream.timeout(requestTimeout)) {
        if (!_current(generation)) return null;
        receivedBytes += bytes.length;
        if (receivedBytes > candidate.size) {
          throw const AppException(AppErrorCode.updateIntegrity);
        }
        sink.add(bytes);
        // Flush each network chunk to keep disk backpressure and storage errors
        // attached to this operation instead of an unobserved IOSink future.
        await sink.flush();
        onProgress(receivedBytes);
      }
      await sink.close();
      sink = null;
      if (!_current(generation)) return null;
      if (receivedBytes != candidate.size ||
          (await sha256.bind(partial.openRead()).first).toString() !=
              candidate.sha256) {
        throw const AppException(AppErrorCode.updateIntegrity);
      }
      if (!_current(generation)) return null;
      final verified = await partial.rename(
        '${partial.path.substring(0, partial.path.length - 5)}.apk',
      );
      if (!_current(generation)) {
        await verified.delete();
        return null;
      }
      return DownloadedUpdate(path: verified.path);
    } catch (cause) {
      if (cause is AppException) rethrow;
      throw AppException(
        cause is FileSystemException
            ? AppErrorCode.updateStorage
            : AppErrorCode.updateNetwork,
        cause: cause,
      );
    } finally {
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {
          /* Original error is reported above. */
        }
      }
      if (partial != null && partial.existsSync()) {
        try {
          await partial.delete();
        } catch (_) {
          /* Retried on the next load. */
        }
      }
      client.close();
      if (identical(_activeClient, client)) _activeClient = null;
    }
  }

  void cancel() {
    _generation++;
    _activeClient?.close();
    _activeClient = null;
  }

  Future<void> discard(DownloadedUpdate download) async {
    try {
      await File(download.path).delete();
    } catch (_) {
      /* Stale files are cleaned on next load. */
    }
  }

  Future<Map<String, dynamic>> _json(http.Client client, Uri uri) async {
    final response = await _get(client, uri);
    final bytes = <int>[];
    await for (final chunk in response.stream.timeout(requestTimeout)) {
      bytes.addAll(chunk);
      if (bytes.length > maxMetadataBytes) {
        throw const AppException(AppErrorCode.updateInvalid);
      }
    }
    try {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is! Map<String, dynamic>) throw const FormatException();
      return value;
    } on FormatException catch (cause) {
      throw AppException(AppErrorCode.updateInvalid, cause: cause);
    }
  }

  Future<http.StreamedResponse> _get(http.Client client, Uri uri) async {
    for (var redirects = 0; redirects < maxRedirects; redirects++) {
      final request = http.Request('GET', uri)..followRedirects = false;
      request.headers['Accept'] = uri.host == 'api.github.com'
          ? 'application/vnd.github+json'
          : 'application/octet-stream';
      request.headers['User-Agent'] = 'Endurain-Updater';
      final response = await client.send(request).timeout(requestTimeout);
      if ({301, 302, 303, 307, 308}.contains(response.statusCode)) {
        final target = uri.resolve(response.headers['location'] ?? '');
        if (!isUpdateRedirect(target, repository)) {
          throw const AppException(AppErrorCode.updateInvalid);
        }
        await response.stream.drain<void>().timeout(requestTimeout);
        uri = target;
        continue;
      }
      if (response.statusCode != 200) {
        throw AppException(
          response.statusCode == 404
              ? AppErrorCode.updateUnavailable
              : response.statusCode == 403 || response.statusCode == 429
              ? AppErrorCode.updateRateLimited
              : AppErrorCode.updateNetwork,
          statusCode: response.statusCode,
        );
      }
      return response;
    }
    throw const AppException(AppErrorCode.updateNetwork);
  }

  void dispose() => cancel();
}
