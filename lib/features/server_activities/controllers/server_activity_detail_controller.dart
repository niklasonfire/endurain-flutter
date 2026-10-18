import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:flutter/foundation.dart';

/// Details belong to the account that opened this screen. A connection change
/// permanently invalidates the destination, even when the new account has an
/// activity with the same numeric id.
class ServerActivityDetailController extends SafeNotifier {
  ServerActivityDetailController({
    required this.activityId,
    required ServerActivitiesRepository repository,
    required ValueListenable<String?> connection,
  }) : _repository = repository,
       _connection = connection {
    _connection.addListener(_invalidate);
    _accountChanged = connection.value == null;
  }

  final int activityId;
  final ServerActivitiesRepository _repository;
  final ValueListenable<String?> _connection;
  ServerActivity? _activity;
  List<ServerRoutePoint> _route = const [];
  Object? _error;
  Object? _routeError;
  bool _loading = false;
  bool _routeLoading = false;
  bool _accountChanged = false;
  int _detailGeneration = 0;
  int _routeGeneration = 0;

  ServerActivity? get activity => _activity;
  List<ServerRoutePoint> get route => _route;
  Object? get error => _error;
  Object? get routeError => _routeError;
  bool get isLoading => _loading;
  bool get isRouteLoading => _routeLoading;
  bool get isAccountChanged => _accountChanged;

  Future<void> load() async {
    if (isDisposed || _accountChanged) return;
    await Future.wait([_loadDetail(), loadRoute()]);
  }

  Future<void> _loadDetail() async {
    final generation = ++_detailGeneration;
    _loading = true;
    _error = null;
    notify();
    try {
      final result = await _repository.fetchDetail(activityId);
      if (_valid && generation == _detailGeneration) _activity = result;
    } catch (error) {
      if (_valid && generation == _detailGeneration) _error = error;
    } finally {
      if (_valid && generation == _detailGeneration) {
        _loading = false;
        notify();
      }
    }
  }

  Future<void> loadRoute() async {
    if (!_valid) return;
    final generation = ++_routeGeneration;
    _routeLoading = true;
    _routeError = null;
    notify();
    try {
      final result = await _repository.fetchRoute(activityId);
      if (_valid && generation == _routeGeneration) {
        _route = List.unmodifiable(result);
      }
    } catch (error) {
      if (_valid && generation == _routeGeneration) _routeError = error;
    } finally {
      if (_valid && generation == _routeGeneration) {
        _routeLoading = false;
        notify();
      }
    }
  }

  bool get _valid => !isDisposed && !_accountChanged;

  void _invalidate() {
    _accountChanged = true;
    _detailGeneration++;
    _routeGeneration++;
    _activity = null;
    _route = const [];
    _error = null;
    _routeError = null;
    _loading = false;
    _routeLoading = false;
    notify();
  }

  @override
  void dispose() {
    _connection.removeListener(_invalidate);
    super.dispose();
  }
}
