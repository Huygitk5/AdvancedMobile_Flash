import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/grammar_model.dart';
import '../../models/quiz_model.dart';
import '../../models/topic_model.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'admin_common.dart';
import 'admin_flashcards_screen.dart';
import 'admin_grammar_examples_screen.dart';
import 'admin_quiz_questions_screen.dart';

typedef _Content = ({List<Topic> topics, List<Grammar> grammars, List<Quiz> quizzes});

/// Lấy hết các trang của một danh sách phân trang (tối đa [maxPages] trang).
Future<List<T>> _allPages<T>(Future<({List<T> items, int totalPages})> Function(int page) fetch, {int maxPages = 5}) async {
  final all = <T>[];
  for (var page = 0; page < maxPages; page++) {
    final r = await fetch(page);
    all.addAll(r.items);
    if (page + 1 >= r.totalPages) break;
  }
  return all;
}

Future<List<Topic>> _allTopics(WidgetRef ref) => _allPages((p) async {
      final r = await ref.read(adminApiProvider).topics(page: p);
      return (items: r.items, totalPages: r.totalPages);
    });

Future<List<Grammar>> _allGrammar(WidgetRef ref) => _allPages((p) async {
      final r = await ref.read(adminApiProvider).grammar(page: p);
      return (items: r.items, totalPages: r.totalPages);
    });

/// Thay đổi ở đây tới app người học qua `/v1/sync/content` ở lần pull sau.
class AdminContentScreen extends ConsumerStatefulWidget {
  const AdminContentScreen({super.key});

