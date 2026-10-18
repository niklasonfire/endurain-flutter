import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:endurain/shared/state/safe_notifier.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';

class StatisticsController extends SafeNotifier {
  StatisticsController({
    required StatisticsRepository repository,
    required ValueListenable<String?> connection,
  }) : _repository = repository,
       _connection = connection {
    _connection.addListener(_connectionChanged);
  }
  final StatisticsRepository _repository;
  final ValueListenable<String?> _connection;
  StatisticsQuery query = StatisticsQuery();
  ActivityStatistics? statistics;
  Object? error;
  bool isLoading = false;
  int _generation = 0;
  bool get isGuest => _connection.value == null;
  void _connectionChanged() {
    _generation++;
    statistics = null;
    error = null;
    isLoading = false;
    query = StatisticsQuery();
    notify();
    if (!isGuest) unawaited(refresh());
  }

  Future<void> setQuery(StatisticsQuery value) {
    query = value;
    statistics = null;
    return refresh();
  }

  Future<void> refresh() async {
    if (isDisposed || isGuest) return;
    final generation = ++_generation;
    isLoading = true;
    error = null;
    notify();
    try {
      final result = await _repository.fetch(query);
      if (_current(generation)) statistics = result;
    } catch (failure) {
      if (_current(generation)) error = failure;
    } finally {
      if (_current(generation)) {
        isLoading = false;
        notify();
      }
    }
  }

  bool _current(int generation) =>
      !isDisposed && !isGuest && generation == _generation;
  @override
  void dispose() {
    _generation++;
    _connection.removeListener(_connectionChanged);
    super.dispose();
  }
}
