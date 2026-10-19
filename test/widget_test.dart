import 'package:endurain/features/activity/controllers/activity_recording_controller.dart';
import 'package:endurain/features/activity/models/active_activity_session.dart';
import 'package:endurain/features/activity/models/activity_recording_state.dart';
import 'package:endurain/features/activity/models/activity_type.dart';
import 'package:endurain/features/activity/services/activity_recording_service.dart';
import 'package:endurain/features/activity/services/geolocator_activity_location_recorder.dart';

import 'helpers/in_memory_active_activity_store.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:endurain/app.dart';
import 'package:endurain/core/config/app_config.dart';
import 'package:endurain/core/services/app_services.dart';
import 'package:endurain/core/services/auth_service.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/features/auth/controllers/auth_session_controller.dart';
import 'package:endurain/features/auth/screens/login_screen.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('App wires the router and shows the splash while loading', (
    WidgetTester tester,
  ) async {
    // App does not initialise an injected controller, so it stays on the
    // splash. This smoke-tests App + router wiring without rendering the map
    // or login destinations, which need heavier services.
    final sessionController = AuthSessionController(
      authService: AuthService(storage: SecureStorageService()),
    );
    addTearDown(sessionController.dispose);

    await tester.pumpWidget(App(sessionController: sessionController));
    await tester.pump();

    expect(find.byType(AdaptiveLoadingIndicator), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('App restores a durable recording before any map is opened', (
    tester,
  ) async {
    final store = InMemoryActiveActivityStore()
      ..session = ActiveActivitySession(
        localSessionId: 'before-restart',
        activityType: ActivityType.ride,
        status: ActiveActivityStatus.recording,
        startedAt: DateTime.utc(2026, 10, 19, 8),
        elapsedDurationSeconds: 120,
      );
    final controller = ActivityRecordingController(
      recordingService: ActivityRecordingService(
        recorder: GeolocatorActivityLocationRecorder(store: store),
      ),
    );
    addTearDown(controller.dispose);
    final services = _RecordingServices(controller);
    final session = AuthSessionController(authService: services.auth);
    addTearDown(session.dispose);
    await tester.pumpWidget(
      App(services: services, sessionController: session),
    );
    // A fast user action shares the in-flight startup recovery; it cannot
    // overwrite the existing durable session with a new run.
    final quickStart = controller.start(ActivityType.run);
    for (var i = 0; i < 20; i++) {
      await tester.pump();
    }
    await quickStart;

    expect(find.byType(AdaptiveLoadingIndicator), findsOneWidget);
    expect(controller.state.status, ActivityRecordingStatus.paused);
    expect(controller.state.elapsedDurationSeconds, 120);
    expect(controller.selectedActivityType, ActivityType.ride);
    // Starting while recovery owns an existing session must keep that session.
    await controller.start(ActivityType.run);
    expect(controller.state.elapsedDurationSeconds, 120);
    expect(store.session!.localSessionId, 'before-restart');
  });

  testWidgets('App safely handles foreground lifecycle transitions', (
    WidgetTester tester,
  ) async {
    final services = AppServices(
      config: const AppConfig(healthSyncEnabled: false),
    );
    final sessionController = AuthSessionController(
      authService: AuthService(storage: services.secureStorage),
    );
    addTearDown(sessionController.dispose);

    await tester.pumpWidget(
      App(services: services, sessionController: sessionController),
    );
    await tester.pump();

    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await tester.pump();

    expect(find.byType(AdaptiveLoadingIndicator), findsOneWidget);
  });
}

class _RecordingServices extends AppServices {
  _RecordingServices(this.controller);
  final ActivityRecordingController controller;
  @override
  ActivityRecordingController get activityRecordingController => controller;
}