  @override
  ConsumerState<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends ConsumerState<AdminContentScreen> {
  Future<_Content>? _future;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => setState(() {
        _future = _fetch();
      });

  Future<_Content> _fetch() async {
    final r = await Future.wait([_allTopics(ref), _allGrammar(ref), ref.read(adminApiProvider).quizzes()]);
    return (topics: r[0] as List<Topic>, grammars: r[1] as List<Grammar>, quizzes: r[2] as List<Quiz>);
  }

  Future<void> _openForm(Widget formScreen) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => formScreen));
    if (saved == true) _loadData();
  }

  Future<void> _openDetail(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    _loadData(); // số từ / câu hỏi có thể đã đổi
  }

  Future<void> _delete(String what, Future<void> Function() call, String success) async {
    if (!await confirmDelete(context, what)) return;
    if (!mounted) return;
    if (await adminRun(context, call, success: success)) _loadData();
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
          actions: [IconButton(tooltip: tr('Làm mới'), icon: const Icon(Icons.refresh), onPressed: _loadData)],
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            tabs: [Tab(text: tr('Từ vựng')), Tab(text: tr('Ngữ pháp')), const Tab(text: 'Quiz')],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: adminSearchField(context, hint: tr('Tìm kiếm nội dung...'), onChanged: (v) => setState(() => _keyword = v)),
            ),
            Expanded(
              child: AdminAsync<_Content>(
                future: _future,
                onRetry: _loadData,
                builder: (c) => TabBarView(children: [_topicTab(c), _grammarTab(c), _quizTab(c)]),
              ),
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
        onRefresh: () async {
          _loadData();
          await _future;
        },
        child: items.isEmpty
            ? ListView(children: [SizedBox(height: 260, child: EmptyView(message: tr('Không có dữ liệu'), icon: Icons.inbox_outlined))])
            : ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 90), children: items),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: fabColor, onPressed: onAdd, child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _card({
    required Widget leading,
    required String title,
    required Widget subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    VoidCallback? onTap,
  }) {
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

  Widget _leadingBox(Color bg, Widget child) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: child,
      );

  Widget _topicTab(_Content c) {
    final shown = c.topics.where((t) => _match(t.title)).toList();
    return _listShell(
      fabColor: AppTheme.primaryColor,
      onAdd: () => _openForm(const TopicFormScreen()),
      items: [
        for (final topic in shown)
          _card(
            leading: _leadingBox(Colors.blue.shade50, Text(topic.iconPath, style: const TextStyle(fontSize: 24))),
            title: topic.title,
            subtitle: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [Text('${trf('{n} từ vựng', {'n': topic.totalWords})} • ${topic.level}'), publishedBadge(topic.isPublished)],
            ),
            onEdit: () => _openForm(TopicFormScreen(existing: topic)),
            onDelete: () => _delete(topic.title, () => ref.read(adminApiProvider).deleteTopic(topic.id), tr('Đã xóa chủ đề!')),
            onTap: () => _openDetail(AdminFlashcardsScreen(topicId: topic.id, topicTitle: topic.title)),
          ),
      ],
    );
  }

  Widget _grammarTab(_Content c) {
    final shown = c.grammars.where((g) => _match(g.title)).toList();
    return _listShell(
      fabColor: Colors.purple,
      onAdd: () => _openForm(const GrammarFormScreen()),
      items: [
        for (final g in shown)
          _card(
            leading: _leadingBox(Colors.purple.shade50, Icon(iconFor(g.iconName, fallback: Icons.menu_book), color: Colors.purple)),
            title: g.title,
            subtitle: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(g.structure.isEmpty ? g.level : '${g.level} • ${g.structure}', maxLines: 1, overflow: TextOverflow.ellipsis),
                publishedBadge(g.isPublished),
              ],
            ),
            onEdit: () => _openForm(GrammarFormScreen(existing: g)),
            onDelete: () => _delete(g.title, () => ref.read(adminApiProvider).deleteGrammar(g.id), tr('Đã xóa chủ điểm!')),
            // Chạm: màn chi tiết sửa cấu trúc / giải thích / từng câu ví dụ
            onTap: () => _openDetail(AdminGrammarExamplesScreen(grammarId: g.id, grammarTitle: g.title)),
          ),
      ],
    );
  }

  Widget _quizTab(_Content c) {
    final shown = c.quizzes.where((q) => _match(q.title)).toList();
    return _listShell(
      fabColor: Colors.redAccent,
      onAdd: () => _openForm(QuizFormScreen(topics: c.topics, grammars: c.grammars)),
      items: [
        for (final q in shown)
          _card(
            leading: _leadingBox(Colors.red.shade50, const Icon(Icons.quiz, color: Colors.redAccent)),
            title: q.title,
            subtitle: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [Text(trf('{n} câu hỏi • Đạt: {p}%', {'n': q.questionCount, 'p': q.passScorePercent})), publishedBadge(q.isPublished)],
            ),
            onEdit: () => _openForm(QuizFormScreen(existing: q, topics: c.topics, grammars: c.grammars)),
            onDelete: () => _delete(q.title, () => ref.read(adminApiProvider).deleteQuiz(q.id), tr('Đã xóa bài kiểm tra!')),
            // Chạm: màn danh sách câu hỏi của đề
            onTap: () => _openDetail(AdminQuizQuestionsScreen(quizId: q.id, quizTitle: q.title)),
          ),
      ],
    );
  }
}

// ================= CÁC FORM FULL MÀN HÌNH =================

Widget _levelDropdown(String value, ValueChanged<String> onChanged) => DropdownButtonFormField<String>(
      initialValue: cefrLevels.contains(value) ? value : 'A1',
      decoration: formDecoration(tr('Cấp độ (CEFR)')),
      items: cefrLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
      onChanged: (v) => onChanged(v!),
    );

Widget _publishedSwitch(bool value, ValueChanged<bool> onChanged) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(tr('Hiển thị cho học viên')),
      subtitle: Text(tr('Tắt = bản nháp, học viên chưa thấy')),
      value: value,
      onChanged: onChanged,
    );

int _minutes(TextEditingController c) => (parseIntOrNull(c.text) ?? 10).clamp(1, 600);

// 1. TOPIC FORM
class TopicFormScreen extends ConsumerStatefulWidget {
  final Topic? existing;

  const TopicFormScreen({super.key, this.existing});

