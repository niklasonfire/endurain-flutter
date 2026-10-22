import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/services/app_preferences_store.dart';
import 'package:endurain/features/updates/update_installer.dart';
import 'package:endurain/features/updates/update_release.dart';
import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum UpdateStatus {
  loading,
  idle,
  checking,
  available,
  current,
  waitingStable,
  downloading,
  ready,
  permissionRequired,
  installerOpened,
  failed,
}

/// Route-owned update module. All requests use isolated unauthenticated clients.
/// A selected release binds one immutable APK name, size, code and digest.
class UpdateController extends SafeNotifier {
  UpdateController({
    required AppPreferencesStore preferences,
    required UpdateInstaller installer,
    required bool Function() recordingActive,
    Listenable? recordingChanges,
    http.Client Function()? clientFactory,
    Future<Directory> Function()? cacheDirectory,
  }) : _preferences = preferences,
       _installer = installer,
       _recordingActive = recordingActive,
       _clientFactory = clientFactory ?? http.Client.new,
       _cacheDirectory = cacheDirectory ?? getTemporaryDirectory,
       _recordingChanges = recordingChanges {
    _recordingChanges?.addListener(notify);
  }

  final AppPreferencesStore _preferences;
  final UpdateInstaller _installer;
  final Listenable? _recordingChanges;
  Future<void> _channelWrite = Future.value();
  final bool Function() _recordingActive;
  final http.Client Function() _clientFactory;
  final Future<Directory> Function() _cacheDirectory;
  static const _channelKey = 'updates.channel';
  static const _checkedKey = 'updates.lastChecked';
  UpdateChannel _channel = UpdateChannel.stable;
  UpdateStatus _status = UpdateStatus.loading;
  InstalledUpdateInfo? _installed;
  UpdateRelease? _release;
  AppException? _error;
  DateTime? _lastChecked;
  int _receivedBytes = 0;
  File? _downloaded;
  String? _handedOffPath;
  static int _cacheSequence = 0;
  http.Client? _activeClient;
  int _generation = 0;
  bool _installing = false;
  UpdateChannel get channel => _channel;
  UpdateStatus get status => _status;
  InstalledUpdateInfo? get installed => _installed;
  UpdateRelease? get release => _release;
  AppException? get error => _error;
  DateTime? get lastChecked => _lastChecked;
  int get receivedBytes => _receivedBytes;
  bool get installationBlocked => _recordingActive();
  double? get progress =>
      _release == null ? null : _receivedBytes / _release!.size;

  Future<void> load() async {
    try {
      final saved = await _preferences.read(key: _channelKey);
      _channel = saved == 'nightly'
          ? UpdateChannel.nightly
          : UpdateChannel.stable;
      _lastChecked = DateTime.tryParse(
        await _preferences.read(key: _checkedKey) ?? '',
      );
      _installed = await _installer.installedInfo();
      final directory = Directory('${(await _cacheDirectory()).path}/updates');
      if (directory.existsSync()) {
        await for (final entity in directory.list(followLinks: false)) {
          if (entity is File &&
              DateTime.now().difference(entity.lastModifiedSync()) >
                  const Duration(hours: 24)) {
            await entity.delete();
          }
        }
      }
      _status = UpdateStatus.idle;
    } catch (cause) {
      _fail(cause, AppErrorCode.updateStorage);
    }
    notify();
  }

  Future<void> selectChannel(UpdateChannel value) async {
    if (_installing || value == _channel || _status == UpdateStatus.loading) {
      return;
    }
    cancel();
    _channel = value;
    _release = null;
    _error = null;
    _status = UpdateStatus.idle;
    notify();
    try {
      _channelWrite = _channelWrite
          .catchError((Object _) {})
          .then((_) => _preferences.write(key: _channelKey, value: value.name));
      await _channelWrite;
    } catch (cause) {
      if (_channel == value) {
        _fail(cause, AppErrorCode.updateStorage);
        notify();
      }
    }
  }

