import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        title: const Text('Thử thách', style: TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
        automaticallyImplyLeading: false, // Ẩn nút back vì đây là màn hình chính
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Thẻ tổng quan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3366FF), Color(0xFF5A85FF)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 50),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Nhiệm vụ hàng ngày', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Hoàn thành để nhận thêm XP', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Danh sách nhiệm vụ
          const Text('Nhiệm vụ hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildQuestItem(Icons.style, 'Học 20 Flashcard mới', 12, 20, 50),
          _buildQuestItem(Icons.fact_check, 'Đạt 100% 1 bài kiểm tra', 0, 1, 100),
          _buildQuestItem(Icons.local_fire_department, 'Duy trì Streak', 1, 1, 20, isCompleted: true),
        ],
      ),
    );
  }

  // Widget hiển thị từng thẻ nhiệm vụ
  Widget _buildQuestItem(IconData icon, String title, int current, int target, int xp, {bool isCompleted = false}) {
    double progress = current / target;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isCompleted ? Colors.green : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 5),
                Text('+$xp XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: isCompleted ? Colors.green : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : Text('$current/$target', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor)),
        ],
      ),
    );
  }
}