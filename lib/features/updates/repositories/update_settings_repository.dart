import 'package:endurain/core/models/app_exception.dart';
import 'package:endurain/core/services/app_preferences_store.dart';
import 'package:endurain/features/updates/models/update_preferences.dart';
import 'package:endurain/features/updates/models/update_release.dart';

/// Owns update preference keys and serializes channel writes across intents.
class UpdateSettingsRepository {
  UpdateSettingsRepository({required AppPreferencesStore preferences})
    : _preferences = preferences;
  final AppPreferencesStore _preferences;
  static const _channelKey = 'updates.channel';
  static const _checkedKey = 'updates.lastChecked';
  Future<void> _channelWrite = Future.value();

  Future<UpdatePreferences> load() => _storage(() async {
    final saved = await _preferences.read(key: _channelKey);
    return UpdatePreferences(
      channel: saved == 'nightly'
          ? UpdateChannel.nightly
          : UpdateChannel.stable,
      lastChecked: DateTime.tryParse(
        await _preferences.read(key: _checkedKey) ?? '',
      ),
    );
  });

  Future<void> saveChannel(UpdateChannel channel) {
    _channelWrite = _channelWrite
        .catchError((Object _) {})
        .then(
          (_) => _storage(
            () => _preferences.write(key: _channelKey, value: channel.name),
          ),
        );
    return _channelWrite;
  }

  Future<void> saveLastChecked(DateTime date) => _storage(
    () => _preferences.write(key: _checkedKey, value: date.toIso8601String()),
  );

  Future<T> _storage<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (cause) {
      throw AppException(AppErrorCode.updateStorage, cause: cause);
    }
  }
}
