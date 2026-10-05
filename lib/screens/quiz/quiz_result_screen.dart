import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import 'quiz_review_screen.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final List<QuizReviewItem> reviewData;
  final String title;

  const QuizResultScreen({super.key, required this.result, required this.reviewData, this.title = ''});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return trf('{m} phút {s} giây', {'m': minutes, 's': rest});
  }

  @override
  Widget build(BuildContext context) {
    final total = result.totalQuestions == 0 ? result.correctAnswers + result.wrongAnswers : result.totalQuestions;
    final passed = result.passed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: goToHome),
        title: Text(tr('Kết quả bài kiểm tra'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(passed ? Icons.emoji_events : Icons.sentiment_neutral, color: passed ? Colors.amber : AppTheme.greyColor, size: 80),
                    const SizedBox(height: 10),
                    Text('${result.correctAnswers}/$total',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                    Text('${result.scorePercent}%', style: const TextStyle(fontSize: 18, color: AppTheme.greyColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(passed ? tr('Tuyệt vời!') : tr('Cố gắng lên!'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      passed ? tr('Bạn đã vượt qua bài kiểm tra.') : tr('Hãy xem lại những câu sai rồi thử lại nhé.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                    ),
                    if (result.xpAwarded > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text('+${result.xpAwarded} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem(tr('Đúng'), '${result.correctAnswers}', Colors.green),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _statItem(tr('Sai'), '${result.wrongAnswers}', Colors.red),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          Flexible(child: _statItem(tr('Thời gian'), _formatTime(result.timeTakenSeconds), null, isTime: true)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizReviewScreen(reviewData: reviewData))),
                      child: Text(tr('Xem chi tiết'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (_) => QuizScreen(quizId: result.quizId, title: title))),
                          child: Text(tr('Làm lại'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: goToHome,
                          child: Text(tr('Về trang chủ'), style: const TextStyle(color: AppTheme.greyColor, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color? color, {bool isTime = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTime ? 14 : 22)),
      ],
    );
  }
}
