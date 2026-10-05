import '../core/utils.dart';
import '../models/daily_statistic_model.dart';
import '../models/lesson_model.dart';
import '../models/json_helpers.dart';
import 'api/api_client.dart';
import 'app_state.dart';

/// Các khoảng thời gian của biểu đồ Tiến độ.
enum StatsRange { week, month, year, all, custom }

class ProgressRepository {
  ProgressRepository._();

  static ApiClient get _api => ApiClient.I;

  static Future<HomeSummary> home() async {
    final summary = HomeSummary.fromJson(asMap(await _api.get('/v1/home/summary')));
    return summary;
  }

  static String _rangeName(StatsRange r) => r.name.toUpperCase();

  static Future<Statistics> statistics(StatsRange range, {DateTime? from, DateTime? to}) async {
    final data = await _api.get('/v1/users/me/statistics', query: {
      'range': _rangeName(range),
      if (range == StatsRange.custom && from != null) 'from': apiDate(from),
      if (range == StatsRange.custom && to != null) 'to': apiDate(to),
    });
    return Statistics.fromJson(asMap(data));
  }

  /// Thống kê của kỳ liền trước có cùng độ dài (để so sánh "+N từ so với kỳ trước"). null nếu không so sánh được.
  static Future<Statistics?> previousPeriod(Statistics current) async {
    if (current.range == 'ALL' || current.range == 'YEAR') return null;
    final days = current.to.difference(current.from).inDays + 1;
    if (days <= 0 || days > 366) return null;
    final prevTo = current.from.subtract(const Duration(days: 1));
    final prevFrom = prevTo.subtract(Duration(days: days - 1));
    return statistics(StatsRange.custom, from: prevFrom, to: prevTo);
  }

  /// Làm mới hồ sơ (XP, streak...) kèm trang chủ.
  static Future<void> refreshUser() => AppState.I.refreshAll();
}
