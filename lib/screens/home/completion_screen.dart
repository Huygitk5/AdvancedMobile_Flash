import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/user_providers.dart';
import '../quiz/quiz_screen.dart';

/// Hoàn thành một bài học: báo XP ước lượng và mời làm các bài kiểm tra của chủ đề.
class CompletionScreen extends ConsumerWidget {
  /// id dòng `lesson_completions` vừa tạo.
  final String lessonCompletionId;

  /// XP ước lượng của bài (server xác nhận khi đồng bộ).
  final int xpEstimate;

  /// Có thì liệt kê các bài kiểm tra của topic.
  final String? topicId;

  /// Tên bài vừa học xong (topic / chủ điểm ngữ pháp); null thì hiện câu chung.
  final String? title;

  const CompletionScreen({super.key, required this.lessonCompletionId, required this.xpEstimate, this.topicId, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final quizzes = topicId == null ? const <Quiz>[] : (ref.watch(topicQuizzesProvider(topicId!)).value ?? const <Quiz>[]);
    final todayDone = ref.watch(todayLessonsDoneProvider).value ?? 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(50)),
                          ),
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        title == null ? tr('Bạn đã hoàn thành\nbài học này!') : trf('Bạn đã học xong\n"{t}"!', {'t': title!}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _chip(Icons.stars, Colors.amber, xpEstimate > 0 ? '+$xpEstimate XP' : '0 XP'),
                          _chip(Icons.local_fire_department, Colors.orange, trf('{n} ngày', {'n': profile?.streakDays ?? 0})),
                          _chip(Icons.menu_book, AppTheme.primaryColor, trf('{n} bài hôm nay', {'n': todayDone})),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(tr('XP sẽ được xác nhận khi đồng bộ'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                      const SizedBox(height: 14),
                      Text(
                        quizzes.isNotEmpty
                            ? tr('Hãy làm bài kiểm tra để củng cố những từ vừa học nhé!')
                            : tr('Hãy tiếp tục duy trì thói quen\nđể đạt được mục tiêu nhé!'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 22),
                      for (final quiz in quizzes) _quizTile(context, quiz),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  // Quay về màn gốc (MainScreen do StartGate dựng), không tạo MainScreen mới.
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text(tr('Quay về trang chủ'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, Color color, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      );

  Widget _quizTile(BuildContext context, Quiz quiz) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(quizId: quiz.id, title: quiz.title))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.quiz_outlined, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quiz.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(trf('{n} câu hỏi', {'n': quiz.questionCount}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.greyColor),
          ],
        ),
      ),
    );
  }
}
