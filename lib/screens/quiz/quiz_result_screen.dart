import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/quiz_result_model.dart';
import '../../providers/content_providers.dart';
import '../../widgets/common.dart';
import 'quiz_review_screen.dart';
import 'quiz_screen.dart';

/// Watch dòng `quiz_attempts`: tự cập nhật khi server chấm lại (`xp_awarded`).
class QuizResultScreen extends ConsumerWidget {
  final String attemptId;

  /// Tên hiển thị khi bấm "Làm lại".
  final String title;

  const QuizResultScreen({super.key, required this.attemptId, this.title = ''});

  String _formatTime(int seconds) => trf('{m} phút {s} giây', {'m': seconds ~/ 60, 's': seconds % 60});

  void _goHome(BuildContext context) => Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(quizAttemptProvider(attemptId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _goHome(context)),
        title: Text(tr('Kết quả bài kiểm tra'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: attempt.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: trf('Không đọc được kết quả: {e}', {'e': e})),
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
            Text(tr('Bài làm không được ghi nhận'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tr('Đề đã được cập nhật, hãy làm lại bài kiểm tra.'),
                textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => _goHome(context), child: Text(tr('Về trang chủ'))),
          ]),
        ),
      );

  Widget _buildResult(BuildContext context, QuizResult result) {
    final pending = result.xpAwarded == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  Text('${result.scorePercent}%',
                      style: const TextStyle(fontSize: 18, color: AppTheme.greyColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(result.passed ? tr('Tuyệt vời!') : tr('Cố gắng lên!'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    result.passed ? tr('Bạn đã vượt qua bài kiểm tra.') : tr('Hãy xem lại những câu sai rồi thử lại nhé.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                  ),
                  if (result.quizTitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(result.quizTitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                  ],
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
                      Text(pending ? tr('Đang chờ đồng bộ') : '+${result.xpAwarded} XP',
                          style: TextStyle(fontWeight: FontWeight.bold, color: pending ? AppTheme.greyColor : Colors.amber.shade800)),
                    ]),
                  ),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizReviewScreen(attemptId: result.id)),
                    ),
                    child: Text(tr('Xem chi tiết'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            context,
                            MaterialPageRoute(
                                builder: (_) => QuizScreen(quizId: result.quizId, title: title.isNotEmpty ? title : result.quizTitle))),
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
                        onPressed: () => _goHome(context),
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
    );
  }

  Widget _statItem(String label, String value, Color? color, {bool isTime = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTime ? 14 : 22)),
      ],
    );
  }
}
