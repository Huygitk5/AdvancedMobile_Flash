import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
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
            'questionText': x.questionText.trim(),
            'options': x.options.map((o) => o.trim()).toList(),
            'correctOptionIndex': x.correctAnswerIndex,
            'explanation': x.explanation.trim().isEmpty ? null : x.explanation.trim(),
            // Câu sinh từ từ vựng: giữ liên kết khi sửa đề
            'flashcardId': x.flashcardId,
          },
      ],
    };

/// Hộp thoại thêm / sửa một câu hỏi (4 đáp án, chọn đáp án đúng). Trả về câu đã sửa, null nếu huỷ.
Future<QuizQuestion?> showQuizQuestionDialog(BuildContext context, {QuizQuestion? existing, String quizId = ''}) {
  return showDialog<QuizQuestion>(context: context, builder: (_) => _QuestionDialog(existing: existing, quizId: quizId));
}

class _QuestionDialog extends StatefulWidget {
  final QuizQuestion? existing;
  final String quizId;

  const _QuestionDialog({required this.existing, required this.quizId});

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  late final TextEditingController _text = TextEditingController(text: widget.existing?.questionText ?? '');
  late final TextEditingController _explanation = TextEditingController(text: widget.existing?.explanation ?? '');
  late final List<TextEditingController> _options = List.generate(4, (i) {
    final opts = widget.existing?.options ?? const <String>[];
    return TextEditingController(text: i < opts.length ? opts[i] : '');
  });
  late int _correct = (widget.existing?.correctAnswerIndex ?? 0).clamp(0, 3);

  @override
  void dispose() {
    _text.dispose();
    _explanation.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  void _apply() {
    final options = _options.map((c) => c.text.trim()).toList();
    if (_text.text.trim().isEmpty || options.any((o) => o.isEmpty)) {
      showAppSnack(context, tr('Cần nhập câu hỏi và đủ 4 đáp án'), error: true);
      return;
    }
    if (options.toSet().length != 4) {
      showAppSnack(context, tr('Các đáp án không được trùng nhau'), error: true);
      return;
    }
    final existing = widget.existing;
    Navigator.pop(
      context,
      QuizQuestion(
        id: existing?.id ?? '',
        quizId: existing?.quizId ?? widget.quizId,
        topicId: existing?.topicId,
        flashcardId: existing?.flashcardId,
        questionText: _text.text.trim(),
        options: options,
        correctAnswerIndex: _correct,
        explanation: _explanation.text.trim(),
        sortOrder: existing?.sortOrder ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.existing == null ? tr('Thêm Câu hỏi') : tr('Sửa Câu hỏi'), style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _text, maxLines: 3, decoration: adminInputDeco(context, tr('Nội dung câu hỏi'))),
            formGap(12),
            RadioGroup<int>(
              groupValue: _correct,
              onChanged: (v) => setState(() => _correct = v ?? _correct),
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    Row(
                      children: [
                        Radio<int>(value: i),
                        Expanded(
                          child: TextField(
                            controller: _options[i],
                            decoration: adminInputDeco(context, '${tr('Đáp án')} ${String.fromCharCode(65 + i)}'),
                          ),
                        ),
                      ],
                    ),
                    formGap(8),
                  ],
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(tr('Chọn nút tròn ở đáp án đúng'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
            ),
            formGap(10),
            TextField(controller: _explanation, maxLines: 3, decoration: adminInputDeco(context, tr('Giải thích đáp án'))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: _apply,
          child: Text(tr('Xong'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Sửa danh sách câu hỏi cục bộ rồi bấm "Lưu" gửi một lần.
/// Lưu ý: sửa đề làm các bài đang làm offline của học viên bị từ chối khi đồng bộ.
class AdminQuizQuestionsScreen extends ConsumerStatefulWidget {
  final String? quizId;
  final String quizTitle;

  /// Quiz chưa tạo: "Lưu" sẽ gọi create.
  final Quiz? draft;

  const AdminQuizQuestionsScreen({super.key, required String this.quizId, required String this.quizTitle}) : draft = null;

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
      showAppSnack(context, tr('Bài kiểm tra cần ít nhất 1 câu hỏi'), error: true);
      return;
    }
    setState(() => _saving = true);
    final api = ref.read(adminApiProvider);
    final ok = await adminRun(
      context,
      () => _creating ? api.createQuiz(quizBody(q, questions)) : api.updateQuiz(q.id, quizBody(q, questions)),
      success: tr('Đã lưu bài kiểm tra'),
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

  Future<void> _edit({QuizQuestion? existing, int? index}) async {
    final edited = await showQuizQuestionDialog(context, existing: existing, quizId: widget.quizId ?? '');
    if (edited == null || !mounted) return;
    setState(() {
      if (index == null) {
        questions.add(edited);
      } else {
        questions[index] = edited;
      }
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Quiz: ${widget.quizTitle}',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: (_dirty || _creating) && !_saving ? _save : null,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(_creating ? tr('Tạo') : tr('Lưu')),
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
                child: Text(
                  tr('Có thay đổi chưa lưu. Lưu ý: sửa đề sẽ làm các bài học viên đang làm offline bị từ chối khi đồng bộ.'),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                ),
              ),
            if (questions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: EmptyView(message: tr('Chưa có câu hỏi nào.'), icon: Icons.quiz_outlined),
              ),
            ...List.generate(questions.length, (index) {
              final q = questions[index];
              final correct = q.correctAnswerIndex.clamp(0, 3);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(trf('Câu {n}: {q}', {'n': index + 1, 'q': q.questionText}),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${tr('Đáp án đúng')}: ${'ABCD'[correct]}${q.options.length > correct ? '. ${q.options[correct]}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _edit(existing: q, index: index)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() {
                          questions.removeAt(index);
                          _dirty = true;
                        }),
                      ),
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
        onPressed: () => _edit(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(tr('Thêm Câu hỏi'), style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
