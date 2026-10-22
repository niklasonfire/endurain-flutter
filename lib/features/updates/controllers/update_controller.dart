import 'dart:async';

import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/features/updates/models/downloaded_update.dart';
import 'package:endurain/features/updates/models/installed_update_info.dart';
import 'package:endurain/features/updates/models/update_release.dart';
import 'package:endurain/features/updates/models/update_status.dart';
import 'package:endurain/features/updates/repositories/update_settings_repository.dart';
import 'package:endurain/features/updates/services/update_installer.dart';
import 'package:endurain/features/updates/services/update_service.dart';
import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:flutter/foundation.dart';

/// Route-owned update workflow. HTTP, verified cache files and persistence stay
/// behind injectable data modules; the controller owns user-visible transitions.
class UpdateController extends SafeNotifier {
  UpdateController({
    required UpdateSettingsRepository settings,
    required UpdateService updates,
    required UpdateInstaller installer,
    required bool Function() recordingActive,
    this.installedChannel = 'local',
    Listenable? recordingChanges,
  }) : _settings = settings,
       _updates = updates,
       _installer = installer,
       _recordingActive = recordingActive,
       _recordingChanges = recordingChanges {
    _recordingChanges?.addListener(notify);
  }
  final UpdateSettingsRepository _settings;
  final UpdateService _updates;
  final UpdateInstaller _installer;
  final Listenable? _recordingChanges;
  final bool Function() _recordingActive;
  final String installedChannel;
  UpdateChannel _channel = UpdateChannel.stable;
  UpdateStatus _status = UpdateStatus.loading;
  InstalledUpdateInfo? _installed;
  UpdateRelease? _release;
  AppException? _error;
  DateTime? _lastChecked;
  int _receivedBytes = 0;
  DownloadedUpdate? _downloaded;
  String? _handedOffPath;
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
      final saved = await _settings.load();
      _channel = saved.channel;
      _lastChecked = saved.lastChecked;
      _installed = await _installer.installedInfo();
      await _updates.cleanStaleCache();
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
      await _settings.saveChannel(value);
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
    _release = null;
    _error = null;
    _status = UpdateStatus.checking;
    notify();
    try {
      final candidate = await _updates.check(selectedChannel, _installed!);
      if (!_current(generation) || candidate == null) return;
      _release = candidate;
      final code = _installed!.versionCode;
      _status = candidate.versionCode > code
          ? UpdateStatus.available
          : candidate.versionCode < code &&
                selectedChannel == UpdateChannel.stable
          ? UpdateStatus.waitingStable
          : UpdateStatus.current;
      _lastChecked = DateTime.now().toUtc();
      await _settings.saveLastChecked(_lastChecked!);
    } catch (cause) {
      if (_current(generation)) _fail(cause, AppErrorCode.updateNetwork);
    } finally {
      if (_current(generation)) notify();
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
    _status = UpdateStatus.downloading;
    _receivedBytes = 0;
    _error = null;
    notify();
    var missing = false;
    try {
      final path = await _updates.download(
        candidate,
        onProgress: (received) {
          if (!_current(generation)) return;
          _receivedBytes = received;
          notify();
        },
      );
      if (!_current(generation) || path == null) return;
      _downloaded = path;
      _status = UpdateStatus.ready;
    } catch (cause) {
      if (_current(generation)) {
        missing = cause is AppException && cause.statusCode == 404;
        _fail(cause, AppErrorCode.updateNetwork);
      }
    } finally {
      if (_current(generation)) notify();
    }
    if (missing && _current(generation)) {
      // A rolling release may remove an APK between checking and downloading.
      // Re-resolve once, then require a new explicit download intent.
      await check();
    }
  }

  void cancel() {
    _generation++;
    _updates.cancel();
    final old = _downloaded;
    _downloaded = null;
    if (old != null && old.path != _handedOffPath) {
      unawaited(_updates.discard(old));
    }
    if (_status == UpdateStatus.downloading) _status = UpdateStatus.available;
    notify();
  }

  Future<void> install() async {
    final candidate = _release;
    final download = _downloaded;
    if (_installing || candidate == null || download == null) return;
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
      _handedOffPath = download.path;
      await _installer.install(
        download.path,
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

  @override
  void dispose() {
    // Preserve the APK Android may still read after this route closes.
    _generation++;
    _updates.dispose();
    _recordingChanges?.removeListener(notify);
    super.dispose();
  }
}
