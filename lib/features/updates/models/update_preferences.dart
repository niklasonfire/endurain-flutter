import 'package:endurain/features/updates/models/update_release.dart';

class UpdatePreferences {
  const UpdatePreferences({required this.channel, this.lastChecked});
  final UpdateChannel channel;
  final DateTime? lastChecked;
}
