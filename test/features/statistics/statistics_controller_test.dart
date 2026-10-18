import 'dart:async';

import 'package:endurain/features/statistics/controllers/statistics_controller.dart';
import 'package:endurain/features/statistics/models/activity_statistics.dart';
import 'package:endurain/features/statistics/repositories/statistics_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class Repository implements StatisticsRepository {
  final requests = <Completer<ActivityStatistics>>[];
  @override
  Future<ActivityStatistics> fetch(StatisticsQuery query) {
    final result = Completer<ActivityStatistics>();
    requests.add(result);
    return result.future;
  }
}

void main() {
  test(
    'account switch clears totals and rejects a late previous response',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Repository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final first = controller.refresh();
      connection.value = 'b';
      repository.requests.first.complete(ActivityStatistics.empty);
      await first;
      expect(controller.statistics, isNull);
      expect(controller.isLoading, isTrue);
      repository.requests.last.complete(ActivityStatistics.empty);
      await Future<void>.delayed(Duration.zero);
      expect(controller.statistics, isNotNull);
      connection.value = null;
      expect(controller.statistics, isNull);
      expect(controller.isGuest, isTrue);
      controller.dispose();
      connection.dispose();
    },
  );
  test(
    'failed refresh retains current totals and a successful retry clears error',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Repository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final initial = controller.refresh();
      repository.requests.last.complete(ActivityStatistics.empty);
      await initial;
      final refresh = controller.refresh();
      repository.requests.last.completeError(Exception('offline'));
      await refresh;
      expect(controller.statistics, same(ActivityStatistics.empty));
      expect(controller.error, isNotNull);
      expect(controller.isLoading, isFalse);
      final retry = controller.refresh();
      repository.requests.last.complete(ActivityStatistics.empty);
      await retry;
      expect(controller.error, isNull);
      controller.dispose();
      connection.dispose();
    },
  );
  test(
    'latest period wins and disposed controllers ignore late failures',
    () async {
      final connection = ValueNotifier<String?>('a');
      final repository = Repository();
      final controller = StatisticsController(
        repository: repository,
        connection: connection,
      );
      final first = controller.refresh();
      final second = controller.setQuery(
        StatisticsQuery(period: StatisticsPeriod.year),
      );
      repository.requests.first.completeError(Exception('stale'));
      await first;
      expect(controller.error, isNull);
      expect(controller.isLoading, isTrue);
      controller.dispose();
      repository.requests.last.completeError(Exception('disposed'));
      await second;
      connection.dispose();
    },
  );
}
