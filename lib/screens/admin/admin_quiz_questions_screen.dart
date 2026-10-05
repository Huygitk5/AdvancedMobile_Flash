import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';

/// Body của POST /v1/quizzes/create và PUT /v1/quizzes/update/{id} (thay TOÀN BỘ câu hỏi).
Map<String, dynamic> quizBody(Quiz q, List<QuizQuestion> questions) => {
      'title': q.title,
      'quizType': q.quizType,
      'topicId': q.topicId,
      'grammarLessonId': q.grammarLessonId,
      'timeLimitSeconds': q.timeLimitSeconds,
      'passScorePercent': q.passScorePercent,
      'isPublished': q.isPublished,
      'questions': [
        for (final x in questions)
          {
            'questionText': x.questionText,
            'options': x.options,
            'correctOptionIndex': x.correctAnswerIndex,
            'explanation': x.explanation.isEmpty ? null : x.explanation,
            'flashcardId': x.flashcardId,
          },
      ],
    };

/// Sửa danh sách câu hỏi cục bộ rồi bấm "Lưu" gửi một lần.
/// Lưu ý: sửa đề làm các bài đang làm offline của học viên bị từ chối khi đồng bộ.
class AdminQuizQuestionsScreen extends ConsumerStatefulWidget {
  final String? quizId;
  final String quizTitle;

  /// Quiz chưa tạo (từ QuizFormScreen): "Lưu" sẽ gọi create.
  final Quiz? draft;

  const AdminQuizQuestionsScreen({super.key, required String this.quizId, required this.quizTitle}) : draft = null;

  AdminQuizQuestionsScreen.create({super.key, required Quiz this.draft})
      : quizId = null,
        quizTitle = draft.title;

  @override
  ConsumerState<AdminQuizQuestionsScreen> createState() => _AdminQuizQuestionsScreenState();
}

class _AdminQuizQuestionsScreenState extends ConsumerState<AdminQuizQuestionsScreen> {
  Future<Quiz>? _future;
  Quiz? _quiz;
  List<QuizQuestion> questions = [];
  bool _dirty = false;
  bool _saving = false;

  bool get _creating => widget.quizId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (_creating) {
      _quiz = widget.draft;
      _future = Future.value(widget.draft!);
      return;
    }
    final f = ref.read(adminApiProvider).quizDetail(widget.quizId!);
    setState(() {
      _future = f.then((d) => d.quiz);
      _dirty = false;
    });
    f.then((d) {
      if (!mounted) return;
      setState(() {
        _quiz = d.quiz;
        questions = List.of(d.questions);
      });
    }, onError: (_) {});
  }

  Future<void> _save() async {
    final q = _quiz;
    if (q == null) return;
    if (questions.isEmpty) {
      await adminRun(context, () async => throw Exception('Cần ít nhất 1 câu hỏi'));
      return;
    }
    setState(() => _saving = true);
    final api = ref.read(adminApiProvider);
    final ok = await adminRun(
      context,
      () => _creating ? api.createQuiz(quizBody(q, questions)) : api.updateQuiz(q.id, quizBody(q, questions)),
      success: 'Đã lưu bài kiểm tra',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) return;
    if (_creating) {
      Navigator.pop(context, true);
    } else {
      _load();
    }
  }

  void _showQuestionFormDialog({QuizQuestion? existingQuestion, int? index}) {
    final qController = TextEditingController(text: existingQuestion?.questionText ?? '');
    String opt(int i) => (existingQuestion?.options.length ?? 0) > i ? existingQuestion!.options[i] : '';
    final optControllers = List.generate(4, (i) => TextEditingController(text: opt(i)));
    final expController = TextEditingController(text: existingQuestion?.explanation ?? '');

    int selectedCorrectIndex = existingQuestion?.correctAnswerIndex ?? 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(existingQuestion == null ? 'Thêm Câu hỏi' : 'Sửa Câu hỏi', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: qController, maxLines: 2, decoration: adminInputDeco('Nội dung câu hỏi')),
                    const SizedBox(height: 15),
                    for (var i = 0; i < 4; i++) ...[
                      TextField(controller: optControllers[i], decoration: adminInputDeco('Đáp án ${'ABCD'[i]}')),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 5),
                    DropdownButtonFormField<int>(
                      initialValue: selectedCorrectIndex,
                      decoration: adminInputDeco('Đáp án đúng'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('A')),
                        DropdownMenuItem(value: 1, child: Text('B')),
                        DropdownMenuItem(value: 2, child: Text('C')),
                        DropdownMenuItem(value: 3, child: Text('D')),
                      ],
                      onChanged: (val) => setStateDialog(() => selectedCorrectIndex = val!),
                    ),
                    const SizedBox(height: 15),
                    TextField(controller: expController, maxLines: 2, decoration: adminInputDeco('Giải thích đáp án')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  onPressed: () {
                    final options = optControllers.map((c) => c.text.trim()).toList();
                    if (qController.text.trim().isEmpty || options.any((o) => o.isEmpty)) return;
                    setState(() {
                      final newQuestion = QuizQuestion(
                        id: existingQuestion?.id ?? '',
                        quizId: widget.quizId ?? '',
                        flashcardId: existingQuestion?.flashcardId,
                        questionText: qController.text.trim(),
                        options: options,
                        correctAnswerIndex: selectedCorrectIndex,
                        explanation: expController.text.trim(),
                      );
                      if (index == null) {
                        questions.add(newQuestion);
                      } else {
                        questions[index] = newQuestion;
                      }
                      _dirty = true;
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: Text('Xong', style: TextStyle(color: Theme.of(dialogContext).cardColor)),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Quiz: ${widget.quizTitle}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: (_dirty || _creating) && !_saving ? _save : null,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(_creating ? 'Tạo' : 'Lưu'),
          ),
        ],
      ),
      body: AdminAsync<Quiz>(
        future: _future,
        onRetry: _load,
        builder: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
          children: [
            if (_dirty && !_creating)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Có thay đổi chưa lưu. Lưu ý: sửa đề sẽ làm các bài học viên đang làm offline bị từ chối khi đồng bộ.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            if (questions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: Text('Chưa có câu hỏi nào.', style: TextStyle(color: AppTheme.greyColor))),
              ),
            ...List.generate(questions.length, (index) {
              final q = questions[index];
              return Card(
                elevation: 2, margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text('Câu ${index + 1}: ${q.questionText}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Đ/A đúng: ${'ABCD'[q.correctAnswerIndex.clamp(0, 3)]}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _showQuestionFormDialog(existingQuestion: q, index: index)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() {
                        questions.removeAt(index);
                        _dirty = true;
                      })),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        onPressed: () => _showQuestionFormDialog(),
        icon: Icon(Icons.add, color: Theme.of(context).cardColor),
        label: Text('Thêm Câu hỏi', style: TextStyle(color: Theme.of(context).cardColor)),
      ),
    );
  }
}
