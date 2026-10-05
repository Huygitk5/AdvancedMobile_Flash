import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/app_snack.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String title;

  const QuizScreen({super.key, required this.quizId, required this.title});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  final DateTime startTime = Clock.now();
  bool _submitting = false;

  final List<String> optionLetters = ['A', 'B', 'C', 'D'];

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
        MaterialPageRoute(builder: (context) => QuizResultScreen(attemptId: attemptId)),
      );
    } catch (e) {
      if (mounted) {
        showError(context, e);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title.isEmpty ? 'Bài kiểm tra' : widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không đọc được đề: $e')),
        data: (c) {
          final quiz = c.quiz;
          final questions = c.questions;
          if (quiz == null || questions.isEmpty) {
            return const Center(child: Text('Bài kiểm tra chưa có câu hỏi.', style: TextStyle(color: AppTheme.greyColor)));
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
    final currentQuestion = questions[currentQuestionIndex];
    final currentSelection = selectedAnswers[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == questions.length - 1;

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
          const SizedBox(height: 25),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn đáp án đúng nhất.', style: TextStyle(fontSize: 16, color: AppTheme.greyColor)),
                  const SizedBox(height: 20),
                  Text(currentQuestion.questionText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  ...List.generate(currentQuestion.options.length, (index) {
                    final isSelected = currentSelection == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedAnswers[currentQuestionIndex] = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                              child: Text(optionLetters[index], style: TextStyle(color: isSelected ? Colors.white : AppTheme.greyColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                currentQuestion.options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primaryColor : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24)
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentSelection != null ? AppTheme.primaryColor : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: currentSelection != null ? 2 : 0,
                ),
                onPressed: currentSelection == null || _submitting ? null : () => _nextQuestion(quiz, questions),
                child: Text(isLastQuestion ? 'Nộp bài' : 'Tiếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
