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
  String selectedFilter = 'Tuần';
  final List<String> filters = ['Tuần', 'Tháng', 'Tất cả'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Nền xám nhạt đồng bộ
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        title: const Text(
          'Tiến độ học tập',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false, // Bỏ nút back vì đây là màn hình chính
      ),
      body: SafeArea(
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

  // 1. Bộ lọc thời gian (Tuần, Tháng, Tất cả)
  Widget _buildFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: filters.map((filter) {
        bool isActive = selectedFilter == filter;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              margin: EdgeInsets.only(right: filter != 'Tất cả' ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.greyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 2. Thẻ biểu đồ chính (Số từ đã học)
  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Số từ đã học', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('248', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              SizedBox(width: 10),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('+12 từ so với tuần trước', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Khu vực vẽ biểu đồ (CustomPaint)
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(stats: MockData.weeklyStats), // Truyền dữ liệu vào
            ),
          ),
          const SizedBox(height: 10),

          // Trục X (Các thứ trong tuần)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('T2', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              Text('T3', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              Text('T4', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              Text('T5', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              Text('T6', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              Text('T7', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              Text('CN', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  // 3. Thẻ Bài học hoàn thành
  Widget _buildCompletedLessonsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Bài học hoàn thành', style: TextStyle(color: AppTheme.greyColor, fontSize: 11))),
            ],
          ),
          const SizedBox(height: 15),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '18 ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                TextSpan(text: '/ 30', style: TextStyle(fontSize: 16, color: AppTheme.greyColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Thẻ Streak hiện tại
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Streak hiện tại', style: TextStyle(color: AppTheme.greyColor, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 15),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '7 ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                TextSpan(text: 'ngày', style: TextStyle(fontSize: 16, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Thẻ Độ chính xác
  Widget _buildAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Vòng tròn phần trăm
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 8,
                  backgroundColor: Colors.green.shade50,
                  color: Colors.green.shade400,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Độ chính xác (Quiz)', style: TextStyle(color: AppTheme.greyColor, fontSize: 13)),
              SizedBox(height: 5),
              Text('85%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          )
        ],
      ),
    );
  }
}

// Lớp vẽ biểu đồ giả lập dữ liệu theo thiết kế
class LineChartPainter extends CustomPainter {
  final List<DailyStatistic> stats;

  LineChartPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    final paintLine = Paint()..color = AppTheme.primaryColor..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Tìm giá trị lớn nhất để lấy tỷ lệ vẽ (Scaling)
    int maxWords = stats.map((s) => s.wordsLearned).fold(0, (prev, amount) => max(prev, amount));
    if (maxWords == 0) maxWords = 1; // Tránh chia cho 0

    List<Offset> points = [];
    for (int i = 0; i < stats.length; i++) {
      // Chia đều không gian X cho số lượng ngày (7 ngày)
      double x = i * (size.width / (stats.length - 1));
      // Tính Y dựa trên tỷ lệ % của ngày đó so với ngày cao nhất (chừa 20% lề trên)
      double y = size.height - (stats[i].wordsLearned / maxWords) * (size.height * 0.8);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy); // Vẽ các đoạn thẳng nối lại
    }

    final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [AppTheme.primaryColor.withOpacity(0.3), AppTheme.primaryColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paintLine);

    final dotPaint = Paint()..color = AppTheme.primaryColor..style = PaintingStyle.fill;
    final dotBgPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    for (var point in points) {
      canvas.drawCircle(point, 5, dotBgPaint);
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Cập nhật khi data đổi
}