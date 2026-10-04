import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'dart:math';
import '../../data/mock_data.dart';
import '../../models/daily_statistic_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Thay đổi thứ tự theo yêu cầu
  String selectedFilter = 'Tất cả';
  final List<String> filters = ['Tất cả', 'Tuần', 'Tháng'];

  // Tạo dữ liệu giả lập cho Tháng và Tất cả để biểu đồ có thể thay đổi
  late List<DailyStatistic> weekData;
  late List<DailyStatistic> monthData;
  late List<DailyStatistic> allData;

  @override
  void initState() {
    super.initState();
    weekData = MockData.weeklyStats;

    // Tạo 30 điểm dữ liệu cho Tháng
    monthData = List.generate(30, (i) => DailyStatistic(
      id: 'm$i', userId: 'u1', date: DateTime.now().subtract(Duration(days: 29 - i)),
      wordsLearned: Random().nextInt(40) + 10, xpGained: 0,
    ));

    // Tạo 12 điểm dữ liệu cho Tất cả (tượng trưng cho 12 tháng)
    allData = List.generate(12, (i) => DailyStatistic(
      id: 'a$i', userId: 'u1', date: DateTime.now().subtract(Duration(days: (11 - i) * 30)),
      wordsLearned: Random().nextInt(200) + 50, xpGained: 0,
    ));
  }

  // Hàm lấy dữ liệu theo Filter
  List<DailyStatistic> get currentChartData {
    if (selectedFilter == 'Tuần') return weekData;
    if (selectedFilter == 'Tháng') return monthData;
    return allData;
  }

  // Hàm tính tổng từ vựng theo Filter để cập nhật con số to
  int get totalWordsLearned {
    return currentChartData.fold(0, (sum, item) => sum + item.wordsLearned);
  }

  @override
  Widget build(BuildContext context) {
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
                boxShadow: isActive ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
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
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('+12 từ so với kỳ trước', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
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
    List<String> labels = [];
    if (selectedFilter == 'Tuần') labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    else if (selectedFilter == 'Tháng') labels = ['1', '10', '20', '30'];
    else labels = ['T1', 'T4', 'T8', 'T12']; // Tất cả

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((l) => Text(l, style: TextStyle(color: AppTheme.greyColor, fontSize: 12))).toList(),
    );
  }

  Widget _buildCompletedLessonsCard() {
    final user = MockData.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 20)), const SizedBox(width: 8), const Expanded(child: Text('Bài học hoàn thành', style: TextStyle(color: AppTheme.greyColor, fontSize: 11)))]),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '${user.completedLessons} ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                TextSpan(text: 'bài', style: TextStyle(fontSize: 16, color: AppTheme.greyColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final user = MockData.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(Icons.local_fire_department, color: Colors.orange, size: 28), SizedBox(width: 8), Expanded(child: Text('Streak hiện tại', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)))]),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '${user.streakDays} ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          SizedBox(
            width: 60, height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [CircularProgressIndicator(value: 0.85, strokeWidth: 8, backgroundColor: Colors.green.shade50, color: Colors.green.shade400)],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Độ chính xác (Quiz)', style: TextStyle(color: AppTheme.greyColor, fontSize: 13)),
              SizedBox(height: 5),
              Text('85%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, )),
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
      double x = i * (size.width / (stats.length - 1));
      double y = size.height - (stats[i].wordsLearned / maxWords) * (size.height * 0.8);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) path.lineTo(points[i].dx, points[i].dy);

    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    final gradientPaint = Paint()
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primaryColor.withOpacity(0.3), AppTheme.primaryColor.withOpacity(0.0)])
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