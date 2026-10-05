import 'package:flutter/material.dart';
import '../../core/icons.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/admin_repository.dart';
import '../../models/grammar_model.dart';
import '../../models/quiz_model.dart';
import '../../models/topic_model.dart';
import '../../widgets/common.dart';
import 'admin_flashcards_screen.dart';
import 'admin_quiz_form_screen.dart';
import 'admin_widgets.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  List<Topic> _topics = const [];
  List<Grammar> _grammar = const [];
  List<QuizInfo> _quizzes = const [];
  bool _loading = true;
  String? _error;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([AdminRepository.topics(), AdminRepository.grammarLessons(), AdminRepository.quizzes()]);
      if (!mounted) return;
      setState(() {
        _topics = results[0] as List<Topic>;
        _grammar = results[1] as List<Grammar>;
        _quizzes = results[2] as List<QuizInfo>;
        _error = null;
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

  Future<void> _openForm(Widget screen) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => screen));
    if (saved == true) _load();
  }

  Future<void> _delete(String name, Future<void> Function() action, String success) async {
    if (!await confirmDelete(context, name)) return;
    try {
      await action();
      if (!mounted) return;
      showAppSnack(context, success);
      _load();
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  bool _match(String text) => text.toLowerCase().contains(_keyword.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(tr('Kho Nội dung'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            tabs: [Tab(text: tr('Từ vựng')), Tab(text: tr('Ngữ pháp')), Tab(text: 'Quiz')],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: adminSearchField(context, hint: tr('Tìm kiếm nội dung...'), onChanged: (v) => setState(() => _keyword = v)),
            ),
            Expanded(
              child: _loading
                  ? const LoadingView()
                  : _error != null
                      ? ErrorView(message: _error!, onRetry: _load)
                      : TabBarView(children: [_topicTab(), _grammarTab(), _quizTab()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listShell({required List<Widget> items, required Color fabColor, required VoidCallback onAdd}) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _load,
        child: items.isEmpty
            ? ListView(children: [SizedBox(height: 260, child: EmptyView(message: tr('Không có dữ liệu'), icon: Icons.inbox_outlined))])
            : ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 90), children: items),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: fabColor, onPressed: onAdd, child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _card({required Widget leading, required String title, required Widget subtitle, required VoidCallback onEdit, required VoidCallback onDelete, VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: leading,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _topicTab() {
    final shown = _topics.where((t) => _match(t.title)).toList();
    return _listShell(
      fabColor: AppTheme.primaryColor,
      onAdd: () => _openForm(const TopicFormScreen()),
      items: [
        for (final topic in shown)
          _card(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
              child: Text(topic.iconPath, style: const TextStyle(fontSize: 24)),
            ),
            title: topic.title,
            subtitle: Row(children: [Text(trf('{n} từ vựng', {'n': topic.totalWords})), const SizedBox(width: 8), publishedBadge(topic.isPublished)]),
            onEdit: () => _openForm(TopicFormScreen(existing: topic)),
            onDelete: () => _delete(topic.title, () => AdminRepository.deleteTopic(topic.id), tr('Đã xóa chủ đề!')),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminFlashcardsScreen(topicId: topic.id, topicTitle: topic.title)));
              _load();
            },
          ),
      ],
    );
  }

  Widget _grammarTab() {
    final shown = _grammar.where((g) => _match(g.title)).toList();
    return _listShell(
      fabColor: Colors.purple,
      onAdd: () => _openForm(const GrammarFormScreen()),
      items: [
        for (final g in shown)
          _card(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(grammarIcon(g.iconName), color: Colors.purple),
            ),
            title: g.title,
            subtitle: Row(children: [Text(g.level), const SizedBox(width: 8), publishedBadge(g.isPublished)]),
            onEdit: () => _openForm(GrammarFormScreen(existing: g)),
            onDelete: () => _delete(g.title, () => AdminRepository.deleteGrammar(g.id), tr('Đã xóa chủ điểm!')),
            onTap: () => _openForm(GrammarFormScreen(existing: g)),
          ),
      ],
    );
  }

  Widget _quizTab() {
    final shown = _quizzes.where((q) => _match(q.title)).toList();
    return _listShell(
      fabColor: Colors.redAccent,
      onAdd: () => _openForm(const QuizFormScreen()),
      items: [
        for (final q in shown)
          _card(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.quiz, color: Colors.redAccent),
            ),
            title: q.title,
            subtitle: Text(trf('{n} câu hỏi • Đạt: {p}%', {'n': q.questionCount, 'p': q.passScorePercent})),
            onEdit: () => _openForm(QuizFormScreen(existing: q)),
            onDelete: () => _delete(q.title, () => AdminRepository.deleteQuiz(q.id), tr('Đã xóa bài kiểm tra!')),
            onTap: () => _openForm(QuizFormScreen(existing: q)),
          ),
      ],
    );
  }
}

