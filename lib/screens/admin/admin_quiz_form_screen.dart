import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/admin_repository.dart';
import '../../models/grammar_model.dart';
import '../../models/quiz_model.dart';
import '../../models/topic_model.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';

/// Một câu hỏi đang soạn.
class _QuestionDraft {
  String text;
  List<String> options;
  int correct;
  String explanation;
  String? flashcardId;

  _QuestionDraft({this.text = '', List<String>? options, this.correct = 0, this.explanation = '', this.flashcardId})
      : options = options ?? ['', '', '', ''];

  factory _QuestionDraft.from(QuizQuestion q) {
    final opts = [...q.options];
    while (opts.length < 4) {
      opts.add('');
    }
    return _QuestionDraft(
        text: q.questionText, options: opts.take(4).toList(), correct: q.correctAnswerIndex.clamp(0, 3), explanation: q.explanation, flashcardId: q.flashcardId);
  }

  Map<String, dynamic> toJson() => {
        'questionText': text.trim(),
        'options': options.map((o) => o.trim()).toList(),
        'correctOptionIndex': correct,
        'explanation': explanation.trim(),
        if (flashcardId != null) 'flashcardId': flashcardId,
      };
}

/// Tạo / sửa bài kiểm tra cùng toàn bộ câu hỏi của nó (API quản trị lưu cả đề trong một lần).
class QuizFormScreen extends StatefulWidget {
  final QuizInfo? existing;

