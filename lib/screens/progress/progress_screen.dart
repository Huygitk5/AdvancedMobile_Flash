import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../models/daily_statistic_model.dart';
import '../../providers/user_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

/// Biểu đồ đọc `daily_statistics` từ SQLite (offline được); ngày trống điền 0.
class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String selectedFilter = 'Tất cả';
  final List<String> filters = ['Tất cả', 'Tuần', 'Tháng'];

  List<DailyStatistic> _all = const [];

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// [days] ngày kết thúc ở [end] (gồm cả [end]), điền 0 cho ngày không có dòng.
  List<DailyStatistic> _range(DateTime end, int days) {
    final byDay = {for (final s in _all) _day(s.date): s};
    return List.generate(days, (i) {
      final d = _day(end).subtract(Duration(days: days - 1 - i));
      return byDay[d] ?? DailyStatistic(date: d);
    });
  }

  /// "Tất cả": gộp theo tháng, tối đa 12 tháng gần nhất.
  List<DailyStatistic> _monthly() {
    final now = Clock.now();
    return List.generate(12, (i) {
      final m = DateTime(now.year, now.month - 11 + i);
      final inMonth = _all.where((s) => s.date.year == m.year && s.date.month == m.month);
      return DailyStatistic(
        date: m,
        wordsLearned: inMonth.fold(0, (a, s) => a + s.wordsLearned),
        correctAnswers: inMonth.fold(0, (a, s) => a + s.correctAnswers),
        totalAnswers: inMonth.fold(0, (a, s) => a + s.totalAnswers),
      );
    });
  }

  List<DailyStatistic> get currentChartData {
    final today = Clock.now();
    if (selectedFilter == 'Tuần') return _range(today, 7);
    if (selectedFilter == 'Tháng') return _range(today, 30);
    return _monthly();
  }

  /// Cùng độ dài, ngay trước kỳ hiện tại (để so sánh "+N từ so với kỳ trước").
  List<DailyStatistic> get previousPeriod {
    final today = Clock.now();
    if (selectedFilter == 'Tuần') return _range(today.subtract(const Duration(days: 7)), 7);
    if (selectedFilter == 'Tháng') return _range(today.subtract(const Duration(days: 30)), 30);
    return const [];
  }

  int get totalWordsLearned => (selectedFilter == 'Tất cả' ? _all : currentChartData).fold(0, (sum, item) => sum + item.wordsLearned);

  /// accuracy = Σ correct_answers / Σ total_answers (chỉ tính câu trả lời quiz).
  double? get accuracy {
    final data = selectedFilter == 'Tất cả' ? _all : currentChartData;
    final total = data.fold(0, (a, s) => a + s.totalAnswers);
    if (total == 0) return null;
    return data.fold(0, (a, s) => a + s.correctAnswers) / total;
  }

  @override
  Widget build(BuildContext context) {
    _all = ref.watch(statsRangeProvider('ALL')).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Tiến độ', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              _buildFilters(),
              const SizedBox(height: 20),
              _buildChartCard(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildCompletedLessonsCard()),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStreakCard()),
                ],
              ),
              const SizedBox(height: 15),
              _buildAccuracyCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: filters.map((filter) {
        bool isActive = selectedFilter == filter;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              margin: EdgeInsets.only(right: filter != 'Tháng' ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [] : [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(color: isActive ? Colors.white : AppTheme.greyColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số từ đã học', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Hiển thị số động theo bộ lọc
              Text('$totalWordsLearned', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, )),
              const SizedBox(width: 10),
              if (selectedFilter != 'Tất cả')
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Builder(builder: (context) {
                    final diff = totalWordsLearned - previousPeriod.fold(0, (a, s) => a + s.wordsLearned);
                    return Text('${diff >= 0 ? '+' : ''}$diff từ so với kỳ trước',
                        style: TextStyle(color: diff >= 0 ? Colors.green : Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12));
                  }),
                ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 120, width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(stats: currentChartData), // Truyền dữ liệu động
            ),
          ),
          const SizedBox(height: 10),
          _buildChartXLabels(),
        ],
      ),
    );
  }

  Widget _buildChartXLabels() {
    const weekday = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final data = currentChartData;
    List<String> labels;
    if (selectedFilter == 'Tuần') {
      labels = data.map((s) => weekday[s.date.weekday - 1]).toList();
    } else if (selectedFilter == 'Tháng') {
      labels = [0, 9, 19, 29].map((i) => '${data[i].date.day}/${data[i].date.month}').toList();
    } else {
      labels = [0, 3, 7, 11].map((i) => 'T${data[i].date.month}').toList();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((l) => Text(l, style: TextStyle(color: AppTheme.greyColor, fontSize: 12))).toList(),
    );
  }

  Widget _buildCompletedLessonsCard() {
    final completed = ref.watch(profileProvider).value?.completedLessons ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 20)), const SizedBox(width: 8), const Expanded(child: Text('Bài học hoàn thành', style: TextStyle(color: AppTheme.greyColor, fontSize: 11)))]),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '$completed ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                TextSpan(text: 'bài', style: TextStyle(fontSize: 16, color: AppTheme.greyColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final user = ref.watch(profileProvider).value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(Icons.local_fire_department, color: Colors.orange, size: 28), SizedBox(width: 8), Expanded(child: Text('Streak hiện tại', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)))]),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '${user?.streakDays ?? 0} ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                TextSpan(text: 'ngày', style: TextStyle(fontSize: 16,  fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          SizedBox(
            width: 60, height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [CircularProgressIndicator(value: accuracy ?? 0, strokeWidth: 8, backgroundColor: Colors.green.shade50, color: Colors.green.shade400)],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Độ chính xác (Quiz)', style: TextStyle(color: AppTheme.greyColor, fontSize: 13)),
              const SizedBox(height: 5),
              Text(accuracy == null ? '—' : '${(accuracy! * 100).round()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              Text('Streak dài nhất: ${ref.watch(profileProvider).value?.longestStreak ?? 0} ngày',
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<DailyStatistic> stats;
  LineChartPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;
    final paintLine = Paint()..color = AppTheme.primaryColor..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    int maxWords = stats.map((s) => s.wordsLearned).fold(0, (prev, amount) => max(prev, amount));
    if (maxWords == 0) maxWords = 1;

    List<Offset> points = [];
    for (int i = 0; i < stats.length; i++) {
      double x = stats.length == 1 ? size.width / 2 : i * (size.width / (stats.length - 1));
      double y = size.height - (stats[i].wordsLearned / maxWords) * (size.height * 0.8);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    final gradientPaint = Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primaryColor.withValues(alpha: 0.3), AppTheme.primaryColor.withValues(alpha: 0.0)])
          .createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paintLine);

    final dotPaint = Paint()..color = AppTheme.primaryColor..style = PaintingStyle.fill;
    final dotBgPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    // Chỉ vẽ chấm tròn nếu số điểm ít (Tuần hoặc Tất cả) để tránh rối mắt cho Tháng
    if (stats.length <= 12) {
      for (var point in points) {
        canvas.drawCircle(point, 5, dotBgPaint);
        canvas.drawCircle(point, 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}