// ================= FORM CHỦ ĐỀ =================
class TopicFormScreen extends StatefulWidget {
  final Topic? existing;

  const TopicFormScreen({super.key, this.existing});

  @override
  State<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends State<TopicFormScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _icon = TextEditingController(text: widget.existing?.iconPath ?? '📚');
  late final TextEditingController _desc = TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _minutes = TextEditingController(text: '${widget.existing?.estimatedMinutes ?? 10}');
  late String _level = widget.existing?.level ?? 'A1';
  late bool _published = widget.existing?.isPublished ?? true;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_title, _icon, _desc, _minutes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _icon.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập tên và icon'), error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await AdminRepository.saveTopic(widget.existing?.id, {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'iconPath': _icon.text.trim(),
        'level': _level,
        'estimatedMinutes': (int.tryParse(_minutes.text) ?? 10).clamp(1, 600),
        'isPublished': _published,
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
    return AdminFormShell(
      title: widget.existing == null ? tr('Thêm Chủ đề') : tr('Sửa Chủ đề'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _title, decoration: formDecoration(tr('Tên Chủ đề'))),
        formGap(),
        TextField(controller: _icon, decoration: formDecoration(tr('Icon (Emoji)'))),
        formGap(),
        TextField(controller: _desc, maxLines: 2, decoration: formDecoration(tr('Mô tả'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _level,
          decoration: formDecoration(tr('Cấp độ')),
          items: cefrLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: (v) => setState(() => _level = v ?? _level),
        ),
        formGap(),
        TextField(controller: _minutes, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thời gian học (phút)'))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Hiển thị cho học viên')), value: _published, onChanged: (v) => setState(() => _published = v)),
      ],
    );
  }
}

// ================= FORM NGỮ PHÁP (kèm ví dụ) =================
class _ExampleDraft {
  final TextEditingController sentence;
  final TextEditingController translation;
  final TextEditingController highlight;

  _ExampleDraft({String sentence = '', String translation = '', String highlight = ''})
      : sentence = TextEditingController(text: sentence),
        translation = TextEditingController(text: translation),
        highlight = TextEditingController(text: highlight);

  void dispose() {
    sentence.dispose();
    translation.dispose();
    highlight.dispose();
  }
}

class GrammarFormScreen extends StatefulWidget {
  final Grammar? existing;

  const GrammarFormScreen({super.key, this.existing});

  @override
  State<GrammarFormScreen> createState() => _GrammarFormScreenState();
}

