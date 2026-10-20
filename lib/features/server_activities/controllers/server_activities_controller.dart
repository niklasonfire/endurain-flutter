import 'dart:async';

import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/server_activities/models/server_route_point.dart';
import 'package:endurain/features/server_activities/repositories/server_activities_repository.dart';
import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:flutter/foundation.dart';

/// Account-scoped server list. Generations reject responses from an old
/// account, query, refresh, or disposed screen, including outstanding pages.
class ServerActivitiesController extends SafeNotifier {
  ServerActivitiesController({
    required ServerActivitiesRepository repository,
    required ValueListenable<String?> connection,
  }) : _repository = repository,
       _connection = connection {
    _connection.addListener(_connectionChanged);
  }

  final ServerActivitiesRepository _repository;
  final ValueListenable<String?> _connection;
  List<ServerActivity> _items = const [];
  List<int> _activityTypes = [];
  ServerActivityQuery _query = const ServerActivityQuery();
  int _generation = 0;
  static const _maxRouteRequests = 2;
  static const _routeCacheCapacity = 40;
  int _routeGeneration = 0;
  int _nextRouteSlot = 0;
  final _routeSlots = List.generate(
    _maxRouteRequests,
    (_) => Future<void>.value(),
  );
  final _routeCache = <int, Future<List<ServerRoutePoint>>>{};
  int _page = 0;
  bool _hasMore = false;
  bool _loading = false;
  bool _loadingMore = false;
  Object? _error;
  Object? _loadMoreError;

  // Replace immutable snapshots on updates; scrolling can read them without
  // copying the full paginated history for each visible card.
  List<ServerActivity> get items => _items;
  List<int> get activityTypes => List.unmodifiable(_activityTypes);
  ServerActivityQuery get query => _query;
  String? get connectionId => _connection.value;

  /// Rebind visible preview futures after a refresh without discarding cached
  /// successful routes (including legitimate empty routes).
  int get previewRevision => _generation;
  bool get isGuest => _connection.value == null;
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  Object? get error => _error;
  Object? get loadMoreError => _loadMoreError;
  bool get hasFilters =>
      _query.search.isNotEmpty ||
      _query.activityType != null ||
      _query.startDate != null ||
      _query.endDate != null;

  void _connectionChanged() {
    _clearRoutes();
    _generation++;
    _items = const [];
    _activityTypes = [];
    _query = const ServerActivityQuery();
    _page = 0;
    _hasMore = false;
    _loading = false;
    _loadingMore = false;
    _error = null;
    _loadMoreError = null;
    notify();
    if (!isGuest) unawaited(refresh());
  }

  Future<void> setQuery(ServerActivityQuery query) {
    _clearRoutes();
    _query = query;
    return refresh(clear: true);
  }

  Future<void> refresh({bool clear = false}) async {
    final generation = ++_generation;
    if (isGuest || isDisposed) return;
    if (clear) {
      _items = const [];
      _page = 0;
      _hasMore = false;
    }
    _loading = true;
    _loadingMore = false;
    _error = null;
    _loadMoreError = null;
    notify();
    unawaited(_loadTypes(generation));
    try {
      final result = await _repository.fetchPage(query: _query);
      if (!_isCurrent(generation)) return;
      _items = _unique(result.items);
      _page = result.page;
      _hasMore = result.hasMore;
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _error = error;
    } finally {
      if (_isCurrent(generation)) {
        _loading = false;
        notify();
      }
    }
  }

  Future<void> _loadTypes(int generation) async {
    try {
      final types = await _repository.fetchActivityTypes();
      if (!_isCurrent(generation)) return;
      _activityTypes = types.toSet().toList()..sort();
      notify();
    } catch (_) {
      // A failed optional type catalog must not hide the activity list.
    }
  }

  Future<void> loadMore() async {
    if (isGuest || isDisposed || _loading || _loadingMore || !_hasMore) return;
    final generation = _generation;
    _loadingMore = true;
    _loadMoreError = null;
    notify();
    try {
      final result = await _repository.fetchPage(
        query: _query,
        page: _page + 1,
      );
      if (!_isCurrent(generation)) return;
      _items = _unique([..._items, ...result.items]);
      _page = result.page;
      _hasMore = result.hasMore;
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _loadMoreError = error;
    } finally {
      if (_isCurrent(generation)) {
        _loadingMore = false;
        notify();
      }
    }
  }

  /// Only cards built by the viewport request routes. Two network slots and a
  /// forty-entry LRU keep scrolling from fetching or retaining entire history.
  Future<List<ServerRoutePoint>> loadRoute(int activityId) {
    if (isGuest || isDisposed) return Future.value(const []);
    final cached = _routeCache.remove(activityId);
    if (cached != null) {
      _routeCache[activityId] = cached;
      return cached;
    }
    final generation = _routeGeneration;
    final slot = _nextRouteSlot;
    _nextRouteSlot = (_nextRouteSlot + 1) % _routeSlots.length;
    final previous = _routeSlots[slot];
    final release = Completer<void>();
    _routeSlots[slot] = release.future;
    late final Future<List<ServerRoutePoint>> result;
    result = () async {
      await previous;
      try {
        // Evicted or obsolete queued requests never reach the server.
        if (!_routeIsCurrent(generation) ||
            !identical(_routeCache[activityId], result)) {
          return const <ServerRoutePoint>[];
        }
        final points = await _repository.fetchRoute(activityId);
        return _routeIsCurrent(generation)
            ? points
            : const <ServerRoutePoint>[];
      } catch (_) {
        // Transient failures use the fallback now and may retry after refresh.
        // Successful empty GPS-less routes remain cached by the success path.
        if (identical(_routeCache[activityId], result)) {
          unawaited(_routeCache.remove(activityId));
        }
        return const <ServerRoutePoint>[];
      } finally {
        release.complete();
      }
    }();
    _routeCache[activityId] = result;
    if (_routeCache.length > _routeCacheCapacity) {
      _routeCache.remove(_routeCache.keys.first);
    }
    return result;
  }

  bool _routeIsCurrent(int generation) =>
      !isDisposed && !isGuest && generation == _routeGeneration;

  void _clearRoutes() {
    _routeGeneration++;
    _routeCache.clear();
  }

  bool _isCurrent(int generation) =>
      !isDisposed && generation == _generation && !isGuest;

  List<ServerActivity> _unique(List<ServerActivity> activities) {
    final ids = <int>{};
    return List.unmodifiable(
      activities.where((activity) => ids.add(activity.id)),
    );
  }

  @override
  void dispose() {
    _clearRoutes();
    _generation++;
    _connection.removeListener(_connectionChanged);
    super.dispose();
  }
}
