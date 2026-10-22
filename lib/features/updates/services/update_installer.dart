import 'package:endurain/features/updates/models/installed_update_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UpdateInstallerException implements Exception {
  const UpdateInstallerException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

abstract class UpdateInstaller {
  Future<InstalledUpdateInfo> installedInfo();
  Future<bool> canInstall();
  Future<void> requestInstallPermission();
  Future<void> install(
    String apkPath, {
    required int versionCode,
    required String applicationId,
    required String sha256,
  });
}

/// Opens Android's confirmation UI only after validating the downloaded APK.
class AndroidUpdateInstaller implements UpdateInstaller {
  const AndroidUpdateInstaller({
    MethodChannel channel = const MethodChannel('endurain/updates'),
  }) : _channel = channel;

  final MethodChannel _channel;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<T?> _invoke<T>(String method, [Map<String, Object>? arguments]) async {
    if (!_supported) {
      throw const UpdateInstallerException(
        'unsupported',
        'APK updates are available on Android only.',
      );
    }
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error) {
      throw UpdateInstallerException(error.code, error.message ?? error.code);
    } on MissingPluginException {
      throw const UpdateInstallerException(
        'unsupported',
        'The Android update installer is unavailable.',
      );
    }
  }

  @override
  Future<InstalledUpdateInfo> installedInfo() async {
    if (!_supported) {
      return const InstalledUpdateInfo(
        applicationId: '',
        versionName: '',
        versionCode: 0,
        supportedAbis: [],
        sdkInt: 0,
        supported: false,
      );
    }
    final value = await _invoke<Map<Object?, Object?>>('installedInfo');
    return InstalledUpdateInfo(
      applicationId: value!['applicationId']! as String,
      versionName: value['versionName']! as String,
      versionCode: value['versionCode']! as int,
      supportedAbis: (value['supportedAbis']! as List).cast<String>(),
      sdkInt: value['sdkInt']! as int,
      supported: value['supported']! as bool,
    );
  }

  @override
  Future<bool> canInstall() async => await _invoke<bool>('canInstall') ?? false;

  @override
  Future<void> requestInstallPermission() =>
      _invoke<void>('requestInstallPermission');

  @override
  Future<void> install(
    String apkPath, {
    required int versionCode,
    required String applicationId,
    required String sha256,
  }) => _invoke<void>('install', {
    'apkPath': apkPath,
    'versionCode': versionCode,
    'applicationId': applicationId,
    'sha256': sha256,
  });
}
