import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/content_repository.dart';
import '../../models/quiz_model.dart';
import '../quiz/quiz_screen.dart';

/// Hoàn thành một bộ thẻ: báo XP vừa nhận và mời làm các bài kiểm tra của chủ đề.
class CompletionScreen extends StatefulWidget {
  final String title;
  final int xpEarned;
  final String topicId;

  const CompletionScreen({super.key, required this.title, required this.xpEarned, required this.topicId});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  List<QuizInfo> _quizzes = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final quizzes = await ContentRepository.quizzesOfTopic(widget.topicId);
      if (mounted) setState(() => _quizzes = quizzes.where((q) => q.questionCount > 0).toList());
    } catch (_) {
      // không tải được danh sách bài kiểm tra: vẫn cho về trang chủ
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                        trf('Bạn đã học xong\n"{t}"!', {'t': widget.title}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      if (widget.xpEarned > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 20),
                              const SizedBox(width: 6),
                              Text('+${widget.xpEarned} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      Text(tr('Hãy làm bài kiểm tra để củng cố những từ vừa học nhé!'),
                          textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5)),
                      const SizedBox(height: 22),
                      if (_loading)
                        const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
                      else
                        for (final quiz in _quizzes) _quizTile(context, quiz),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: goToHome,
                  child: Text(tr('Quay về trang chủ'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quizTile(BuildContext context, QuizInfo quiz) {
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
