import 'package:endurain/features/updates/update_installer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('endurain/updates');
  const installer = AndroidUpdateInstaller();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('reads actual installed version and device compatibility', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'installedInfo');
      return {
        'applicationId': 'com.endurain.endurain.local',
        'versionName': '0.12.0',
        'versionCode': 100042,
        'supportedAbis': ['arm64-v8a', 'armeabi-v7a'],
        'sdkInt': 35,
        'supported': true,
      };
    });
    final info = await installer.installedInfo();
    expect(info.applicationId, 'com.endurain.endurain.local');
    expect(info.versionName, '0.12.0');
    expect(info.versionCode, 100042);
    expect(info.supportedAbis, ['arm64-v8a', 'armeabi-v7a']);
    expect(info.sdkInt, 35);
    expect(info.supported, isTrue);
  });

  test(
    'checks permission again after returning from system settings',
    () async {
      var allowed = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'requestInstallPermission') {
          allowed = true;
          return null;
        }
        expect(call.method, 'canInstall');
        return allowed;
      });
      expect(await installer.canInstall(), isFalse);
      await installer.requestInstallPermission();
      expect(await installer.canInstall(), isTrue);
    },
  );

  test('passes bound metadata and checksum for native validation', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'install');
      expect(call.arguments, {
        'apkPath': '/cache/updates/update.apk',
        'versionCode': 100043,
        'applicationId': 'com.endurain.endurain.local',
        'sha256': 'verified checksum',
      });
      return null;
    });
    await installer.install(
      '/cache/updates/update.apk',
      versionCode: 100043,
      applicationId: 'com.endurain.endurain.local',
      sha256: 'verified checksum',
    );
  });

  test('preserves typed Android errors for the update controller', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(
        code: 'signature_mismatch',
        message: 'Signing identity changed.',
      );
    });
    await expectLater(
      installer.install(
        '/cache/updates/update.apk',
        versionCode: 100043,
        applicationId: 'com.endurain.endurain.local',
        sha256: 'checksum',
      ),
      throwsA(
        isA<UpdateInstallerException>()
            .having((error) => error.code, 'code', 'signature_mismatch')
            .having(
              (error) => error.toString(),
              'message',
              'Signing identity changed.',
            ),
      ),
    );
  });

  test('reports missing native installer as unsupported', () async {
    await expectLater(
      installer.canInstall(),
      throwsA(
        isA<UpdateInstallerException>().having(
          (error) => error.code,
          'code',
          'unsupported',
        ),
      ),
    );
  });

  test('does not call Android APIs on other platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(channel, (call) async {
      fail('Android installer was called on iOS');
    });
    expect((await installer.installedInfo()).supported, isFalse);
    await expectLater(
      installer.requestInstallPermission(),
      throwsA(isA<UpdateInstallerException>()),
    );
  });
}
