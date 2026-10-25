import 'package:endurain/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Small "Last updated \<time\>" chip marking a cached view: a screen rendered
/// from the offline read cache while offline (ADR-0001).
///
/// Mounts wherever a controller exposes the fetch time of cached data, e.g.
/// below the activity history filters; reused by later cached screens.
class CacheLastUpdatedChip extends StatelessWidget {
  const CacheLastUpdatedChip({super.key, required this.fetchedAt});

  /// When the cached data was last fetched from the server.
  final DateTime fetchedAt;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat.yMd(locale)
        .add_Hm()
        .format(fetchedAt.toLocal());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.history,
          size: 14,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.cacheLastUpdated(formatted),
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
