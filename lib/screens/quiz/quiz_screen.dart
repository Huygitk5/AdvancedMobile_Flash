import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/content_repository.dart';
import '../../data/study_repository.dart';
import '../../models/quiz_model.dart';
import '../../widgets/common.dart';
import 'quiz_result_screen.dart';

/// Làm một bài kiểm tra trắc nghiệm. Đề lấy từ server; nộp bài thì server chấm lại và cộng XP.
class QuizScreen extends StatefulWidget {
  final String quizId;
  final String title;

  const QuizScreen({super.key, required this.quizId, this.title = ''});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizDetail? _quiz;
  List<int?> _answers = [];
  int _current = 0;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  DateTime _startedAt = DateTime.now();

  static const List<String> _letters = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quiz = await ContentRepository.quiz(widget.quizId);
      if (!mounted) return;
      setState(() {
        _quiz = quiz;
        _answers = List<int?>.filled(quiz.questions.length, null);
        _current = 0;
        _startedAt = DateTime.now();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _next() async {
    final quiz = _quiz!;
    if (_current < quiz.questions.length - 1) {
      setState(() => _current++);
      return;
    }
    setState(() => _submitting = true);
    try {
      final result = await StudyRepository.submitQuiz(
        quizId: quiz.quiz.id,
        questions: quiz.questions,
        answers: _answers,
        startedAt: _startedAt,
      );
      if (!mounted) return;
      // Dữ liệu xem lại dựng từ chính đề và đáp án vừa chọn
      final review = <QuizReviewItem>[
        for (var i = 0; i < quiz.questions.length; i++)
          QuizReviewItem(
            id: quiz.questions[i].id,
            question: quiz.questions[i].questionText,
            options: quiz.questions[i].options,
            correctIndex: quiz.questions[i].correctAnswerIndex,
            userIndex: _answers[i] ?? -1,
            explanation: quiz.questions[i].explanation,
          ),
      ];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuizResultScreen(result: result, reviewData: review, title: widget.title)),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Bài kiểm tra'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    final quiz = _quiz!;
    if (quiz.questions.isEmpty) return EmptyView(message: tr('Bài kiểm tra này chưa có câu hỏi'), icon: Icons.quiz_outlined);

    final question = quiz.questions[_current];
    final selection = _answers[_current];
    final isLast = _current == quiz.questions.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_current + 1) / quiz.questions.length,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primaryColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Text('${_current + 1}/${quiz.questions.length}', style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
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
                if (widget.title.isNotEmpty || quiz.quiz.title.isNotEmpty)
                  Text(widget.title.isNotEmpty ? widget.title : quiz.quiz.title,
                      style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(tr('Chọn đáp án đúng nhất.'), style: const TextStyle(fontSize: 15, color: AppTheme.greyColor)),
                const SizedBox(height: 16),
                Text(question.questionText, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 26),
                ...List.generate(question.options.length, (index) {
                  final isSelected = selection == index;
                  return GestureDetector(
                    onTap: _submitting ? null : () => setState(() => _answers[_current] = index),
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
                                style: TextStyle(color: isSelected ? Colors.white : AppTheme.greyColor, fontSize: 13, fontWeight: FontWeight.bold)),
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
            onPressed: selection == null ? null : _next,
          ),
        ),
      ],
    );
  }
}
