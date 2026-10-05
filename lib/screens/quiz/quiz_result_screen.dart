import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/quiz_result_model.dart';
import '../../providers/content_providers.dart';
import 'quiz_review_screen.dart';

/// Watch dòng `quiz_attempts`: tự cập nhật khi server chấm lại (`xp_awarded`).
class QuizResultScreen extends ConsumerWidget {
  final String attemptId;

  const QuizResultScreen({super.key, required this.attemptId});

  String _formatTime(int seconds) => '${seconds ~/ 60} phút ${seconds % 60} giây';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(quizAttemptProvider(attemptId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text('Kết quả bài kiểm tra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: attempt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không đọc được kết quả: $e')),
        data: (result) => result == null ? _rejected(context) : _buildResult(context, result),
      ),
    );
  }

  /// Bài bị server từ chối khi đồng bộ (VD đề đã được admin sửa lúc offline): dòng attempt đã bị xoá.
  Widget _rejected(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 70),
            const SizedBox(height: 16),
            const Text('Bài làm không được ghi nhận', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Đề đã được cập nhật, hãy làm lại bài kiểm tra.',
                textAlign: TextAlign.center, style: TextStyle(color: AppTheme.greyColor)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Về trang chủ'),
            ),
          ]),
        ),
      );

  Widget _buildResult(BuildContext context, QuizResult result) {
    final pending = result.xpAwarded == null;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(result.passed ? Icons.emoji_events : Icons.sentiment_neutral,
                      color: result.passed ? Colors.amber : AppTheme.greyColor, size: 80),
                  const SizedBox(height: 10),
                  Text('${result.correctAnswers}/${result.totalQuestions}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                  Text(result.passed ? 'Tuyệt vời!' : 'Cố gắng thêm nhé!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('${result.quizTitle.isEmpty ? 'Bạn đã hoàn thành bài kiểm tra.' : result.quizTitle} • ${result.scorePercent}%',
                      textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: pending ? Colors.grey.shade200 : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(pending ? Icons.cloud_upload_outlined : Icons.stars,
                          size: 16, color: pending ? AppTheme.greyColor : Colors.amber.shade800),
                      const SizedBox(width: 6),
                      Text(pending ? 'Đang chờ đồng bộ' : '+${result.xpAwarded} XP',
                          style: TextStyle(fontWeight: FontWeight.bold, color: pending ? AppTheme.greyColor : Colors.amber.shade800)),
                    ]),
                  ),
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizReviewScreen(attemptId: result.id)),
                ),
                child: Text('Xem chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, {bool isTime = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTime ? 14 : 22)),
      ],
    );
  }
}
