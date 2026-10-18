/// Calendar dates are inclusive and filter the UTC date of server start_time.
/// The selected year/month/day is sent without device timezone conversion.
class ServerActivityQuery {
  const ServerActivityQuery({
    this.search = '',
    this.activityType,
    this.startDate,
    this.endDate,
  });

  final String search;
  final int? activityType;
  final DateTime? startDate;
  final DateTime? endDate;
}
