import 'dart:async';

import 'package:endurain/features/updates/update_controller.dart';
import 'package:endurain/features/updates/update_screen.dart';
import 'package:endurain/l10n/app_localizations_en.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'update_fixture.dart';

void main() {
  late UpdateFixture fixture;
  late UpdateController controller;
  final l10n = AppLocalizationsEn();

  setUp(() {
    fixture = UpdateFixture();
    controller = fixture.controller();
  });
  tearDown(() {
    controller.dispose();
    fixture.dispose();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      AdaptiveApp(
        title: 'Test',
        locale: const Locale('en'),
        home: UpdateScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> ready(WidgetTester tester) async {
    await pump(tester);
    await tester.runAsync(() async {
      await controller.check();
      await controller.download();
    });
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.updatesInstall));
  }

  testWidgets(
    'shows installed code, local build channel and manual channel selection',
    (tester) async {
      await pump(tester);
      expect(find.text(l10n.updatesTitle), findsOneWidget);
      expect(
        find.text('Installed: 1.0.0+100000 (Local build)'),
        findsOneWidget,
      );
      expect(fixture.requested, isEmpty);
      await tester.tap(find.text('Nightly'));
      await tester.pumpAndSettle();
      expect(fixture.requested, isEmpty);
      expect(find.text(l10n.updatesNightlyDescription), findsOneWidget);
    },
  );

  testWidgets(
    'manual check displays notes, size and Download for a newer release',
    (tester) async {
      await pump(tester);
      await tester.runAsync(() async {
        final done = Completer<void>();
        void changed() {
          if ((controller.status == UpdateStatus.available ||
                  controller.status == UpdateStatus.failed) &&
              !done.isCompleted) {
            done.complete();
          }
        }

        controller.addListener(changed);
        await tester.tap(find.text(l10n.updatesCheck));
        await done.future;
        expect(
          controller.status,
          UpdateStatus.available,
          reason: controller.error.toString(),
        );
        controller.removeListener(changed);
      });
      await tester.pumpAndSettle();
      expect(find.text('1.2.3+100042'), findsOneWidget);
      expect(find.text('Release notes for this build'), findsOneWidget);
      expect(find.text(l10n.updatesDownload), findsOneWidget);
      expect(find.textContaining('Last successful check:'), findsOneWidget);
    },
  );

  testWidgets('current stable and waiting for stable are different messages', (
    tester,
  ) async {
    fixture.code = 100000;
    await pump(tester);
    await tester.runAsync(controller.check);
    await tester.pumpAndSettle();
    expect(find.text(l10n.updatesCurrent), findsOneWidget);
    fixture.code = 99999;
    await tester.runAsync(controller.check);
    await tester.pumpAndSettle();
    expect(find.text(l10n.updatesWaitingStable), findsOneWidget);
    expect(find.text(l10n.updatesDownload), findsNothing);
  });

  testWidgets('network errors are localized and keep a retry action', (
    tester,
  ) async {
    fixture.responseStatus = 403;
    await pump(tester);
    await tester.runAsync(controller.check);
    await tester.pumpAndSettle();
    expect(find.text(l10n.errorUpdateRateLimited), findsOneWidget);
    expect(find.text(l10n.updatesCurrent), findsNothing);
    expect(find.text(l10n.updatesCheck), findsOneWidget);
  });

  testWidgets(
    'unsupported platform explains why manual APK checking is disabled',
    (tester) async {
      fixture.installer.supported = false;
      await pump(tester);
      expect(find.text(l10n.updatesUnsupported), findsOneWidget);
      final action = tester.widget<AdaptiveButton>(
        find.widgetWithText(AdaptiveButton, l10n.updatesCheck),
      );
      expect(action.onPressed, isNull);
    },
  );

  testWidgets('recording changes immediately disable and re-enable Install', (
    tester,
  ) async {
    await ready(tester);
    fixture.recording = true;
    fixture.recordingChanges.notifyListeners();
    await tester.pumpAndSettle();
    expect(find.text(l10n.updatesRecordingActive), findsOneWidget);
    expect(
      tester
          .widget<AdaptiveButton>(
            find.widgetWithText(AdaptiveButton, l10n.updatesInstall),
          )
          .onPressed,
      isNull,
    );
    fixture.recording = false;
    fixture.recordingChanges.notifyListeners();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AdaptiveButton>(
            find.widgetWithText(AdaptiveButton, l10n.updatesInstall),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('permission round trip requires a second explicit Install tap', (
    tester,
  ) async {
    fixture.installer.allowed = false;
    await ready(tester);
    await tester.tap(find.text(l10n.updatesInstall));
    await tester.pumpAndSettle();
    expect(find.text(l10n.updatesPermission), findsOneWidget);
    expect(fixture.installer.openedPath, isNull);
    fixture.installer.allowed = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text(l10n.updatesPermission), findsNothing);
    await tester.ensureVisible(find.text(l10n.updatesInstall));
    await tester.tap(find.text(l10n.updatesInstall));
    await tester.pumpAndSettle();
    expect(find.text(l10n.updatesInstallerOpened), findsOneWidget);
    expect(find.text(l10n.updatesCurrent), findsNothing);
  });
}
