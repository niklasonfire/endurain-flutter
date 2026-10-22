import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/updates/update_installer.dart';

enum UpdateChannel { stable, nightly }

/// Distribution policy for this fork, separate from the update implementation.
const updateRepository = 'niklasonfire/endurain-flutter';

class UpdateRelease {
  const UpdateRelease({
    required this.channel,
    required this.versionName,
    required this.versionCode,
    required this.applicationId,
    required this.builtAt,
    required this.notes,
    required this.assetName,
    required this.size,
    required this.sha256,
    required this.downloadUri,
  });

  final UpdateChannel channel;
  final String versionName;
  final int versionCode;
  final String applicationId;
  final DateTime builtAt;
  final String notes;
  final String assetName;
  final int size;
  final String sha256;
  final Uri downloadUri;

  /// Validates both documents together so a rolling release cannot mix builds.
  static UpdateRelease parse(
    Map<String, dynamic> release,
    Map<String, dynamic> manifest,
    UpdateChannel channel,
    InstalledUpdateInfo installed,
  ) {
    Never invalid() => throw const AppException(AppErrorCode.updateInvalid);
    final tag = release['tag_name'];
    if (release['draft'] != false ||
        release['prerelease'] != (channel == UpdateChannel.nightly) ||
        manifest['schemaVersion'] != 1 ||
        manifest['channel'] != channel.name ||
        manifest['applicationId'] != installed.applicationId ||
        manifest['versionName'] is! String ||
        (manifest['versionName'] as String).isEmpty ||
        manifest['versionCode'] is! int ||
        manifest['minSdk'] is! int ||
        manifest['commit'] is! String ||
        !RegExp(r'^[0-9a-f]{40}$').hasMatch(manifest['commit'] as String)) {
      invalid();
    }
    final code = manifest['versionCode'] as int;
    if (code < 1 ||
        code > 2100000000 ||
        (channel == UpdateChannel.nightly
            ? tag != 'nightly'
            : tag != 'v${manifest['versionName']}+$code')) {
      invalid();
    }
    final date = DateTime.tryParse(manifest['builtAt']?.toString() ?? '');
    if (date == null || !date.isUtc || (manifest['minSdk'] as int) < 1) {
      invalid();
    }
    if ((manifest['minSdk'] as int) > installed.sdkInt) {
      throw const AppException(AppErrorCode.updateIncompatible);
    }
    final entries = manifest['assets'];
    final releaseAssets = release['assets'];
    if (entries is! List || entries.isEmpty || releaseAssets is! List) {
      invalid();
    }
    final names = <String>{};
    Map<String, dynamic>? selected;
    for (final entry in entries) {
      if (entry is! Map<String, dynamic> ||
          entry['abi'] is! String ||
          entry['name'] is! String ||
          !RegExp(r'^[A-Za-z0-9._-]+\.apk$')
              .hasMatch(entry['name'] as String) ||
          !names.add(entry['name'] as String) ||
          entry['size'] is! int ||
          (entry['size'] as int) <= 0 ||
          entry['sha256'] is! String ||
          !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(entry['sha256'] as String)) {
        invalid();
      }
    }
    for (final abi in installed.supportedAbis) {
      final matches = entries.where((entry) => entry['abi'] == abi).toList();
      if (matches.length > 1) invalid();
      if (matches.isNotEmpty) {
        selected = matches.single as Map<String, dynamic>;
        break;
      }
    }
    if (selected == null) {
      throw const AppException(AppErrorCode.updateIncompatible);
    }
    final matches = releaseAssets
        .where((entry) => entry is Map && entry['name'] == selected!['name'])
        .toList();
    if (matches.length != 1 || matches.single['size'] != selected['size']) {
      invalid();
    }
    final uri = Uri.tryParse(
      matches.single['browser_download_url']?.toString() ?? '',
    );
    if (uri == null ||
        !isRepositoryDownload(uri) ||
        uri.pathSegments.last != selected['name'] ||
        uri.pathSegments[4] != tag) {
      invalid();
    }
    return UpdateRelease(
      channel: channel,
      versionName: manifest['versionName'] as String,
      versionCode: code,
      applicationId: manifest['applicationId'] as String,
      builtAt: date,
      notes: release['body'] is String ? release['body'] as String : '',
      assetName: selected['name'] as String,
      size: selected['size'] as int,
      sha256: (selected['sha256'] as String).toLowerCase(),
      downloadUri: uri,
    );
  }
}

bool isRepositoryDownload(Uri uri) =>
    uri.scheme == 'https' &&
    uri.host == 'github.com' &&
    !uri.hasPort &&
    uri.userInfo.isEmpty &&
    uri.path.startsWith('/$updateRepository/releases/download/') &&
    uri.pathSegments.length == 6;

bool isUpdateRedirect(Uri uri) =>
    isRepositoryDownload(uri) ||
    (uri.scheme == 'https' &&
        !uri.hasPort &&
        uri.userInfo.isEmpty &&
        (uri.host == 'release-assets.githubusercontent.com' ||
            uri.host == 'objects.githubusercontent.com'));
