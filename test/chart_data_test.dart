import 'package:flash/core/l10n.dart';
import 'package:flash/data/progress_repository.dart';
import 'package:flash/models/daily_statistic_model.dart';
import 'package:flash/screens/progress/chart_data.dart';
import 'package:flutter_test/flutter_test.dart';

Statistics stats(String range, DateTime from, DateTime to, Map<DateTime, int> words) => Statistics(
      range: range,
      from: from,
      to: to,
      daily: [for (final e in words.entries) DailyStatistic(date: e.key, wordsLearned: e.value)],
    );

void main() {
  setUp(() => AppLocale.language.value = 'vi');

  group('yAxisScale', () {
    test('giá trị nhỏ dùng bước 1, tối thiểu 4 vạch', () {
      expect(yAxisScale(0), (step: 1, top: 4));
      expect(yAxisScale(3), (step: 1, top: 4));
      expect(yAxisScale(4), (step: 1, top: 4));
    });

    test('luôn phủ được giá trị lớn nhất và chia hết cho 4 khoảng', () {
      for (final max in [5, 7, 9, 13, 40, 41, 87, 99, 120, 250, 999, 1234, 5000, 98765]) {
        final s = yAxisScale(max);
        expect(s.top, greaterThanOrEqualTo(max), reason: 'max=$max');
        expect(s.top, s.step * 4);
        expect([1, 2, 5].contains(s.step ~/ _magnitude(s.step)), isTrue, reason: 'bước ${s.step} phải là 1/2/5 x 10^k');
      }
    });
  });

  group('buildChartPoints', () {
    test('Tuần: 7 điểm theo ngày, nhãn T2..CN, ngày không học bằng 0', () {
      final from = DateTime(2026, 9, 29); // Thứ Ba
      final to = DateTime(2026, 10, 5); // Thứ Hai
      final points = buildChartPoints(StatsRange.week, stats('WEEK', from, to, {DateTime(2026, 10, 1): 12, DateTime(2026, 10, 5): 30}));
      expect(points, hasLength(7));
      expect(points.map((p) => p.label), ['T3', 'T4', 'T5', 'T6', 'T7', 'CN', 'T2']);
      expect(points.map((p) => p.value), [0, 0, 12, 0, 0, 0, 30]);
      expect(points[2].when, '01/10/2026');
    });

    test('Tuần bằng English dùng tên thứ tiếng Anh', () {
      AppLocale.language.value = 'en';
      final points = buildChartPoints(StatsRange.week, stats('WEEK', DateTime(2026, 9, 29), DateTime(2026, 10, 5), {}));
      expect(points.first.label, 'Tue');
    });

    test('Tháng: 30 điểm theo ngày', () {
      final to = DateTime(2026, 10, 5);
      final from = DateTime(2026, 9, 6);
      final points = buildChartPoints(StatsRange.month, stats('MONTH', from, to, {to: 5}));
      expect(points, hasLength(30));
      expect(points.first.label, '06/09');
      expect(points.last.value, 5);
    });

    test('Năm: 12 điểm theo tháng, cộng dồn các ngày trong cùng tháng', () {
      final to = DateTime(2026, 10, 5);
      final points = buildChartPoints(
        StatsRange.year,
        stats('YEAR', DateTime(2025, 10, 7), to, {
          DateTime(2026, 10, 1): 10,
          DateTime(2026, 10, 4): 5,
          DateTime(2026, 8, 20): 7,
          DateTime(2025, 11, 2): 3,
        }),
      );
      expect(points, hasLength(12));
      expect(points.first.when, '11/2025');
      expect(points.last.when, '10/2026');
      expect(points.last.value, 15);
      expect(points.firstWhere((p) => p.when == '08/2026').value, 7);
      expect(points.first.value, 3);
      expect(points.map((p) => p.value).reduce((a, b) => a + b), 25);
    });

    test('Tất cả: theo tháng từ tháng học đầu tiên đến nay', () {
      final points = buildChartPoints(
        StatsRange.all,
        stats('ALL', DateTime(2026, 7, 15), DateTime(2026, 10, 5), {DateTime(2026, 7, 15): 4, DateTime(2026, 9, 1): 6}),
      );
      expect(points.map((p) => p.when), ['07/2026', '08/2026', '09/2026', '10/2026']);
      expect(points.map((p) => p.value), [4, 0, 6, 0]);
    });

    test('Tất cả khi chưa có dữ liệu vẫn trả đúng 1 điểm (tháng hiện tại)', () {
      final points = buildChartPoints(StatsRange.all, stats('ALL', DateTime(2026, 10, 5), DateTime(2026, 10, 5), {}));
      expect(points, hasLength(1));
      expect(points.single.value, 0);
    });

    test('Tùy chọn ngắn (<= 31 ngày): từng ngày', () {
      final points = buildChartPoints(StatsRange.custom, stats('CUSTOM', DateTime(2026, 9, 26), DateTime(2026, 10, 5), {DateTime(2026, 9, 30): 8}));
      expect(points, hasLength(10));
      expect(points[4].when, '30/09/2026');
      expect(points[4].value, 8);
    });

    test('Tùy chọn trung bình (<= 120 ngày): gom theo tuần, tổng được giữ nguyên', () {
      final from = DateTime(2026, 6, 1);
      final to = DateTime(2026, 8, 30); // 91 ngày
      final words = {DateTime(2026, 6, 2): 5, DateTime(2026, 6, 9): 6, DateTime(2026, 8, 30): 9};
      final points = buildChartPoints(StatsRange.custom, stats('CUSTOM', from, to, words));
      expect(points, hasLength(13));
      expect(points.first.when, '01/06/2026 - 07/06/2026');
      expect(points.last.when, '24/08/2026 - 30/08/2026');
      expect(points.map((p) => p.value).reduce((a, b) => a + b), 20);
    });

    test('Tùy chọn dài (> 120 ngày): gom theo tháng', () {
      final points = buildChartPoints(StatsRange.custom, stats('CUSTOM', DateTime(2026, 1, 10), DateTime(2026, 10, 5), {DateTime(2026, 3, 3): 11}));
      expect(points, hasLength(10));
      expect(points[2].when, '03/2026');
      expect(points[2].value, 11);
    });

    test('Cộng ngày không lệch khi qua ngày đổi giờ mùa hè', () {
      final points = buildChartPoints(StatsRange.custom, stats('CUSTOM', DateTime(2026, 3, 25), DateTime(2026, 4, 2), {}));
      expect(points.map((p) => p.when).toList(), [for (var d = 25; d <= 31; d++) '$d/03/2026', '01/04/2026', '02/04/2026']);
    });
  });
}

int _magnitude(int step) {
  var m = 1;
  while (m * 10 <= step) {
    m *= 10;
  }
  return m;
}
