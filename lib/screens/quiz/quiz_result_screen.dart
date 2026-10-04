import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/quiz_result_model.dart';
import '../../models/quiz_review_model.dart'; // THÊM IMPORT NÀY
import 'quiz_review_screen.dart'; // Import màn hình mới

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final List<QuizReviewItem> reviewData;

  const QuizResultScreen({Key? key, required this.result, required this.reviewData}) : super(key: key);

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes phút $remainingSeconds giây';
  }

  @override
  Widget build(BuildContext context) {
    int totalQuestions = result.correctAnswers + result.wrongAnswers;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, ),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text('Kết quả bài kiểm tra', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 80),
                    const SizedBox(height: 10),
                    Text('${result.correctAnswers}/$totalQuestions', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                    Text('Tuyệt vời!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, )),
                    const SizedBox(height: 5),
                    Text('Bạn đã hoàn thành bài kiểm tra.', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Đúng', '${result.correctAnswers}', Colors.green),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          _buildStatItem('Sai', '${result.wrongAnswers}', Colors.red),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          _buildStatItem('Thời gian', _formatTime(result.timeTakenSeconds), const Color(0xFF1E293B), isTime: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizReviewScreen(result: result, reviewData: reviewData)), // TRUYỀN DỮ LIỆU ĐI TIẾP
                    );
                  },
                  child: Text('Xem chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, {bool isTime = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTime ? 14 : 22)),
      ],
    );
  }
}