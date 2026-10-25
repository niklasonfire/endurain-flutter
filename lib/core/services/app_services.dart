import 'package:endurain/features/updates/repositories/update_settings_repository.dart';
import 'package:endurain/features/updates/services/update_service.dart';
import 'package:endurain/features/updates/controllers/update_controller.dart';
import 'package:endurain/features/updates/services/update_installer.dart';
import 'package:endurain/features/activity/models/activity_recording_state.dart';
import 'package:endurain/features/home/controllers/home_controller.dart';
import 'package:endurain/features/goals/repositories/cached_goals_repository.dart';
import 'package:endurain/features/goals/repositories/goals_repository.dart';
import 'package:endurain/features/goals/repositories/api_goals_repository.dart';
import 'package:endurain/features/activity/models/local_activity_record.dart';
import 'package:endurain/features/statistics/controllers/statistics_controller.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:endurain/features/statistics/repositories/api_statistics_repository.dart';
import 'package:endurain/core/config/app_config.dart';
import 'package:endurain/core/services/api_client.dart';
import 'package:endurain/core/services/app_infrastructure.dart';
import 'package:endurain/core/services/app_preferences_store.dart';
import 'package:endurain/core/services/auth_service.dart';
import 'package:endurain/core/services/auth_session_store.dart';
import 'package:endurain/core/services/connectivity_service.dart';
import 'package:endurain/core/services/crash_reporting_service.dart';
import 'package:endurain/core/services/diagnostics_service.dart';
import 'package:endurain/core/services/location_service.dart';
import 'package:endurain/core/services/offline_cache_identity_wiper.dart';
import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/core/services/modules/activity_module.dart';
import 'package:endurain/core/services/modules/auth_module.dart';
import 'package:endurain/core/services/modules/health_module.dart';
import 'package:endurain/core/services/modules/sensors_module.dart';
import 'package:endurain/core/services/platform/app_links_service.dart';
import 'package:endurain/core/services/platform/package_info_service.dart';
import 'package:endurain/core/services/platform/share_service.dart';
import 'package:endurain/core/services/platform/url_launcher_service.dart';
import 'package:endurain/core/services/secure_storage_service.dart';
import 'package:endurain/core/services/server_settings_service.dart';
import 'package:endurain/core/services/sqflite_offline_cache_store.dart';
import 'package:endurain/core/services/sso_service.dart';
import 'package:endurain/features/server_activities/controllers/server_activities_controller.dart';
import 'package:endurain/features/server_activities/repositories/api_server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/cached_server_activities_repository.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/features/activity/controllers/activity_recording_controller.dart';
import 'package:endurain/features/activity/controllers/auto_pause_settings_controller.dart';
import 'package:endurain/features/activity/controllers/local_activity_history_controller.dart';
import 'package:endurain/features/activity/repositories/activity_retention_settings_repository.dart';
import 'package:endurain/features/activity/repositories/auto_pause_settings_repository.dart';
import 'package:endurain/features/activity/repositories/local_activity_repository.dart';
import 'package:endurain/features/activity/services/activity_location_recorder.dart';
import 'package:endurain/features/activity/services/activity_recording_service.dart';
import 'package:endurain/features/activity/services/activity_upload_queue.dart';
import 'package:endurain/features/activity/services/activity_upload_service.dart';
import 'package:endurain/features/activity/services/local_activity_gpx_storage.dart';
import 'package:endurain/features/health/controllers/health_sync_controller.dart';
import 'package:endurain/features/health/repositories/health_import_repository.dart';
import 'package:endurain/features/health/repositories/health_sync_settings_repository.dart';
import 'package:endurain/features/health/services/health_platform_adapter.dart';
import 'package:endurain/features/health/services/health_sync_service.dart';
import 'package:endurain/features/map/repositories/map_settings_repository.dart';
import 'package:endurain/features/sensors/models/sensor_measurement.dart';
import 'package:endurain/features/sensors/services/sensor_connection_adapter.dart';
import 'package:endurain/features/sensors/services/sensor_profile.dart';
import 'package:endurain/features/sensors/services/sensor_service.dart';
import 'package:endurain/features/settings/controllers/audio_announcement_settings_controller.dart';
import 'package:endurain/features/settings/controllers/locale_controller.dart';
import 'package:endurain/features/settings/controllers/measurement_system_controller.dart';
import 'package:endurain/features/settings/controllers/settings_controller.dart';