  const QuizFormScreen({super.key, this.existing});

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _title = TextEditingController();
  final _timeLimit = TextEditingController();
  final _pass = TextEditingController(text: '70');
  String _type = 'TOPIC';
  String? _topicId;
  String? _grammarId;
  bool _published = true;
  List<Topic> _topics = const [];
  List<Grammar> _grammar = const [];
  final List<_QuestionDraft> _questions = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _timeLimit.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final topics = await AdminRepository.topics();
      final grammar = await AdminRepository.grammarLessons();
      QuizDetail? detail;
      if (widget.existing != null) detail = await AdminRepository.quizDetail(widget.existing!.id);
      if (!mounted) return;
      setState(() {
        _topics = topics;
        _grammar = grammar;
        if (detail != null) {
          final q = detail.quiz;
          _title.text = q.title;
          _type = q.quizType;
          _topicId = q.topicId;
          _grammarId = q.grammarLessonId;
          _timeLimit.text = q.timeLimitSeconds?.toString() ?? '';
          _pass.text = '${q.passScorePercent}';
          _questions
            ..clear()
            ..addAll(detail.questions.map(_QuestionDraft.from));
        }
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

  Future<void> _editQuestion([int? index]) async {
    final draft = index == null ? _QuestionDraft() : _QuestionDraft(text: _questions[index].text, options: [..._questions[index].options], correct: _questions[index].correct, explanation: _questions[index].explanation, flashcardId: _questions[index].flashcardId);
    final saved = await showDialog<bool>(context: context, builder: (_) => _QuestionDialog(draft: draft));
    if (saved != true) return;
    setState(() {
      if (index == null) {
        _questions.add(draft);
      } else {
        _questions[index] = draft;
      }
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập tên bài kiểm tra'), error: true);
      return;
    }
    if (_type == 'TOPIC' && _topicId == null || _type == 'GRAMMAR' && _grammarId == null) {
      showAppSnack(context, tr('Vui lòng chọn chủ đề hoặc chủ điểm cho bài kiểm tra'), error: true);
      return;
    }
    if (_questions.isEmpty) {
      showAppSnack(context, tr('Bài kiểm tra cần ít nhất 1 câu hỏi'), error: true);
      return;
    }
    final timeLimit = int.tryParse(_timeLimit.text.trim());
    setState(() => _saving = true);
    try {
      await AdminRepository.saveQuiz(widget.existing?.id, {
        'title': _title.text.trim(),
        'quizType': _type,
        'topicId': _type == 'TOPIC' ? _topicId : null,
        'grammarLessonId': _type == 'GRAMMAR' ? _grammarId : null,
        'timeLimitSeconds': (timeLimit != null && timeLimit >= 10) ? timeLimit : null,
        'passScorePercent': (int.tryParse(_pass.text) ?? 70).clamp(0, 100),
        'isPublished': _published,
        'questions': _questions.map((q) => q.toJson()).toList(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null ? tr('Thêm Bài kiểm tra') : tr('Sửa Bài kiểm tra');
    if (_loading) return Scaffold(appBar: AppBar(title: Text(title)), body: const LoadingView());
    if (_error != null) return Scaffold(appBar: AppBar(title: Text(title)), body: ErrorView(message: _error!, onRetry: _load));
    return AdminFormShell(
      title: title,
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _title, decoration: formDecoration(tr('Tên Bài kiểm tra'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: formDecoration(tr('Loại')),
          items: [
            DropdownMenuItem(value: 'TOPIC', child: Text(tr('Từ vựng (theo chủ đề)'))),
            DropdownMenuItem(value: 'GRAMMAR', child: Text(tr('Ngữ pháp (theo chủ điểm)'))),
          ],
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        formGap(),
        if (_type == 'TOPIC')
          DropdownButtonFormField<String>(
            initialValue: _topics.any((t) => t.id == _topicId) ? _topicId : null,
            isExpanded: true,
            decoration: formDecoration(tr('Chủ đề')),
            items: _topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _topicId = v),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _grammar.any((g) => g.id == _grammarId) ? _grammarId : null,
            isExpanded: true,
            decoration: formDecoration(tr('Chủ điểm ngữ pháp')),
            items: _grammar.map((g) => DropdownMenuItem(value: g.id, child: Text(g.title, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _grammarId = v),
          ),
        formGap(),
        Row(
          children: [
            Expanded(child: TextField(controller: _pass, keyboardType: TextInputType.number, decoration: formDecoration(tr('Tỷ lệ đậu (%)')))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _timeLimit, keyboardType: TextInputType.number, decoration: formDecoration(tr('Giới hạn (giây)')))),
          ],
        ),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Hiển thị cho học viên')), value: _published, onChanged: (v) => setState(() => _published = v)),
        formGap(8),
        Row(
          children: [
            Expanded(child: Text(trf('Câu hỏi ({n})', {'n': _questions.length}), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            TextButton.icon(onPressed: () => _editQuestion(), icon: const Icon(Icons.add), label: Text(tr('Thêm câu hỏi'))),
          ],
        ),
        for (var i = 0; i < _questions.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(radius: 14, backgroundColor: AppTheme.primaryColor, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
              title: Text(_questions[i].text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('${tr('Đáp án đúng')}: ${String.fromCharCode(65 + _questions[i].correct)}. ${_questions[i].options[_questions[i].correct]}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.green, fontSize: 12)),
              onTap: () => _editQuestion(i),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(i))),
            ),
          ),
      ],
    );
  }
}

class _QuestionDialog extends StatefulWidget {
  final _QuestionDraft draft;

  const _QuestionDialog({required this.draft});

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  late final TextEditingController _text = TextEditingController(text: widget.draft.text);
  late final TextEditingController _explanation = TextEditingController(text: widget.draft.explanation);
  late final List<TextEditingController> _options = widget.draft.options.map((o) => TextEditingController(text: o)).toList();
  late int _correct = widget.draft.correct;

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
    if (_text.text.trim().isEmpty || _options.any((c) => c.text.trim().isEmpty)) {
      showAppSnack(context, tr('Cần nhập câu hỏi và đủ 4 đáp án'), error: true);
      return;
    }
    final texts = _options.map((c) => c.text.trim()).toList();
    if (texts.toSet().length != 4) {
      showAppSnack(context, tr('Các đáp án không được trùng nhau'), error: true);
      return;
    }
    widget.draft
      ..text = _text.text
      ..options = _options.map((c) => c.text).toList()
      ..correct = _correct
      ..explanation = _explanation.text;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(tr('Câu hỏi'), style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _text, maxLines: 3, decoration: formDecoration(tr('Nội dung câu hỏi'))),
            formGap(12),
            for (var i = 0; i < 4; i++) ...[
              Row(
                children: [
                  Radio<int>(value: i, groupValue: _correct, onChanged: (v) => setState(() => _correct = v ?? _correct)),
                  Expanded(child: TextField(controller: _options[i], decoration: formDecoration('${tr('Đáp án')} ${String.fromCharCode(65 + i)}'))),
                ],
              ),
              formGap(8),
            ],
            TextField(controller: _explanation, maxLines: 3, decoration: formDecoration(tr('Giải thích'))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: _apply,
          child: Text(tr('Xong'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
