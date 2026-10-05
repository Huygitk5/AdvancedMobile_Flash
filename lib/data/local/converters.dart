/// Thời gian ở SQLite là epoch milliseconds UTC (INTEGER), ở API là ISO-8601 UTC.
int? toEpoch(String? iso) =>
    iso == null ? null : DateTime.parse(iso).toUtc().millisecondsSinceEpoch;

String? toIso(int? epochMs) => epochMs == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toIso8601String();

DateTime? fromEpoch(int? epochMs) =>
    epochMs == null ? null : DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true);

/// Boolean ở SQLite là 0/1.
int boolToInt(bool v) => v ? 1 : 0;
bool intToBool(int? v) => v == 1;

/// 'YYYY-MM-DD' theo giờ ĐỊA PHƯƠNG của thiết bị (khoá `daily_statistics.stat_date`, `user_quests.period_start`).
String localDateKey(DateTime d) {
  final l = d.toLocal();
  final m = l.month.toString().padLeft(2, '0');
  final day = l.day.toString().padLeft(2, '0');
  return '${l.year}-$m-$day';
}

/// 'YYYY-MM-DD' -> DateTime địa phương lúc 00:00.
DateTime parseDateKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// Thứ Hai của tuần chứa [d] (giống `Zones.weekStart` ở server): kỳ của nhiệm vụ WEEKLY.
String weekStartKey(DateTime d) {
  final l = d.toLocal();
  return localDateKey(DateTime(l.year, l.month, l.day - (l.weekday - DateTime.monday)));
}

/// `period_start` cố định của nhiệm vụ ONE_TIME.
const oneTimePeriodKey = '1970-01-01';

/// `period_start` của nhiệm vụ theo tần suất, tính cho ngày [d].
String questPeriodKey(String frequency, DateTime d) => switch (frequency) {
      'WEEKLY' => weekStartKey(d),
      'ONE_TIME' => oneTimePeriodKey,
      _ => localDateKey(d),
    };

/// ISO-8601 UTC cho payload gửi server.
String isoNow(DateTime d) => d.toUtc().toIso8601String();