/// The application's composition root.
///
/// [AppServices] wires the shared [AppInfrastructure] and the per-feature
/// modules ([AuthModule], [SensorsModule], [ActivityModule], [HealthModule])
/// once, in dependency order, and exposes them through a stable public surface
/// that screens and controllers reach via `AppScope.servicesOf(context)`.
///
/// Each feature's wiring lives in its own module so this file stays small and
/// a contributor changing one feature does not touch the others. The two
/// cross-feature back-edges are resolved here rather than inside a module:
/// - sensors ↔ activity: [SensorsModule] receives a `canAutoReconnect` gate
///   backed by [ActivityModule.canAutoReconnectSensors]; the closure is lazy,
///   so either module can be built first.
/// - activity → health: the local-history controller's default health-import
///   cleanup is injected here (see [createLocalActivityHistoryController]).
class AppServices {
  AppServices({this.config = AppConfig.defaults}) {
    // Offline read cache lifecycle (ADR-0001): the cache belongs to the active
    // identity, so wipe the identity being left on logout/server switch. The
    // subscription outlives this constructor: the session store's notifier
    // keeps the wiper's listener (and thereby the wiper) alive for the app's
    // lifetime.
    OfflineCacheIdentityWiper(
      cacheStore: offlineCache,
      connectionChanges: authSession.connectionChanges,
    );
  }

  /// Runtime configuration shared by every service.
  final AppConfig config;

  late final AppInfrastructure _infra = AppInfrastructure(config: config);
  late final AuthModule _auth = AuthModule(_infra);

  // [SensorsModule] and [ActivityModule] reference each other; the gate closure
  // below is only evaluated at runtime, so the `late final` fields can be built
  // in either order without a cycle.
  late final SensorsModule _sensors = SensorsModule(
    infra: _infra,
    canAutoReconnect: () => _activity.canAutoReconnectSensors(),
  );
  late final ActivityModule _activity = ActivityModule(
    infra: _infra,
    auth: _auth,
    sensors: _sensors,
  );
  late final HealthModule _health = HealthModule(
    infra: _infra,
    auth: _auth,
    activity: _activity,
  );

  // ── Infrastructure ─────────────────────────────────────────────────────────

  DiagnosticsService get diagnostics => _infra.diagnostics;
  CrashReportingService get crashReporting => _infra.crashReporting;
  SecureStorageService get secureStorage => _infra.secureStorage;
  AppPreferencesStore get preferences => _infra.preferences;
  LocaleController get localeController => _infra.localeController;
  MeasurementSystemController get measurementSystemController =>
      _infra.measurementSystemController;
  LocationService get location => _infra.location;
  ConnectivityService get connectivity => _infra.connectivity;
  AppLinksService get appLinks => _infra.appLinks;
  UrlLauncherService get urlLauncher => _infra.urlLauncher;
  ShareService get share => _infra.share;
  PackageInfoService get packageInfo => _infra.packageInfo;

  // ── Auth ─────────────────────────────────────────────────────────────────

  AuthSessionStore get authSession => _auth.session;
  AuthService get auth => _auth.service;
  SsoService get sso => _auth.sso;
  ServerSettingsService get serverSettings => _auth.serverSettings;
  ApiClient get apiClient => _auth.apiClient;

  /// Offline read cache shared by every server-backed repository (ADR-0001).
  late final OfflineCacheStore offlineCache = SqfliteOfflineCacheStore();

  late final ServerActivitiesRepository serverActivities =
      CachedServerActivitiesRepository(
        inner: ApiServerActivitiesRepository(
          apiClient: apiClient,
          sessionStore: authSession,
          endpoints: _infra.endpoints,
        ),
        cacheStore: offlineCache,
        connectionProfile: authSession.getConnectionProfile,
      );