  Future<void> check() async {
    if (_installing || _installed == null || !_installed!.supported) return;
    cancel();
    final generation = _generation;
    final selectedChannel = _channel;
    final client = _clientFactory();
    _activeClient = client;
    _release = null;
    _error = null;
    _status = UpdateStatus.checking;
    notify();
    try {
      final endpoint = selectedChannel == UpdateChannel.stable
          ? 'latest'
          : 'tags/nightly';
      final document = await _json(
        client,
        Uri.parse(
          'https://api.github.com/repos/$updateRepository/releases/$endpoint',
        ),
      );
      if (!_current(generation)) return;
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
          !isRepositoryDownload(uri) ||
          uri.pathSegments[4] != document['tag_name'] ||
          uri.pathSegments.last != 'update.json') {
        throw const AppException(AppErrorCode.updateInvalid);
      }
      final manifest = await _json(client, uri);
      if (!_current(generation)) return;
      final candidate = UpdateRelease.parse(
        document,
        manifest,
        selectedChannel,
        _installed!,
      );
      if (!_current(generation)) return;
      _release = candidate;
      final code = _installed!.versionCode;
      _status = candidate.versionCode > code
          ? UpdateStatus.available
          : candidate.versionCode < code &&
                selectedChannel == UpdateChannel.stable
          ? UpdateStatus.waitingStable
          : UpdateStatus.current;
      _lastChecked = DateTime.now().toUtc();
      try {
        await _preferences.write(
          key: _checkedKey,
          value: _lastChecked!.toIso8601String(),
        );
      } catch (cause) {
        throw AppException(AppErrorCode.updateStorage, cause: cause);
      }
    } catch (cause) {
      if (_current(generation)) _fail(cause, AppErrorCode.updateNetwork);
    } finally {
      client.close();
      if (_current(generation)) {
        _activeClient = null;
        notify();
      }
    }
  }

  Future<void> download() async {
    final candidate = _release;
    if (_installing ||
        candidate == null ||
        candidate.versionCode <= (_installed?.versionCode ?? 0) ||
        _status == UpdateStatus.downloading) {
      return;
    }
    cancel();
    final generation = _generation;
    final client = _clientFactory();
    _activeClient = client;
    _status = UpdateStatus.downloading;
    _receivedBytes = 0;
    _error = null;
    notify();
    File? partial;
    IOSink? sink;
    var missing = false;
    try {
      final dir = await Directory('${(await _cacheDirectory()).path}/updates')
          .create(recursive: true);
      if (!_current(generation)) return;
      final downloadId =
          '${DateTime.now().microsecondsSinceEpoch}-${_cacheSequence++}-${candidate.versionCode}';
      partial = File('${dir.path}/$downloadId.part');
      sink = partial.openWrite();
      final response = await _get(client, candidate.downloadUri);
      if (response.contentLength != null &&
          response.contentLength != candidate.size) {
        throw const AppException(AppErrorCode.updateIntegrity);
      }
      await for (final bytes in response.stream.timeout(
        const Duration(seconds: 30),
      )) {
        if (!_current(generation)) return;
        _receivedBytes += bytes.length;
        if (_receivedBytes > candidate.size) {
          throw const AppException(AppErrorCode.updateIntegrity);
        }
        sink.add(bytes);
        // Flush each network chunk to keep disk backpressure and storage errors
        // attached to this operation instead of an unobserved IOSink future.
        await sink.flush();
        notify();
      }
      await sink.close();
      sink = null;
      if (!_current(generation)) return;
      if (_receivedBytes != candidate.size ||
          (await sha256.bind(partial.openRead()).first).toString() !=
              candidate.sha256) {
        throw const AppException(AppErrorCode.updateIntegrity);
      }
      if (!_current(generation)) return;
      final verified = await partial.rename(
        '${partial.path.substring(0, partial.path.length - 5)}.apk',
      );
      if (!_current(generation)) {
        await verified.delete();
        return;
      }
      _downloaded = verified;
      _status = UpdateStatus.ready;
    } catch (cause) {
      if (_current(generation)) {
        missing = cause is AppException && cause.statusCode == 404;
        _fail(
          cause,
          cause is FileSystemException
              ? AppErrorCode.updateStorage
              : AppErrorCode.updateNetwork,
        );
      }
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
      if (_current(generation)) {
        _activeClient = null;
        notify();
      }
    }
    if (missing && _current(generation)) {
      // Rolling Nightly may remove an asset between check and download. Resolve
      // exactly once, then require a fresh user download for the new build.
      await check();
    }
  }

  void cancel() {
    _generation++;
    _activeClient?.close();
    _activeClient = null;
    final old = _downloaded;
    _downloaded = null;
    if (old != null && old.path != _handedOffPath) {
      unawaited(old.delete().catchError((_) => old));
    }
    if (_status == UpdateStatus.downloading) _status = UpdateStatus.available;
    notify();
  }

  Future<void> install() async {
    final candidate = _release;
    final file = _downloaded;
    if (_installing || candidate == null || file == null) return;
    _installing = true;
    _error = null;
    try {
      _ensureSafe();
      if (!await _installer.canInstall()) {
        _ensureSafe();
        _status = UpdateStatus.permissionRequired;
        notify();
        await _installer.requestInstallPermission();
        return;
      }
      _ensureSafe();
      _handedOffPath = file.path;
      await _installer.install(
        file.path,
        versionCode: candidate.versionCode,
        applicationId: candidate.applicationId,
        sha256: candidate.sha256,
      );
      _status = UpdateStatus.installerOpened;
    } catch (cause) {
      _fail(cause, AppErrorCode.updateInstallFailed);
    } finally {
      _installing = false;
      notify();
    }
  }

  /// Installer launch is not success. Re-read actual package state on resume;
  /// returning from source permissions only makes the Install action available.
  Future<void> onResume() async {
    final generation = _generation;
    try {
      final actual = await _installer.installedInfo();
      if (!_current(generation)) return;
      _installed = actual;
      if (_release != null &&
          _installed!.versionCode >= _release!.versionCode) {
        cancel();
        _status =
            _channel == UpdateChannel.stable &&
                _installed!.versionCode > _release!.versionCode
            ? UpdateStatus.waitingStable
            : UpdateStatus.current;
      } else if (_downloaded != null) {
        final allowed = await _installer.canInstall();
        if (!_current(generation)) return;
        _status = allowed
            ? UpdateStatus.ready
            : UpdateStatus.permissionRequired;
      }
    } catch (cause) {
      if (_current(generation)) _fail(cause, AppErrorCode.updateInstallFailed);
    }
    notify();
  }

  void _ensureSafe() {
    if (_recordingActive()) {
      throw const AppException(AppErrorCode.updateRecordingActive);
    }
    if (isDisposed) throw const AppException(AppErrorCode.updateInstallFailed);
  }

  bool _current(int generation) => !isDisposed && generation == _generation;

  void _fail(Object cause, AppErrorCode fallback) {
    _error = cause is AppException
        ? cause
        : AppException(
            cause is UpdateInstallerException &&
                    cause.code == 'recording_active'
                ? AppErrorCode.updateRecordingActive
                : fallback,
            cause: cause,
          );
    _status = UpdateStatus.failed;
  }

  Future<Map<String, dynamic>> _json(http.Client client, Uri uri) async {
    final response = await _get(client, uri);
    final bytes = <int>[];
    await for (final chunk in response.stream.timeout(
      const Duration(seconds: 30),
    )) {
      bytes.addAll(chunk);
      if (bytes.length > 2 * 1024 * 1024) {
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
    for (var redirects = 0; redirects < 6; redirects++) {
      final request = http.Request('GET', uri)..followRedirects = false;
      request.headers['Accept'] = uri.host == 'api.github.com'
          ? 'application/vnd.github+json'
          : 'application/octet-stream';
      request.headers['User-Agent'] = 'Endurain-Updater';
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
      if ({301, 302, 303, 307, 308}.contains(response.statusCode)) {
        final target = uri.resolve(response.headers['location'] ?? '');
        if (!isUpdateRedirect(target)) {
          throw const AppException(AppErrorCode.updateInvalid);
        }
        await response.stream.drain<void>().timeout(
          const Duration(seconds: 30),
        );
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

  @override
  void dispose() {
    // Android may still be reading the content URI after this route closes.
    _generation++;
    _activeClient?.close();
    _recordingChanges?.removeListener(notify);
    super.dispose();
  }
}