  @override
  ConsumerState<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends ConsumerState<TopicFormScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _icon = TextEditingController(text: widget.existing?.iconPath ?? '📚');
  late final TextEditingController _desc = TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _minutesCtrl = TextEditingController(text: '${widget.existing?.estimatedMinutes ?? 10}');
  late final TextEditingController _sort = TextEditingController(text: '${widget.existing?.sortOrder ?? 0}');
  late String _level = widget.existing?.level ?? 'A1';
  late bool _published = widget.existing?.isPublished ?? false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_title, _icon, _desc, _minutesCtrl, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _icon.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập tên và icon'), error: true);
      return;
    }
    final api = ref.read(adminApiProvider);
    // Server thay toàn bộ: gửi đủ mọi field (kể cả coverColor cũ).
    final body = {
      'title': _title.text.trim(),
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'iconPath': _icon.text.trim(),
      'level': _level,
      'coverColor': widget.existing?.coverColor,
      'estimatedMinutes': _minutes(_minutesCtrl),
      'sortOrder': parseIntOrNull(_sort.text) ?? 0,
      'isPublished': _published,
    };
    setState(() => _saving = true);
    final ok = await adminRun(
        context, () => widget.existing == null ? api.createTopic(body) : api.updateTopic(widget.existing!.id, body),
        success: tr('Đã lưu chủ đề'));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
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
        _levelDropdown(_level, (v) => setState(() => _level = v)),
        formGap(),
        TextField(controller: _minutesCtrl, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thời gian học (phút)'))),
        formGap(),
        TextField(controller: _sort, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thứ tự hiển thị'))),
        _publishedSwitch(_published, (v) => setState(() => _published = v)),
      ],
    );
  }
}

// 2. GRAMMAR FORM (kèm giải thích, lưu ý và ví dụ)
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

class GrammarFormScreen extends ConsumerStatefulWidget {
  final Grammar? existing;

  const GrammarFormScreen({super.key, this.existing});

  @override
  ConsumerState<GrammarFormScreen> createState() => _GrammarFormScreenState();
}