  ServerActivitiesController createServerActivitiesController({
    ServerActivitiesRepository? repository,
  }) => ServerActivitiesController(
    repository: repository ?? serverActivities,
    connection: authSession.connectionChanges,
  );

  late final StatisticsRepository statistics = ApiStatisticsRepository(
    apiClient: apiClient,
    sessionStore: authSession,
    endpoints: _infra.endpoints,
  );

  StatisticsController createStatisticsController({
    StatisticsRepository? repository,
  }) => StatisticsController(
    repository: repository ?? statistics,
    connection: authSession.connectionChanges,
  );

  late final GoalsRepository goals = CachedGoalsRepository(
    inner: ApiGoalsRepository(
      apiClient: apiClient,
      sessionStore: authSession,
      endpoints: _infra.endpoints,
    ),
    cacheStore: offlineCache,
    connectionProfile: authSession.getConnectionProfile,
  );

  HomeController createHomeController({
    StatisticsRepository? statisticsRepository,
    ServerActivitiesRepository? activitiesRepository,
    GoalsRepository? goalsRepository,
  }) => HomeController(
    statisticsRepository: statisticsRepository ?? statistics,
    activitiesRepository: activitiesRepository ?? serverActivities,
    goalsRepository: goalsRepository ?? goals,
    connection: authSession.connectionChanges,
    loadLocalActivities: localActivities.list,
    loadPendingUploads: () async {
      final profile = await authSession.getConnectionProfile();
      if (profile == null) return 0;
      final records = await localActivities.listByUploadStatus({
        LocalActivityUploadStatus.pending,
        LocalActivityUploadStatus.failed,
      });
      return records
          .where(
            (r) =>
                r.connectionOrigin == profile.origin &&
                r.connectionProfileId == profile.id,
          )
          .length;
    },
  );

  // ── Activity ───────────────────────────────────────────────────────────────

  ActivityUploadService get activityUpload => _activity.upload;
  LocalActivityGpxStorage get localActivityGpxStorage => _activity.gpxStorage;
  LocalActivityRepository get localActivities => _activity.localActivities;
  ActivityRetentionSettingsRepository get activityRetentionSettings =>
      _activity.retentionSettings;
  AutoPauseSettingsRepository get activityAutoPauseSettings =>
      _activity.autoPauseSettings;
  ActivityUploadQueue get activityUploadQueue => _activity.uploadQueue;
  ActivityRecordingController get activityRecordingController =>
      _activity.recordingController;

  /// App-lifetime controller for the audio-announcement preferences (master
  /// on/off, ducking, and the per-activity-type interval). Read from the
  /// settings screen and from the map screen when starting a recording.
  AudioAnnouncementSettingsController get audioAnnouncementSettingsController =>
      _activity.audioAnnouncementSettingsController;

  /// Builds the active-recording recorder for the current platform.
  ActivityLocationRecorder createActivityLocationRecorder({
    LocationService? locationService,
  }) => _activity.createLocationRecorder(locationService: locationService);

  /// Assembles a ready-to-use [ActivityRecordingService] for the current
  /// platform, wiring the correct recorder and the sensor sources.
  ActivityRecordingService createActivityRecordingService({
    LocationService? locationService,
  }) => _activity.createRecordingService(locationService: locationService);

  /// Builds a route-owned [LocalActivityHistoryController].
  ///
  /// Screen-level overrides (typically injected in tests) take precedence over
  /// the app-lifetime services wired here. The default health-import cleanup is
  /// injected from [HealthModule], keeping that cross-feature edge in the root.
  /// Defaults are resolved from this composition root's getters so a subclass
  /// (or test) can override them.
  LocalActivityHistoryController createLocalActivityHistoryController({
    LocalActivityRepository? repository,
    ActivityUploadService? uploadService,
    ShareService? shareService,
    ActivityRetentionSettingsRepository? retentionSettingsRepository,
    Future<void> Function(String localActivityId)? removeImportProvenance,
  }) {
    return _activity.createHistoryController(
      removeImportProvenance:
          removeImportProvenance ??
          _health.importRepository.removeByLocalActivityId,
      repository: repository ?? localActivities,
      uploadService: uploadService ?? activityUpload,
      shareService: shareService ?? share,
      retentionSettingsRepository:
          retentionSettingsRepository ?? activityRetentionSettings,
    );
  }

