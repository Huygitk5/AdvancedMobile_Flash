import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/content_providers.dart';
import '../../providers/user_providers.dart';
import '../quiz/quiz_screen.dart';

class CompletionScreen extends ConsumerWidget {
  /// id dòng `lesson_completions` vừa tạo.
  final String lessonCompletionId;

  /// XP ước lượng của bài (server xác nhận khi đồng bộ).
  final int xpEstimate;

  /// Có thì hiện nút "Kiểm tra" nếu topic có quiz.
  final String? topicId;

  const CompletionScreen({super.key, required this.lessonCompletionId, required this.xpEstimate, this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final quiz = topicId == null ? null : ref.watch(topicQuizProvider(topicId!)).value;
    final today = ref.watch(todayStatsProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150, height: 100,
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(50)),
                  ),
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Bạn đã hoàn thành\nbài học này!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3),
              ),
              const SizedBox(height: 15),
              const Text(
                'Hãy tiếp tục duy trì thói quen\nđể đạt được mục tiêu nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(Icons.stars, Colors.amber, xpEstimate > 0 ? '+$xpEstimate XP' : '0 XP'),
                  const SizedBox(width: 12),
                  _chip(Icons.local_fire_department, Colors.orange, '${profile?.streakDays ?? 0} ngày'),
                  const SizedBox(width: 12),
                  _chip(Icons.menu_book, AppTheme.primaryColor, '${today?.lessonsCompleted ?? 1} bài hôm nay'),
                ],
              ),
              const SizedBox(height: 8),
              const Text('XP sẽ được xác nhận khi đồng bộ', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              const Spacer(),
              if (quiz != null && quiz.questionCount > 0) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => QuizScreen(quizId: quiz.id, title: quiz.title)),
                    ),
                    icon: const Icon(Icons.quiz_outlined, color: AppTheme.primaryColor),
                    label: const Text('Kiểm tra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
                  child: Text('Quay về trang chủ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
              const SizedBox(height: 20),
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
}