class _GrammarFormScreenState extends ConsumerState<GrammarFormScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _structure = TextEditingController();
  final _content = TextEditingController();
  final _usage = TextEditingController();
  final _icon = TextEditingController(text: 'menu_book');
  final _minutesCtrl = TextEditingController(text: '10');
  final _sort = TextEditingController(text: '0');
  String _level = 'A1';
  bool _published = false;
  int? _coverColor;
  final List<_ExampleDraft> _examples = [];
  Future<void>? _loading;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _loading = _loadDetail();
  }

  @override
  void dispose() {
    for (final c in [_title, _desc, _structure, _content, _usage, _icon, _minutesCtrl, _sort]) {
      c.dispose();
    }
    for (final e in _examples) {
      e.dispose();
    }
    super.dispose();
  }

  /// Update thay TOÀN BỘ (kể cả ví dụ): nạp bản chi tiết để giữ content / usageNotes / examples.
  Future<void> _loadDetail() async {
    final detail = await ref.read(adminApiProvider).grammarDetail(widget.existing!.id);
    if (!mounted) return;
    final g = detail.grammar;
    setState(() {
      _title.text = g.title;
      _desc.text = g.description ?? '';
      _structure.text = g.structure;
      _content.text = detail.content ?? '';
      _usage.text = detail.usageNotes ?? '';
      _icon.text = g.iconName;
      _minutesCtrl.text = '${g.estimatedMinutes}';
      _sort.text = '${widget.existing!.sortOrder}';
      _level = g.level;
      _published = g.isPublished;
      _coverColor = g.coverColor ?? widget.existing!.coverColor;
      for (final e in _examples) {
        e.dispose();
      }
      _examples
        ..clear()
        ..addAll(detail.examples.map(
            (ex) => _ExampleDraft(sentence: ex.sentence, translation: ex.translation ?? '', highlight: ex.highlight ?? '')));
    });
  }

  String? _orNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _structure.text.trim().isEmpty || _icon.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập tên, cấu trúc và tên icon'), error: true);
      return;
    }
    final api = ref.read(adminApiProvider);
    final body = {
      'title': _title.text.trim(),
      'description': _orNull(_desc),
      'structure': _structure.text.trim(),
      'content': _orNull(_content),
      'usageNotes': _orNull(_usage),
      'iconName': _icon.text.trim(),
      'level': _level,
      'coverColor': _coverColor,
      'estimatedMinutes': _minutes(_minutesCtrl),
      'sortOrder': parseIntOrNull(_sort.text) ?? 0,
      'isPublished': _published,
      'examples': grammarExamplesBody([
        for (final e in _examples)
          if (e.sentence.text.trim().isNotEmpty)
            GrammarExample(
                id: '', sentence: e.sentence.text.trim(), translation: e.translation.text.trim(), highlight: e.highlight.text.trim()),
      ]),
    };
    setState(() => _saving = true);
    final ok = await adminRun(
        context, () => widget.existing == null ? api.createGrammar(body) : api.updateGrammar(widget.existing!.id, body),
        success: tr('Đã lưu chủ điểm'));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null ? tr('Thêm Ngữ pháp') : tr('Sửa Ngữ pháp');
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snap) {
        if (_loading != null && snap.connectionState != ConnectionState.done) {
          return Scaffold(appBar: AppBar(title: Text(title)), body: const LoadingView());
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: AdminErrorView(error: snap.error!, onRetry: () => setState(() {
                      _loading = _loadDetail();
                    })),
          );
        }
        return AdminFormShell(
          title: title,
          saving: _saving,
          onSave: _save,
          children: [
            TextField(controller: _title, decoration: formDecoration(tr('Tên Chủ điểm Ngữ pháp'))),
            formGap(),
            TextField(controller: _structure, decoration: formDecoration(tr('Cấu trúc'), hint: 'S + am/is/are + V-ing')),
            formGap(),
            TextField(controller: _desc, maxLines: 2, decoration: formDecoration(tr('Mô tả ngắn'))),
            formGap(),
            TextField(controller: _content, minLines: 4, maxLines: 10, decoration: formDecoration(tr('Giải thích chi tiết'))),
            formGap(),
            TextField(controller: _usage, minLines: 2, maxLines: 6, decoration: formDecoration(tr('Lưu ý'))),
            formGap(),
            TextField(controller: _icon, decoration: formDecoration(tr('Tên Icon (VD: menu_book)'))),
            formGap(),
            _levelDropdown(_level, (v) => setState(() => _level = v)),
            formGap(),
            TextField(controller: _minutesCtrl, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thời gian học (phút)'))),
            formGap(),
            TextField(controller: _sort, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thứ tự hiển thị'))),
            _publishedSwitch(_published, (v) => setState(() => _published = v)),
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
      },
    );
  }
}

// 3. QUIZ FORM (soạn luôn câu hỏi; chạm vào quiz ở danh sách để sửa riêng từng câu)
class QuizFormScreen extends ConsumerStatefulWidget {
  final Quiz? existing;
  final List<Topic> topics;
  final List<Grammar> grammars;

  const QuizFormScreen({super.key, this.existing, required this.topics, required this.grammars});