  // ── Health sync ────────────────────────────────────────────────────────────

  HealthSyncSettingsRepository get healthSyncSettings => _health.syncSettings;
  HealthImportRepository get healthImportRepository => _health.importRepository;
  HealthSyncService get healthSyncService => _health.syncService;

  /// Creates a route-owned controller for health-platform workout sync.
  HealthSyncController createHealthSyncController() =>
      _health.createSyncController();

  /// Builds the concrete health-platform adapter for the current platform.
  HealthPlatformAdapter createHealthPlatformAdapter() =>
      _health.createPlatformAdapter();

  // ── External sensors (BLE) ───────────────────────────────────────────────

  /// The app-lifetime sensor coordinators keyed by kind.
  Map<SensorMeasurementKind, SensorService> get sensorServices =>
      _sensors.services;

  SensorService get heartRateSensorService => _sensors.heartRate;
  SensorService get powerSensorService => _sensors.power;
  SensorService get cadenceSensorService => _sensors.cadence;

  /// Best-effort reconnect of every remembered sensor (heart rate, power,
  /// cadence). A no-op per kind when nothing is remembered, one is already
  /// connected, Bluetooth is off, or a recording currently owns the sensor.
  Future<void> reconnectRememberedSensors() => _sensors.reconnectRemembered();

  /// Builds a BLE sensor adapter for [profiles] on the current platform.
  SensorConnectionAdapter createSensorConnectionAdapter(
    List<SensorProfile> profiles,
  ) => _sensors.createAdapter(profiles);

  // ── Map ────────────────────────────────────────────────────────────────────

  /// Builds a [MapSettingsRepository] scoped to the active connection origin.
  MapSettingsRepository createMapSettingsRepository() {
    return MapSettingsRepository(
      preferences: _infra.preferences,
      config: config,
      activeConnectionOrigin: _auth.session.getAuthenticatedOrigin,
    );
  }

  // ── Settings ───────────────────────────────────────────────────────────────

  /// Builds a route-owned [SettingsController] for the settings screen.
  ///
  /// The unit preference is delegated to the app-lifetime
  /// [measurementSystemController] so a change made here re-renders the rest
  /// of the app, not just this route.
  SettingsController createSettingsController() {
    return SettingsController(
      packageInfoService: _infra.packageInfo,
      retentionSettingsRepository: _activity.retentionSettings,
      measurementSystemController: _infra.measurementSystemController,
      secureStorage: _infra.secureStorage,
      offlineCache: offlineCache,
    );
  }

  /// Builds a route-owned [AutoPauseSettingsController] for the auto-pause
  /// settings screen.
  AutoPauseSettingsController createAutoPauseSettingsController() {
    return AutoPauseSettingsController(repository: _activity.autoPauseSettings);
  }

  /// Creates the route-owned manual APK update module for this distribution.
  UpdateController createUpdateController() => UpdateController(
    settings: UpdateSettingsRepository(preferences: preferences),
    updates: UpdateService(repository: config.updateRepository),
    installedChannel: config.updateChannel,
    installer: const AndroidUpdateInstaller(),
    recordingChanges: activityRecordingController,
    recordingActive: () {
      final state = activityRecordingController.state;
      return activityRecordingController.isRecoveringRecording ||
          state.isActive ||
          state.status == ActivityRecordingStatus.stopping ||
          state.canRecover ||
          (state.status == ActivityRecordingStatus.completed &&
              activityRecordingController.completedLocalActivityId == null);
    },
  );
}
