import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../../models/daily_statistic_model.dart';

/// Một điểm của biểu đồ "Số từ đã học".
class ChartPoint {
  /// Nhãn ngắn dưới trục hoành (VD: T2, 05/10, T10).
  final String label;

  /// Mô tả đầy đủ mốc thời gian, hiện khi chạm vào điểm (VD: 05/10/2026, 10/2026).
  final String when;
  final int value;

  const ChartPoint({required this.label, required this.when, required this.value});
}

String _two(int n) => n.toString().padLeft(2, '0');

String _weekdayLabel(DateTime d) {
  const vi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return (AppLocale.isEnglish ? en : vi)[d.weekday - 1];
}

String _monthLabel(DateTime d) => AppLocale.isEnglish ? '${_two(d.month)}/${d.year % 100}' : 'T${d.month}';

/// Chuyển thống kê (dựng từ `daily_statistics` local) thành các điểm biểu đồ theo khoảng đang chọn:
/// Tuần / Tháng / Khoảng ngắn theo ngày, Năm / Tất cả theo tháng, khoảng dài tuỳ chọn theo tuần hoặc tháng.
List<ChartPoint> buildChartPoints(StatsRange range, Statistics stats) {
  final byDate = <DateTime, int>{for (final d in stats.daily) dateOnly(d.date): d.wordsLearned};
  final from = dateOnly(stats.from);
  final to = dateOnly(stats.to);

  switch (range) {
    case StatsRange.week:
      return _daily(byDate, from, to, (d) => _weekdayLabel(d));
    case StatsRange.month:
      return _daily(byDate, from, to, (d) => '${_two(d.day)}/${_two(d.month)}');
    case StatsRange.year:
      return _monthly(byDate, DateTime(to.year, to.month - 11, 1), to);
    case StatsRange.all:
      if (byDate.isEmpty) return _monthly(byDate, DateTime(to.year, to.month, 1), to);
      return _monthly(byDate, DateTime(from.year, from.month, 1), to);
    case StatsRange.custom:
      final days = to.difference(from).inDays + 1;
      if (days <= 31) return _daily(byDate, from, to, (d) => '${_two(d.day)}/${_two(d.month)}');
      if (days <= 120) return _weekly(byDate, from, to);
      return _monthly(byDate, DateTime(from.year, from.month, 1), to);
  }
}

List<ChartPoint> _daily(Map<DateTime, int> byDate, DateTime from, DateTime to, String Function(DateTime) label) {
  final points = <ChartPoint>[];
  // Cộng ngày bằng DateTime(y, m, d + 1) thay vì Duration để không lệch giờ khi qua ngày đổi giờ
  for (var d = from; !d.isAfter(to); d = DateTime(d.year, d.month, d.day + 1)) {
    points.add(ChartPoint(label: label(d), when: formatDate(d), value: byDate[d] ?? 0));
  }
  return points;
}

List<ChartPoint> _weekly(Map<DateTime, int> byDate, DateTime from, DateTime to) {
  final points = <ChartPoint>[];
  for (var start = from; !start.isAfter(to); start = DateTime(start.year, start.month, start.day + 7)) {
    var end = DateTime(start.year, start.month, start.day + 6);
    if (end.isAfter(to)) end = to;
    var sum = 0;
    for (var d = start; !d.isAfter(end); d = DateTime(d.year, d.month, d.day + 1)) {
      sum += byDate[d] ?? 0;
    }
    points.add(ChartPoint(
      label: '${_two(start.day)}/${_two(start.month)}',
      when: '${formatDate(start)} - ${formatDate(end)}',
      value: sum,
    ));
  }
  return points;
}

List<ChartPoint> _monthly(Map<DateTime, int> byDate, DateTime firstMonth, DateTime to) {
  final sums = <DateTime, int>{};
  byDate.forEach((date, value) {
    final key = DateTime(date.year, date.month, 1);
    sums[key] = (sums[key] ?? 0) + value;
  });
  final points = <ChartPoint>[];
  for (var m = DateTime(firstMonth.year, firstMonth.month, 1); !m.isAfter(to); m = DateTime(m.year, m.month + 1, 1)) {
    points.add(ChartPoint(label: _monthLabel(m), when: '${_two(m.month)}/${m.year}', value: sums[m] ?? 0));
  }
  return points;
}

/// Giá trị trục tung "đẹp" (chia hết cho 4 khoảng) phủ được [maxValue].
({int step, int top}) yAxisScale(int maxValue) {
  if (maxValue <= 4) return (step: 1, top: 4);
  final raw = (maxValue / 4).ceil();
  var magnitude = 1;
  while (magnitude * 10 <= raw) {
    magnitude *= 10;
  }
  const nice = [1, 2, 5, 10];
  var step = magnitude * 10;
  for (final n in nice) {
    if (n * magnitude >= raw) {
      step = n * magnitude;
      break;
    }
  }
  return (step: step, top: step * 4);
}