class _GrammarFormScreenState extends State<GrammarFormScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _structure = TextEditingController();
  final _content = TextEditingController();
  final _usage = TextEditingController();
  final _icon = TextEditingController(text: 'menu_book');
  final _minutes = TextEditingController(text: '10');
  String _level = 'A1';
  bool _published = true;
  final List<_ExampleDraft> _examples = [];
  bool _loading = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _loadDetail();
  }

  @override
  void dispose() {
    for (final c in [_title, _desc, _structure, _content, _usage, _icon, _minutes]) {
      c.dispose();
    }
    for (final e in _examples) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      final detail = await AdminRepository.grammarDetail(widget.existing!.id);
      if (!mounted) return;
      final s = detail.summary;
      setState(() {
        _title.text = s.title;
        _desc.text = s.description;
        _structure.text = s.structure;
        _content.text = detail.content;
        _usage.text = detail.usageNotes;
        _icon.text = s.iconName;
        _minutes.text = '${s.estimatedMinutes}';
        _level = s.level;
        _published = s.isPublished;
        for (final ex in detail.examples) {
          _examples.add(_ExampleDraft(sentence: ex.sentence, translation: ex.translation, highlight: ex.highlight));
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

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _structure.text.trim().isEmpty || _icon.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập tên, cấu trúc và tên icon'), error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await AdminRepository.saveGrammar(widget.existing?.id, {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'structure': _structure.text.trim(),
        'content': _content.text.trim(),
        'usageNotes': _usage.text.trim(),
        'iconName': _icon.text.trim(),
        'level': _level,
        'estimatedMinutes': (int.tryParse(_minutes.text) ?? 10).clamp(1, 600),
        'isPublished': _published,
        'examples': [
          for (final e in _examples)
            if (e.sentence.text.trim().isNotEmpty)
              {'sentence': e.sentence.text.trim(), 'translation': e.translation.text.trim(), 'highlight': e.highlight.text.trim()},
        ],
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
    final title = widget.existing == null ? tr('Thêm Ngữ pháp') : tr('Sửa Ngữ pháp');
    if (_loading) return Scaffold(appBar: AppBar(title: Text(title)), body: const LoadingView());
    if (_error != null) return Scaffold(appBar: AppBar(title: Text(title)), body: ErrorView(message: _error!, onRetry: _loadDetail));
    return AdminFormShell(
      title: title,
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _title, decoration: formDecoration(tr('Tên Chủ điểm Ngữ pháp'))),
        formGap(),
        TextField(controller: _desc, maxLines: 2, decoration: formDecoration(tr('Mô tả ngắn'))),
        formGap(),
        TextField(controller: _structure, decoration: formDecoration(tr('Cấu trúc'), hint: 'S + am/is/are + V-ing')),
        formGap(),
        TextField(controller: _content, minLines: 4, maxLines: 10, decoration: formDecoration(tr('Giải thích chi tiết'))),
        formGap(),
        TextField(controller: _usage, minLines: 2, maxLines: 6, decoration: formDecoration(tr('Lưu ý'))),
        formGap(),
        TextField(controller: _icon, decoration: formDecoration(tr('Tên Icon (VD: menu_book)'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _level,
          decoration: formDecoration(tr('Cấp độ')),
          items: cefrLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: (v) => setState(() => _level = v ?? _level),
        ),
        formGap(),
        TextField(controller: _minutes, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thời gian học (phút)'))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Hiển thị cho học viên')), value: _published, onChanged: (v) => setState(() => _published = v)),
        formGap(8),
        Row(
          children: [
            Expanded(child: Text(tr('Ví dụ minh họa'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            TextButton.icon(
              onPressed: () => setState(() => _examples.add(_ExampleDraft())),
              icon: const Icon(Icons.add),
              label: Text(tr('Thêm ví dụ')),
            ),
          ],
        ),
        for (var i = 0; i < _examples.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(controller: _examples[i].sentence, decoration: formDecoration(tr('Câu tiếng Anh'))),
                  formGap(10),
                  TextField(controller: _examples[i].translation, decoration: formDecoration(tr('Dịch'))),
                  formGap(10),
                  TextField(controller: _examples[i].highlight, decoration: formDecoration(tr('Cụm cần tô đậm'))),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _examples.removeAt(i).dispose()),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      label: Text(tr('Xóa'), style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