  @override
  ConsumerState<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends ConsumerState<QuizFormScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _pass = TextEditingController(text: '${widget.existing?.passScorePercent ?? 70}');
  late final TextEditingController _timeLimit = TextEditingController(text: widget.existing?.timeLimitSeconds?.toString() ?? '');
  late String _type = widget.existing?.quizType ?? 'TOPIC';
  late String? _topicId = widget.existing?.topicId;
  late String? _grammarId = widget.existing?.grammarLessonId;
  late bool _published = widget.existing?.isPublished ?? false;
  List<QuizQuestion> _questions = [];
  Future<void>? _loading;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _loading = _loadQuestions();
  }

  @override
  void dispose() {
    _title.dispose();
    _pass.dispose();
    _timeLimit.dispose();
    super.dispose();
  }

  /// Update thay TOÀN BỘ câu hỏi: nạp danh sách hiện có để gửi lại.
  Future<void> _loadQuestions() async {
    final detail = await ref.read(adminApiProvider).quizDetail(widget.existing!.id);
    if (mounted) setState(() => _questions = List.of(detail.questions));
  }

  Quiz _meta(String id) {
    final timeLimit = parseIntOrNull(_timeLimit.text);
    return Quiz(
      id: id,
      title: _title.text.trim(),
      quizType: _type,
      topicId: _type == 'TOPIC' ? _topicId : null,
      grammarLessonId: _type == 'GRAMMAR' ? _grammarId : null,
      timeLimitSeconds: (timeLimit != null && timeLimit >= 10) ? timeLimit : null,
      passScorePercent: (parseIntOrNull(_pass.text) ?? 70).clamp(0, 100),
      isPublished: _published,
    );
  }

  Future<void> _editQuestion([int? index]) async {
    final edited = await showQuizQuestionDialog(context, existing: index == null ? null : _questions[index]);
    if (edited == null) return;
    setState(() => index == null ? _questions.add(edited) : _questions[index] = edited);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập tên bài kiểm tra'), error: true);
      return;
    }
    if ((_type == 'TOPIC' ? _topicId : _grammarId) == null) {
      showAppSnack(context, tr('Vui lòng chọn chủ đề hoặc chủ điểm cho bài kiểm tra'), error: true);
      return;
    }
    if (_questions.isEmpty) {
      showAppSnack(context, tr('Bài kiểm tra cần ít nhất 1 câu hỏi'), error: true);
      return;
    }
    final api = ref.read(adminApiProvider);
    final id = widget.existing?.id;
    setState(() => _saving = true);
    final ok = await adminRun(
      context,
      () => id == null ? api.createQuiz(quizBody(_meta(''), _questions)) : api.updateQuiz(id, quizBody(_meta(id), _questions)),
      success: tr('Đã lưu bài kiểm tra'),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null ? tr('Thêm Bài kiểm tra') : tr('Sửa Bài kiểm tra');
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snap) {
        if (_loading != null && snap.connectionState != ConnectionState.done) {
          return Scaffold(appBar: AppBar(title: Text(title)), body: const LoadingView());
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: AdminErrorView(error: snap.error!, onRetry: () => setState(() {
                      _loading = _loadQuestions();
                    })),
          );
        }
        return AdminFormShell(
          title: title,
          saving: _saving,
          onSave: _save,
          children: [
            if (widget.existing != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(tr('Lưu ý: sửa đề sẽ làm các bài học viên đang làm offline bị từ chối khi đồng bộ.'),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              ),
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
                initialValue: widget.topics.any((t) => t.id == _topicId) ? _topicId : null,
                isExpanded: true,
                decoration: formDecoration(tr('Chủ đề')),
                items: widget.topics
                    .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _topicId = v),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: widget.grammars.any((g) => g.id == _grammarId) ? _grammarId : null,
                isExpanded: true,
                decoration: formDecoration(tr('Chủ điểm ngữ pháp')),
                items: widget.grammars
                    .map((g) => DropdownMenuItem(value: g.id, child: Text(g.title, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _grammarId = v),
              ),
            formGap(),
            Row(
              children: [
                Expanded(
                    child: TextField(controller: _pass, keyboardType: TextInputType.number, decoration: formDecoration(tr('Tỷ lệ đậu (%)')))),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _timeLimit,
                    keyboardType: TextInputType.number,
                    decoration: formDecoration(tr('Giới hạn (giây)'), hint: tr('Để trống = không giới hạn')),
                  ),
                ),
              ],
            ),
            _publishedSwitch(_published, (v) => setState(() => _published = v)),
            formGap(8),
            Row(
              children: [
                Expanded(
                    child: Text(trf('Câu hỏi ({n})', {'n': _questions.length}),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                TextButton.icon(onPressed: () => _editQuestion(), icon: const Icon(Icons.add), label: Text(tr('Thêm câu hỏi'))),
              ],
            ),
            for (var i = 0; i < _questions.length; i++)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                  title: Text(_questions[i].questionText,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                      '${tr('Đáp án đúng')}: ${String.fromCharCode(65 + _questions[i].correctAnswerIndex.clamp(0, 3))}. '
                      '${_questions[i].options.length > _questions[i].correctAnswerIndex ? _questions[i].options[_questions[i].correctAnswerIndex] : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.green, fontSize: 12)),
                  onTap: () => _editQuestion(i),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(i))),
                ),
              ),
          ],
        );
      },
    );
  }
}
