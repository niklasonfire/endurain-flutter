import 'dart:async';

import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import 'package:endurain/core/services/app_scope.dart';
import 'package:endurain/features/server_activities/controllers/server_activities_controller.dart';
import 'package:endurain/features/server_activities/models/server_activity.dart';
import 'package:endurain/features/server_activities/models/server_activity_query.dart';
import 'package:endurain/features/home/widgets/home_activity_card.dart';
import 'package:endurain/l10n/app_localizations.dart';
import 'package:endurain/shared/adaptive/adaptive.dart';
import 'package:endurain/shared/state/owned_controllers.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class ServerActivitiesScreen extends StatefulWidget {
  const ServerActivitiesScreen({
    super.key,
    this.controller,
    this.onSignIn,
    this.onOpenActivity,
  });
  final ServerActivitiesController? controller;
  final VoidCallback? onSignIn;

  /// Detail navigation seam: receives the selected server activity. The detail
  /// destination must bind its state to the active connection as this list does.
  final ValueChanged<ServerActivity>? onOpenActivity;

  @override
  State<ServerActivitiesScreen> createState() => _ServerActivitiesScreenState();
}

class _ServerActivitiesScreenState extends State<ServerActivitiesScreen>
    with OwnedControllers, WidgetsBindingObserver {
  late final ServerActivitiesController _controller;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _searchTimer;
  String? _connectionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = registerController(
      widget.controller,
      () => AppScope.servicesOf(
        context,
        listen: false,
      ).createServerActivitiesController(),
    );
    _connectionId = _controller.connectionId;
    _controller.addListener(_syncSearch);
    _scroll.addListener(_nearEnd);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    if (widget.controller == null) {
      await AppScope.servicesOf(
        context,
        listen: false,
      ).authSession.readSession();
    }
    if (mounted && !_controller.isLoading) await _controller.refresh();
  }

  void _syncSearch() {
    if (_connectionId != _controller.connectionId) {
      _connectionId = _controller.connectionId;
      _searchTimer?.cancel();
      _searchTimer = null;
      _search.clear();
    }
  }

  void _nearEnd() {
    if (_scroll.hasClients &&
        _scroll.position.extentAfter < 320 &&
        _controller.loadMoreError == null) {
      unawaited(_controller.loadMore());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_syncSearch);
    _searchTimer?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _setFilters({
    String? search,
    int? type,
    bool changeType = false,
    DateTimeRange? dates,
    bool changeDates = false,
  }) {
    final query = _controller.query;
    unawaited(
      _controller.setQuery(
        ServerActivityQuery(
          search: search ?? _search.text.trim(),
          activityType: changeType ? type : query.activityType,
          startDate: changeDates ? dates?.start : query.startDate,
          endDate: changeDates ? dates?.end : query.endDate,
        ),
      ),
    );
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _clearFilters() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _search.clear();
    unawaited(_controller.setQuery(const ServerActivityQuery()));
  }

  Future<void> _pickDates() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateUtils.dateOnly(DateTime.now());
    final query = _controller.query;
    final range = await showAdaptiveDateRangePicker(
      context: context,
      initialStart: query.startDate ?? now.subtract(const Duration(days: 30)),
      initialEnd: query.endDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10, 12, 31),
      startLabel: l10n.serverActivitiesStartDate,
      endLabel: l10n.serverActivitiesEndDate,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.ok,
    );
    if (mounted && range != null) _setFilters(dates: range, changeDates: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveScaffold(
      title: l10n.activitiesTab,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isGuest) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_run,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.serverActivitiesGuestTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.serverActivitiesGuestMessage,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AdaptiveButton(
                      onPressed: widget.onSignIn,
                      label: l10n.serverActivitiesSignIn,
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              _filters(context, l10n),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.refresh,
                  child: ListView.builder(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    scrollCacheExtent: const ScrollCacheExtent.pixels(0),
                    itemCount: _controller.items.isEmpty
                        ? 1
                        : _controller.items.length + 1,
                    itemBuilder: (context, index) {
                      if (_controller.items.isEmpty) return _emptyState(l10n);
                      if (index == _controller.items.length) {
                        return _footer(l10n);
                      }
                      final activity = _controller.items[index];
                      return HomeActivityCard(
                        key: ValueKey((
                          _controller.connectionId,
                          _controller.previewRevision,
                          activity,
                        )),
                        activity: activity,
                        loadRoute: () => _controller.loadRoute(activity.id),
                        onTap: () => widget.onOpenActivity?.call(activity),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filters(BuildContext context, AppLocalizations l10n) {
    final query = _controller.query;
    final types =
        (_controller.activityTypes.isEmpty
                ? List<int>.generate(47, (i) => i + 1)
                : _controller.activityTypes)
            .toSet();
    if (query.activityType != null) types.add(query.activityType!);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = query.startDate == null
        ? l10n.serverActivitiesDateFilter
        : '${DateFormat.yMMMd(locale).format(query.startDate!)} – ${DateFormat.yMMMd(locale).format(query.endDate ?? query.startDate!)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.serverActivitiesSearch,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              _searchTimer?.cancel();
              _searchTimer = Timer(const Duration(milliseconds: 400), () {
                _searchTimer = null;
                if (mounted && !_controller.isGuest) {
                  _setFilters(search: value.trim());
                }
              });
            },
            onSubmitted: (value) {
              _searchTimer?.cancel();
              _searchTimer = null;
              _setFilters(search: value.trim());
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: DropdownButton<int>(
                  value: query.activityType ?? 0,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(l10n.serverActivitiesAllSports),
                    ),
                    for (final type in types)
                      DropdownMenuItem(
                        value: type,
                        child: Text(
                          l10n.serverActivitySport('$type'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => _setFilters(
                    type: value == 0 ? null : value,
                    changeType: true,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _pickDates,
                icon: const Icon(Icons.date_range),
                label: Text(dateLabel),
              ),
              if (query.startDate != null)
                IconButton(
                  onPressed: () => _setFilters(changeDates: true),
                  icon: const Icon(Icons.close),
                  tooltip: l10n.serverActivitiesClearDates,
                ),
              if (_controller.hasFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.serverActivitiesClearFilters),
                ),
            ],
          ),
          Text(
            l10n.serverActivitiesNewestFirst,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_controller.isLoading && _controller.items.isNotEmpty)
            const LinearProgressIndicator(),
          if (_controller.error != null && _controller.items.isNotEmpty)
            _retry(
              l10n.serverActivitiesLoadFailed,
              () => _controller.refresh(),
              l10n,
            ),
        ],
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: _controller.isLoading
          ? const Center(child: AdaptiveLoadingIndicator())
          : _controller.error != null
          ? _retry(
              l10n.serverActivitiesLoadFailed,
              () => _controller.refresh(),
              l10n,
            )
          : Text(
              _controller.hasFilters
                  ? l10n.serverActivitiesNoMatches
                  : l10n.serverActivitiesEmpty,
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _footer(AppLocalizations l10n) {
    if (_controller.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: AdaptiveLoadingIndicator()),
      );
    }
    if (_controller.loadMoreError != null) {
      return _retry(
        l10n.serverActivitiesMoreFailed,
        _controller.loadMore,
        l10n,
      );
    }
    if (_controller.hasMore) {
      return Center(
        child: TextButton(
          onPressed: _controller.loadMore,
          child: Text(l10n.serverActivitiesLoadMore),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _retry(String message, VoidCallback onRetry, AppLocalizations l10n) =>
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            TextButton(
              onPressed: onRetry,
              child: Text(l10n.serverActivitiesRetry),
            ),
          ],
        ),
      );
}
