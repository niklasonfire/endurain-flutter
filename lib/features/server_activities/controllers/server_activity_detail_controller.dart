import 'package:endurain/core/services/offline_cache_store.dart';
import 'package:endurain/features/server_activities/models/server_activity_graph.dart';
import 'package:endurain/features/server_activities/repositories/server_activity_graph_repository.dart';
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
  List<ServerActivityGraph> _graphs = const [];
  List<ServerActivityLap> _laps = const [];
  Object? _graphError;
  Object? _lapError;
  bool _isGraphLoading = false;
  bool _isLapLoading = false;
  int _graphGeneration = 0;
  int _lapGeneration = 0;
  ServerActivity? _activity;
  List<ServerRoutePoint> _route = const [];
  Object? _error;
  Object? _routeError;
  bool _loading = false;
  bool _routeLoading = false;
  bool _accountChanged = false;
  int _detailGeneration = 0;
  int _routeGeneration = 0;
  DateTime? _cacheFetchedAt;

  List<ServerActivityGraph> get graphs => _graphs;
  List<ServerActivityLap> get laps => _laps;
  Object? get graphError => _graphError;
  Object? get lapError => _lapError;
  bool get isGraphLoading => _isGraphLoading;
  bool get isLapLoading => _isLapLoading;

  ServerActivity? get activity => _activity;
  List<ServerRoutePoint> get route => _route;
  Object? get error => _error;
  Object? get routeError => _routeError;
  bool get isLoading => _loading;
  bool get isRouteLoading => _routeLoading;
  bool get isAccountChanged => _accountChanged;

  /// When the visible detail was served from the offline read cache, the time
  /// its data was last fetched from the server; `null` for a live view.
  DateTime? get cacheFetchedAt => _cacheFetchedAt;

  Future<void> load() async {
    if (isDisposed || _accountChanged) return;
    await Future.wait([_loadDetail(), loadRoute(), loadGraphs(), loadLaps()]);
  }

  Future<void> _loadDetail() async {
    final generation = ++_detailGeneration;
    _loading = true;
    _error = null;
    _cacheFetchedAt = null;
    notify();
    try {
      final result = await _repository.fetchDetail(activityId);
      if (_valid && generation == _detailGeneration) {
        _activity = result;
        _cacheFetchedAt = _cacheProvenanceOf(result);
      }
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

  Future<void> loadGraphs() async {
    final repository = _repository;
    if (!_valid || repository is! ServerActivityGraphRepository) return;
    final generation = ++_graphGeneration;
    _isGraphLoading = true;
    _graphError = null;
    notify();
    try {
      final result = await (repository as ServerActivityGraphRepository)
          .fetchGraphs(activityId);
      if (_valid && generation == _graphGeneration) {
        _graphs = List.unmodifiable(result);
      }
    } catch (error) {
      if (_valid && generation == _graphGeneration) _graphError = error;
    } finally {
      if (_valid && generation == _graphGeneration) {
        _isGraphLoading = false;
        notify();
      }
    }
  }

  Future<void> loadLaps() async {
    final repository = _repository;
    if (!_valid || repository is! ServerActivityGraphRepository) return;
    final generation = ++_lapGeneration;
    _isLapLoading = true;
    _lapError = null;
    notify();
    try {
      final result = await (repository as ServerActivityGraphRepository)
          .fetchLaps(activityId);
      if (_valid && generation == _lapGeneration) {
        _laps = List.unmodifiable(result);
      }
    } catch (error) {
      if (_valid && generation == _lapGeneration) _lapError = error;
    } finally {
      if (_valid && generation == _lapGeneration) {
        _isLapLoading = false;
        notify();
      }
    }
  }

  bool get _valid => !isDisposed && !_accountChanged;

  void _invalidate() {
    _accountChanged = true;
    _detailGeneration++;
    _routeGeneration++;
    _graphGeneration++;
    _lapGeneration++;
    _graphs = const [];
    _laps = const [];
    _graphError = null;
    _lapError = null;
    _isGraphLoading = false;
    _isLapLoading = false;
    _activity = null;
    _route = const [];
    _error = null;
    _routeError = null;
    _loading = false;
    _routeLoading = false;
    _cacheFetchedAt = null;
    notify();
  }

  DateTime? _cacheProvenanceOf(ServerActivity result) {
    return switch (_repository) {
      final OfflineCacheProvenance provenance =>
        provenance.provenanceOf(result)?.fetchedAt,
      _ => null,
    };
  }

  @override
  void dispose() {
    _connection.removeListener(_invalidate);
    super.dispose();
  }
}
