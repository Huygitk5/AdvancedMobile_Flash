import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'quiz_result_screen.dart';

/// Làm một bài kiểm tra trắc nghiệm. Đề đọc từ SQLite; nộp bài thì chấm tạm ở máy, server chấm lại khi đồng bộ.
class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String title;

  const QuizScreen({super.key, required this.quizId, this.title = ''});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  final DateTime startTime = Clock.now();
  bool _submitting = false;

  static const List<String> _letters = ['A', 'B', 'C', 'D'];

  void _nextQuestion(Quiz quiz, List<QuizQuestion> questions) {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() => currentQuestionIndex++);
    } else {
      _submitQuiz(quiz, questions);
    }
  }

  /// Chấm tạm local, ghi quiz_attempts + enqueue QUIZ_SUBMIT (gửi đủ mọi câu, câu bỏ qua = null).
  Future<void> _submitQuiz(Quiz quiz, List<QuizQuestion> questions) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final attemptId = await ref.read(quizRepositoryProvider).submit(
            quiz: quiz,
            questions: questions,
            answers: selectedAnswers,
            startedAt: startTime,
          );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizResultScreen(attemptId: attemptId, title: widget.title)),
      );
    } catch (e) {
      if (mounted) {
        showAppSnack(context, errorMessage(e), error: true);
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(quizContentProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Bài kiểm tra'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: content.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: trf('Không đọc được đề: {e}', {'e': e})),
        data: (c) {
          final quiz = c.quiz;
          final questions = c.questions;
          if (quiz == null || questions.isEmpty) {
            return EmptyView(message: tr('Bài kiểm tra này chưa có câu hỏi'), icon: Icons.quiz_outlined);
          }
          if (selectedAnswers.length != questions.length) {
            selectedAnswers = List.filled(questions.length, null);
            currentQuestionIndex = currentQuestionIndex.clamp(0, questions.length - 1);
          }
          return _buildQuiz(quiz, questions);
        },
      ),
    );
  }

  Widget _buildQuiz(Quiz quiz, List<QuizQuestion> questions) {
    final question = questions[currentQuestionIndex];
    final selection = selectedAnswers[currentQuestionIndex];
    final isLast = currentQuestionIndex == questions.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.title.isNotEmpty ? widget.title : quiz.title;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.primaryColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${currentQuestionIndex + 1}/${questions.length}', style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(tr('Chọn đáp án đúng nhất.'), style: const TextStyle(fontSize: 15, color: AppTheme.greyColor)),
                  const SizedBox(height: 16),
                  Text(question.questionText, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, height: 1.4)),
                  const SizedBox(height: 26),
                  ...List.generate(question.options.length, (index) {
                    final isSelected = selection == index;
                    return GestureDetector(
                      onTap: _submitting ? null : () => setState(() => selectedAnswers[currentQuestionIndex] = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? (isDark ? const Color(0xFF273449) : const Color(0xFFEEF2FF)) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white24 : Colors.grey.shade300),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                              child: Text(index < _letters.length ? _letters[index] : '${index + 1}',
                                  style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.greyColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primaryColor : null,
                                ),
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: PrimaryButton(
              label: isLast ? tr('Nộp bài') : tr('Tiếp theo'),
              loading: _submitting,
              onPressed: selection == null ? null : () => _nextQuestion(quiz, questions),
            ),
          ),
        ],
      ),
    );
  }
}
