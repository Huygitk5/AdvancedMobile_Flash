class DailyStatistic {
  /// Ngày theo giờ địa phương (00:00).
  final DateTime date;
  final int wordsLearned;
  final int cardsReviewed;
  final int xpGained;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int correctAnswers;
  final int totalAnswers;
  final int studySeconds;

  const DailyStatistic({
    required this.date,
    this.wordsLearned = 0,
    this.cardsReviewed = 0,
    this.xpGained = 0,
    this.lessonsCompleted = 0,
    this.quizzesCompleted = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.studySeconds = 0,
  });
}

/// Các khoảng thời gian của biểu đồ Tiến độ (khớp `StatsRange` của server).
enum StatsRange { week, month, year, all, custom }

/// Thống kê của một khoảng ngày [from]..[to] (gồm cả hai đầu), dựng từ `daily_statistics` local
/// theo đúng quy tắc của `/v1/users/me/statistics`: WEEK/MONTH 7/30 ngày gần nhất, YEAR 365 ngày,
/// ALL từ ngày học đầu tiên, CUSTOM theo khoảng người dùng chọn (tối đa [maxCustomDays] ngày).
class Statistics {
  /// 'WEEK' | 'MONTH' | 'YEAR' | 'ALL' | 'CUSTOM'
  final String range;
  final DateTime from;
  final DateTime to;

  /// Chỉ các ngày có dòng dữ liệu (ngày trống do biểu đồ điền 0).
  final List<DailyStatistic> daily;

  const Statistics({required this.range, required this.from, required this.to, required this.daily});

  static const maxCustomDays = 366;

  int get wordsLearned => daily.fold(0, (a, s) => a + s.wordsLearned);
  int get xpGained => daily.fold(0, (a, s) => a + s.xpGained);
  int get correctAnswers => daily.fold(0, (a, s) => a + s.correctAnswers);
  int get totalAnswers => daily.fold(0, (a, s) => a + s.totalAnswers);

  /// correct / total câu trả lời quiz trong khoảng; null khi chưa làm câu nào.
  double? get accuracy => totalAnswers == 0 ? null : correctAnswers / totalAnswers;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Lọc [all] (mọi ngày có dữ liệu, tăng dần) theo [range]. [customFrom]/[customTo] bắt buộc với CUSTOM.
  factory Statistics.of(
    StatsRange range,
    List<DailyStatistic> all, {
    required DateTime today,
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    final to = _day(range == StatsRange.custom ? customTo! : today);
    final DateTime from = switch (range) {
      StatsRange.week => DateTime(to.year, to.month, to.day - 6),
      StatsRange.month => DateTime(to.year, to.month, to.day - 29),
      StatsRange.year => DateTime(to.year, to.month, to.day - 364),
      StatsRange.all => all.isEmpty ? to : _day(all.first.date),
      StatsRange.custom => _day(customFrom!),
    };
    return Statistics(
      range: range.name.toUpperCase(),
      from: from,
      to: to,
      daily: [
        for (final s in all)
          if (!_day(s.date).isBefore(from) && !_day(s.date).isAfter(to)) s,
      ],
    );
  }

  /// Kỳ liền trước có cùng độ dài (để so sánh "+N từ so với kỳ trước"); null với YEAR / ALL.
  Statistics? previous(List<DailyStatistic> all) {
    if (range == 'ALL' || range == 'YEAR') return null;
    final days = _day(to).difference(_day(from)).inDays + 1;
    if (days <= 0 || days > maxCustomDays) return null;
    final prevTo = DateTime(from.year, from.month, from.day - 1);
    final prevFrom = DateTime(prevTo.year, prevTo.month, prevTo.day - (days - 1));
    return Statistics.of(StatsRange.custom, all, today: prevTo, customFrom: prevFrom, customTo: prevTo);
  }
}
