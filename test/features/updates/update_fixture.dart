import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:endurain/core/services/app_preferences_store.dart';
import 'package:endurain/features/updates/controllers/update_controller.dart';
import 'package:endurain/features/updates/models/installed_update_info.dart';
import 'package:endurain/features/updates/repositories/update_settings_repository.dart';
import 'package:endurain/features/updates/services/update_installer.dart';
import 'package:endurain/features/updates/services/update_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class UpdateFixture {
  UpdateFixture()
    : cache = Directory.systemTemp.createTempSync('endurain-update-test');
  final Directory cache;
  final AppPreferencesStore preferences = _MemoryPreferences();
  final installer = FakeUpdateInstaller();
  final recordingChanges = ChangeNotifier();
  bool recording = false;
  int code = 100042;
  String channel = 'stable';
  int? responseStatus;
  int? apkStatus;
  List<int> apk = utf8.encode('known test APK bytes');
  String? digestOverride;
  Future<http.Response> Function(http.Request)? respond;
  final requested = <Uri>[];
  Map<String, dynamic> Function(Map<String, dynamic>)? changeManifest;
  Map<String, dynamic> Function(Map<String, dynamic>)? changeRelease;

  String get assetName => 'endurain-local-$code-arm64-v8a.apk';
  String get tag => channel == 'nightly' ? 'nightly' : 'v1.2.3+$code';
  String url(String name) =>
      'https://github.com/niklasonfire/endurain-flutter/releases/download/${Uri.encodeComponent(tag)}/$name';

  Map<String, dynamic> manifest() {
    final result = <String, dynamic>{
      'schemaVersion': 1,
      'channel': channel,
      'versionName': '1.2.3',
      'versionCode': code,
      'commit': 'a' * 40,
      'builtAt': '2026-10-22T12:00:00Z',
      'applicationId': 'com.endurain.endurain.local',
      'minSdk': 26,
      'assets': [
        <String, dynamic>{
          'abi': 'arm64-v8a',
          'name': assetName,
          'size': apk.length,
          'sha256': digestOverride ?? sha256.convert(apk).toString(),
        },
      ],
    };
    return changeManifest?.call(result) ?? result;
  }

  Map<String, dynamic> release() {
    final result = <String, dynamic>{
      'draft': false,
      'prerelease': channel == 'nightly',
      'tag_name': tag,
      'body': 'Release notes for this build',
      'assets': [
        {
          'name': 'update.json',
          'size': 500,
          'browser_download_url': url('update.json'),
        },
        {
          'name': assetName,
          'size': apk.length,
          'browser_download_url': url(assetName),
        },
      ],
    };
    return changeRelease?.call(result) ?? result;
  }

  Future<http.Response> response(http.Request request) async {
    requested.add(request.url);
    if (respond != null) return respond!(request);
    if (responseStatus != null) return http.Response('', responseStatus!);
    if (request.url.host == 'api.github.com') {
      return http.Response(jsonEncode(release()), 200);
    }
    if (request.url.path.endsWith('/update.json')) {
      return http.Response(jsonEncode(manifest()), 200);
    }
    return http.Response.bytes(apk, apkStatus ?? 200);
  }

  UpdateController controller({http.Client Function()? clients}) =>
      UpdateController(
        settings: UpdateSettingsRepository(preferences: preferences),
        updates: UpdateService(
          repository: 'niklasonfire/endurain-flutter',
          clientFactory: clients ?? () => MockClient(response),
          cacheDirectory: () async => cache,
        ),
        installer: installer,
        recordingActive: () => recording,
        recordingChanges: recordingChanges,
      );

  void dispose() {
    recordingChanges.dispose();
    if (cache.existsSync()) cache.deleteSync(recursive: true);
  }
}

class FakeUpdateInstaller implements UpdateInstaller {
  int code = 100000;
  bool allowed = true;
  bool supported = true;
  int sdk = 37;
  List<String> abis = ['arm64-v8a'];
  int permissionRequests = 0;
  String? openedPath;
  String? openedDigest;
  Object? installError;
  Future<bool> Function()? permission;

  @override
  Future<InstalledUpdateInfo> installedInfo() async => InstalledUpdateInfo(
    applicationId: 'com.endurain.endurain.local',
    versionName: '1.0.0',
    versionCode: code,
    supportedAbis: abis,
    sdkInt: sdk,
    supported: supported,
  );
  @override
  Future<bool> canInstall() async =>
      permission == null ? allowed : permission!();
  @override
  Future<void> requestInstallPermission() async {
    permissionRequests++;
  }

  @override
  Future<void> install(
    String path, {
    required int versionCode,
    required String applicationId,
    required String sha256,
  }) async {
    if (installError != null) throw installError!;
    openedPath = path;
    openedDigest = sha256;
  }
}

class _MemoryPreferences extends AppPreferencesStore {
  final values = <String, String>{};
  @override
  Future<String?> read({required String key}) async => values[key];
  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}
