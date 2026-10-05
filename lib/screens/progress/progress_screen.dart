import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/daily_statistic_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common.dart';
import 'chart_data.dart';
import 'line_chart.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

/// Biểu đồ đọc `daily_statistics` từ SQLite (offline được), lọc theo khoảng bằng [Statistics.of].
class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  StatsRange _range = StatsRange.week;
  DateTimeRange? _customRange;

  void _select(StatsRange range) {
    if (range == StatsRange.custom) {
      _pickRange();
      return;
    }
    setState(() => _range = range);
  }

  Future<void> _pickRange() async {
    final today = dateOnly(Clock.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 3),
      lastDate: today,
      initialDateRange: _customRange ?? DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today),
      locale: AppLocale.locale,
      helpText: tr('Chọn khoảng ngày'),
      saveText: tr('Áp dụng'),
    );
    if (picked == null || !mounted) return;
    if (picked.end.difference(picked.start).inDays + 1 > Statistics.maxCustomDays) {
      showAppSnack(context, tr('Khoảng ngày tối đa 366 ngày'), error: true);
      return;
    }
    setState(() {
      _customRange = DateTimeRange(start: dateOnly(picked.start), end: dateOnly(picked.end));
      _range = StatsRange.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(statsRangeProvider('ALL'));
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(tr('Tiến độ'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(syncWorkerProvider).syncNow(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 100 + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(),
                if (_range == StatsRange.custom && _customRange != null) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text('${formatDate(_customRange!.start)} - ${formatDate(_customRange!.end)}',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 18),
                ...all.when(
                  loading: () => [const Padding(padding: EdgeInsets.only(top: 60), child: LoadingView())],
                  error: (e, _) => [
                    Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: ErrorView(message: trf('Không đọc được dữ liệu: {e}', {'e': e}))),
                  ],
                  data: (daily) {
                    final stats = Statistics.of(_range, daily,
                        today: Clock.now(), customFrom: _customRange?.start, customTo: _customRange?.end);
                    return [
                      _buildChartCard(stats, stats.previous(daily)),
                      const SizedBox(height: 15),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildCompletedLessonsCard()),
                            const SizedBox(width: 15),
                            Expanded(child: _buildStreakCard()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAccuracyCard(stats),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final items = <(StatsRange, String)>[
      (StatsRange.week, tr('Tuần')),
      (StatsRange.month, tr('Tháng')),
      (StatsRange.year, tr('Năm')),
      (StatsRange.all, tr('Tất cả')),
      (StatsRange.custom, tr('Tùy chọn')),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => _select(item.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: _range == item.$1 ? AppTheme.primaryColor : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: _range == item.$1 ? null : Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.$1 == StatsRange.custom) ...[
                        Icon(Icons.date_range, size: 16, color: _range == item.$1 ? Colors.white : AppTheme.greyColor),
                        const SizedBox(width: 6),
                      ],
                      Text(item.$2,
                          style: TextStyle(color: _range == item.$1 ? Colors.white : AppTheme.greyColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(Widget child, {EdgeInsets padding = const EdgeInsets.all(20)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }

  Widget _buildChartCard(Statistics stats, Statistics? previous) {
    final points = buildChartPoints(_range, stats);
    final total = points.fold<int>(0, (sum, p) => sum + p.value);
    final delta = previous == null ? null : total - previous.wordsLearned;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('Số từ đã học'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$total', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              if (delta != null)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      delta >= 0
                          ? trf('+{n} từ so với kỳ trước', {'n': delta})
                          : trf('{n} từ so với kỳ trước', {'n': delta}),
                      maxLines: 2,
                      style: TextStyle(color: delta >= 0 ? Colors.green : Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (points.every((p) => p.value == 0))
            SizedBox(
              height: 150,
              child: Center(
                child: Text(tr('Chưa có từ nào được học trong khoảng này'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
              ),
            )
          else
            WordsLineChart(points: points),
        ],
      ),
    );
  }

  Widget _buildCompletedLessonsCard() {
    final completed = ref.watch(profileProvider).value?.completedLessons ?? 0;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(tr('Bài học hoàn thành'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 11))),
          ]),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Roboto', color: Theme.of(context).textTheme.bodyLarge?.color),
              children: [
                TextSpan(
                    text: '$completed ',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                TextSpan(text: tr('bài'), style: const TextStyle(fontSize: 16, color: AppTheme.greyColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
    );
  }

  Widget _buildStreakCard() {
    final user = ref.watch(profileProvider).value;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(tr('Streak hiện tại'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12))),
          ]),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Roboto', color: Theme.of(context).textTheme.bodyLarge?.color),
              children: [
                TextSpan(
                    text: '${user?.streakDays ?? 0} ',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                TextSpan(text: tr('ngày'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
    );
  }

  Widget _buildAccuracyCard(Statistics stats) {
    final accuracy = stats.accuracy;
    final longest = ref.watch(profileProvider).value?.longestStreak ?? 0;
    return _card(
      Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
                value: (accuracy ?? 0).clamp(0.0, 1.0), strokeWidth: 8, backgroundColor: Colors.green.shade50, color: Colors.green.shade400),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Độ chính xác (Quiz)'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                const SizedBox(height: 5),
                Text(accuracy == null ? '—' : '${(accuracy * 100).round()}%',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                Text(trf('Streak dài nhất: {n} ngày', {'n': longest}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
