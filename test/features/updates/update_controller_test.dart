import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/updates/controllers/update_controller.dart';
import 'package:endurain/features/updates/models/update_release.dart';
import 'package:endurain/features/updates/models/update_status.dart';
import 'package:endurain/features/updates/services/update_installer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'update_fixture.dart';

void main() {
  late UpdateFixture fixture;
  late UpdateController controller;
  setUp(() {
    fixture = UpdateFixture();
    controller = fixture.controller();
  });
  tearDown(() async {
    controller.dispose();
    await Future<void>.delayed(Duration.zero);
    fixture.dispose();
  });

  Future<void> checked() async {
    await controller.load();
    await controller.check();
  }

  Future<void> downloaded() async {
    await checked();
    await controller.download();
  }

  test(
    'manual stable check offers a higher global code and saves check time',
    () async {
      await controller.load();
      expect(fixture.requested, isEmpty);
      await controller.check();
      expect(controller.status, UpdateStatus.available);
      expect(controller.release!.versionCode, 100042);
      expect(controller.release!.notes, 'Release notes for this build');
      expect(controller.lastChecked, isNotNull);
      expect(fixture.requested.first.path, endsWith('/releases/latest'));
      expect(
        await fixture.preferences.read(key: 'updates.lastChecked'),
        isNotNull,
      );
    },
  );

  test('switching channels is persisted and never starts a request', () async {
    await controller.load();
    await controller.selectChannel(UpdateChannel.nightly);
    expect(fixture.requested, isEmpty);
    final second = fixture.controller();
    addTearDown(second.dispose);
    await second.load();
    expect(second.channel, UpdateChannel.nightly);
    fixture.channel = 'nightly';
    await controller.check();
    expect(fixture.requested.first.path, endsWith('/releases/tags/nightly'));
    expect(controller.status, UpdateStatus.available);
  });

  for (final code in [100000, 99999]) {
    test('stable code $code does not offer a downgrade', () async {
      fixture.code = code;
      await checked();
      expect(
        controller.status,
        code == 100000 ? UpdateStatus.current : UpdateStatus.waitingStable,
      );
      await controller.download();
      expect(fixture.requested.length, 2);
    });
  }

  test(
    'returning to the app keeps the wait-for-newer-Stable explanation',
    () async {
      fixture.code = 99999;
      await checked();
      await controller.onResume();
      expect(controller.status, UpdateStatus.waitingStable);
    },
  );

  test(
    'successive builds under the same nightly tag use versionCode',
    () async {
      fixture.channel = 'nightly';
      await controller.load();
      await controller.selectChannel(UpdateChannel.nightly);
      await controller.check();
      fixture.code = 100043;
      await controller.check();
      expect(controller.release!.versionCode, 100043);
    },
  );

  for (final status in [404, 403, 429, 500]) {
    test('HTTP $status has a distinct failure rather than current', () async {
      fixture.responseStatus = status;
      await checked();
      expect(controller.status, UpdateStatus.failed);
      expect(
        controller.error!.code,
        status == 404
            ? AppErrorCode.updateUnavailable
            : status == 403 || status == 429
            ? AppErrorCode.updateRateLimited
            : AppErrorCode.updateNetwork,
      );
      expect(controller.lastChecked, isNull);
    });
  }

  test(
    'network timeout is retryable and does not silently change channel',
    () async {
      fixture.respond = (_) => Future.error(TimeoutException('offline'));
      await checked();
      expect(controller.error!.code, AppErrorCode.updateNetwork);
      expect(controller.channel, UpdateChannel.stable);
    },
  );

  for (final mutation in <String, void Function(Map<String, dynamic>)>{
    'schema': (m) => m['schemaVersion'] = 2,
    'channel': (m) => m['channel'] = 'nightly',
    'package': (m) => m['applicationId'] = 'other.app',
    'noninteger code': (m) => m['versionCode'] = '100042',
    'code overflow': (m) => m['versionCode'] = 2100000001,
    'commit': (m) => m['commit'] = 'truncated',
    'date': (m) => m['builtAt'] = 'not a date',
    'asset digest': (m) => (m['assets'] as List).single['sha256'] = 'bad',
    'asset traversal': (m) =>
        (m['assets'] as List).single['name'] = '../evil.apk',
    'duplicate asset': (m) =>
        (m['assets'] as List).add((m['assets'] as List).single),
  }.entries) {
    test('rejects invalid manifest ${mutation.key}', () async {
      fixture.changeManifest = (m) {
        mutation.value(m);
        return m;
      };
      await checked();
      expect(controller.error!.code, AppErrorCode.updateInvalid);
      expect(controller.release, isNull);
    });
  }

  for (final mutation in <String, void Function(Map<String, dynamic>)>{
    'prerelease': (m) => m['prerelease'] = true,
    'draft': (m) => m['draft'] = true,
    'wrong tag': (m) => m['tag_name'] = 'different',
    'missing APK': (m) => (m['assets'] as List).removeLast(),
    'wrong size': (m) => (m['assets'] as List).last['size'] = 999,
    'foreign APK host': (m) =>
        (m['assets'] as List).last['browser_download_url'] =
            'https://evil.example/file.apk',
  }.entries) {
    test('rejects release ${mutation.key}', () async {
      fixture.changeRelease = (m) {
        mutation.value(m);
        return m;
      };
      await checked();
      expect(controller.error!.code, AppErrorCode.updateInvalid);
    });
  }

  test('a missing manifest is unavailable, not up to date', () async {
    fixture.changeRelease = (m) {
      (m['assets'] as List).removeAt(0);
      return m;
    };
    await checked();
    expect(controller.error!.code, AppErrorCode.updateUnavailable);
  });

  for (final abi in [false, true]) {
    test(
      'refuses incompatible ${abi ? 'architecture' : 'Android version'}',
      () async {
        if (abi) {
          fixture.installer.abis = ['x86_64'];
        } else {
          fixture.installer.sdk = 25;
        }
        await checked();
        expect(controller.error!.code, AppErrorCode.updateIncompatible);
      },
    );
  }

  test(
    'late response after channel change cannot replace the selected channel',
    () async {
      final pending = Completer<http.Response>();
      fixture.respond = (_) => pending.future;
      await controller.load();
      final check = controller.check();
      await Future<void>.delayed(Duration.zero);
      await controller.selectChannel(UpdateChannel.nightly);
      pending.complete(http.Response(jsonEncode(fixture.release()), 200));
      await check;
      expect(controller.channel, UpdateChannel.nightly);
      expect(controller.status, UpdateStatus.idle);
      expect(controller.release, isNull);
    },
  );

  test(
    'GitHub asset redirects are supported without forwarding credentials',
    () async {
      fixture.respond = (request) async {
        expect(
          request.headers.keys.map((key) => key.toLowerCase()),
          isNot(contains('authorization')),
        );
        if (request.url.host == 'api.github.com') {
          return http.Response(jsonEncode(fixture.release()), 200);
        }
        if (request.url.host == 'github.com') {
          return http.Response(
            '',
            302,
            headers: {
              'location': 'https://release-assets.githubusercontent.com/test',
            },
          );
        }
        return http.Response(jsonEncode(fixture.manifest()), 200);
      };
      await checked();
      expect(controller.status, UpdateStatus.available);
    },
  );

  test('foreign or insecure redirects are refused', () async {
    fixture.respond = (_) async => http.Response(
      '',
      302,
      headers: {'location': 'http://evil.example/package'},
    );
    await checked();
    expect(controller.error!.code, AppErrorCode.updateInvalid);
  });

  test(
    'oversized metadata is refused before it can become a release',
    () async {
      fixture.respond = (_) async => http.Response('x' * (2097153), 200);
      await checked();
      expect(controller.error!.code, AppErrorCode.updateInvalid);
    },
  );

  test('an unresponsive connection times out and offers retry', () {
    fakeAsync((clock) {
      fixture.respond = (_) => Completer<http.Response>().future;
      unawaited(controller.load());
      clock.flushMicrotasks();
      unawaited(controller.check());
      clock.flushMicrotasks();
      expect(controller.status, UpdateStatus.checking);
      clock.elapse(const Duration(seconds: 31));
      clock.flushMicrotasks();
      expect(controller.error!.code, AppErrorCode.updateNetwork);
    });
  });

  test(
    'download verifies bytes then opens the installer without claiming success',
    () async {
      await downloaded();
      expect(controller.status, UpdateStatus.ready);
      expect(controller.progress, 1);
      await controller.install();
      expect(
        await File(fixture.installer.openedPath!).readAsBytes(),
        fixture.apk,
      );
      expect(fixture.installer.openedDigest, controller.release!.sha256);
      expect(controller.status, UpdateStatus.installerOpened);
      await controller.onResume();
      expect(controller.status, UpdateStatus.ready);
      fixture.installer.code = 100042;
      await controller.onResume();
      expect(controller.status, UpdateStatus.current);
    },
  );

  test(
    'corrupted download never becomes installable and removes partial data',
    () async {
      fixture.digestOverride = '0' * 64;
      await downloaded();
      expect(controller.error!.code, AppErrorCode.updateIntegrity);
      expect(Directory('${fixture.cache.path}/updates').listSync(), isEmpty);
      await controller.install();
      expect(fixture.installer.openedPath, isNull);
    },
  );

  test('truncated download is rejected before installation', () async {
    await checked();
    fixture.apk = [1, 2, 3];
    await controller.download();
    expect(controller.error!.code, AppErrorCode.updateIntegrity);
  });

  test(
    'removed rolling asset triggers one new check without mixed installation',
    () async {
      await checked();
      fixture.apkStatus = 404;
      fixture.code = 100043;
      await controller.download();
      expect(controller.status, UpdateStatus.available);
      expect(controller.release!.versionCode, 100043);
      expect(fixture.installer.openedPath, isNull);
    },
  );

  test('recording blocks install and source-permission round trip rechecks recording', () async {
    await downloaded();
    fixture.recording = true;
    await controller.install();
    expect(controller.error!.code, AppErrorCode.updateRecordingActive);
    expect(fixture.installer.openedPath, isNull);
    fixture.recording = false;
    fixture.installer.allowed = false;
    await controller.install();
    expect(controller.status, UpdateStatus.permissionRequired);
    expect(fixture.installer.permissionRequests, 1);
    fixture.installer.allowed = true;
    await controller.onResume();
    expect(controller.status, UpdateStatus.ready);
    fixture.recording = true;
    await controller.install();
    expect(fixture.installer.openedPath, isNull);
  });

  test(
    'recording starting during permission check is caught before installer',
    () async {
      await downloaded();
      fixture.installer.permission = () async {
        fixture.recording = true;
        return true;
      };
      await controller.install();
      expect(controller.error!.code, AppErrorCode.updateRecordingActive);
      expect(fixture.installer.openedPath, isNull);
    },
  );

  test(
    'native recording guard errors remain localized application errors',
    () async {
      await downloaded();
      fixture.installer.installError = const UpdateInstallerException(
        'recording_active',
        'native detail',
      );
      await controller.install();
      expect(controller.error!.code, AppErrorCode.updateRecordingActive);
    },
  );

  test(
    'reopening settings preserves an APK already handed to Android',
    () async {
      await downloaded();
      await controller.install();
      final path = fixture.installer.openedPath!;
      final reopened = fixture.controller();
      addTearDown(reopened.dispose);
      await reopened.load();
      expect(File(path).existsSync(), isTrue);
    },
  );

  test(
    'late permission result after changing channel cannot restore a stale APK',
    () async {
      await downloaded();
      final permission = Completer<bool>();
      fixture.installer.permission = () => permission.future;
      final resume = controller.onResume();
      await Future<void>.delayed(Duration.zero);
      await controller.selectChannel(UpdateChannel.nightly);
      permission.complete(true);
      await resume;
      expect(controller.status, UpdateStatus.idle);
      expect(controller.release, isNull);
    },
  );

  test('startup removes stale partials from earlier runs', () async {
    final dir = Directory('${fixture.cache.path}/updates')..createSync();
    final stale = File('${dir.path}/stale.part')..writeAsStringSync('partial');
    stale.setLastModifiedSync(DateTime.now().subtract(const Duration(days: 2)));
    await controller.load();
    expect(dir.listSync(), isEmpty);
  });

  test('unsupported platform never contacts GitHub', () async {
    fixture.installer.supported = false;
    await checked();
    expect(fixture.requested, isEmpty);
  });

  test('malformed GitHub JSON is a metadata error', () async {
    fixture.respond = (_) async => http.Response('not json', 200);
    await checked();
    expect(controller.error!.code, AppErrorCode.updateInvalid);
  });

  test(
    'download cancellation removes partial data and does not open installer',
    () async {
      final chunks = StreamController<List<int>>();
      var clients = 0;
      controller.dispose();
      controller = fixture.controller(
        clients: () => ++clients == 1
            ? MockClient(fixture.response)
            : _StreamingClient(chunks.stream),
      );
      await checked();
      final started = Completer<void>();
      controller.addListener(() {
        if (controller.receivedBytes > 0 && !started.isCompleted) {
          started.complete();
        }
      });
      final downloading = controller.download();
      chunks.add([1, 2]);
      await started.future;
      controller.cancel();
      await chunks.close();
      await downloading;
      expect(controller.status, UpdateStatus.available);
      expect(Directory('${fixture.cache.path}/updates').listSync(), isEmpty);
      expect(fixture.installer.openedPath, isNull);
    },
  );
}

class _StreamingClient extends http.BaseClient {
  _StreamingClient(this.bytes);
  final Stream<List<int>> bytes;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(bytes, 200);
}
