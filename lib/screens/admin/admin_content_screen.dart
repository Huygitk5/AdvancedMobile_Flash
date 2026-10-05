import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/theme.dart';
import '../../models/grammar_model.dart';
import '../../models/quiz_model.dart';
import '../../models/topic_model.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';
import 'admin_flashcards_screen.dart';
import 'admin_grammar_examples_screen.dart';
import 'admin_quiz_questions_screen.dart';

typedef _Content = ({List<Topic> topics, List<Grammar> grammars, List<Quiz> quizzes});

/// Thay đổi ở đây tới app người học qua `/v1/sync/content` ở lần pull sau.
class AdminContentScreen extends ConsumerStatefulWidget {
  const AdminContentScreen({super.key});

  @override
  ConsumerState<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends ConsumerState<AdminContentScreen> {
  Future<_Content>? _future;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => setState(() { _future = _fetch(); });

  Future<_Content> _fetch() async {
    final api = ref.read(adminApiProvider);
    final r = await Future.wait([api.topics(size: 100), api.grammar(size: 100), api.quizzes()]);
    return (
      topics: (r[0] as dynamic).items as List<Topic>,
      grammars: (r[1] as dynamic).items as List<Grammar>,
      quizzes: r[2] as List<Quiz>,
    );
  }

  Future<void> _openFullScreenForm(Widget formScreen) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => formScreen));
    if (saved == true) _loadData();
  }

  Future<void> _delete(String what, Future<void> Function() call) async {
    if (!await confirmDelete(context, what)) return;
    if (!mounted) return;
    if (await adminRun(context, call, success: 'Đã xoá')) _loadData();
  }

  bool _match(String title) => title.toLowerCase().contains(searchQuery.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0, automaticallyImplyLeading: false,
          title: const Text('Kho Nội dung', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
          bottom: const TabBar(labelColor: AppTheme.primaryColor, unselectedLabelColor: AppTheme.greyColor, tabs: [Tab(text: 'Từ vựng'), Tab(text: 'Ngữ pháp'), Tab(text: 'Quiz')]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(hintText: 'Tìm kiếm nội dung...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
            ),
            Expanded(
              child: AdminAsync<_Content>(
                future: _future,
                onRetry: _loadData,
                builder: (c) => TabBarView(
                  children: [_buildTopicTab(c), _buildGrammarTab(c), _buildQuizTab(c)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _draftBadge(bool published) => published
      ? const SizedBox.shrink()
      : Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
          child: const Text('Nháp', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        );

  Widget _buildTopicTab(_Content c) {
    final filteredTopics = c.topics.where((t) => _match(t.title)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredTopics.length,
        itemBuilder: (context, index) {
          final topic = filteredTopics[index];
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Text(topic.iconPath, style: const TextStyle(fontSize: 24))),
              title: Row(children: [Flexible(child: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold))), _draftBadge(topic.isPublished)]),
              subtitle: Text('${topic.totalWords} từ vựng • ${topic.level}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(TopicFormScreen(existingTopic: topic))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete('chủ đề "${topic.title}"', () => ref.read(adminApiProvider).deleteTopic(topic.id))),
              ]),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminFlashcardsScreen(topicId: topic.id, topicTitle: topic.title)));
                _loadData(); // số từ có thể đã đổi
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(const TopicFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }

  Widget _buildGrammarTab(_Content c) {
    final filteredGrammar = c.grammars.where((g) => _match(g.title)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredGrammar.length,
        itemBuilder: (context, index) {
          final grammar = filteredGrammar[index];
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(iconFor(grammar.iconName, fallback: Icons.menu_book), color: Colors.purple)),
              title: Row(children: [Flexible(child: Text(grammar.title, style: const TextStyle(fontWeight: FontWeight.bold))), _draftBadge(grammar.isPublished)]),
              subtitle: Text(grammar.structure, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(GrammarFormScreen(existingGrammar: grammar))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete('chủ điểm "${grammar.title}"', () => ref.read(adminApiProvider).deleteGrammar(grammar.id))),
              ]),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminGrammarExamplesScreen(grammarId: grammar.id, grammarTitle: grammar.title)));
                _loadData();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.purple, onPressed: () => _openFullScreenForm(const GrammarFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }

  Widget _buildQuizTab(_Content c) {
    final filteredQuizzes = c.quizzes.where((q) => _match(q.title)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = filteredQuizzes[index];
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.quiz, color: Colors.redAccent)),
              title: Row(children: [Flexible(child: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold))), _draftBadge(quiz.isPublished)]),
              subtitle: Text('${quiz.questionCount} câu hỏi • Pass: ${quiz.passScorePercent}%'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(QuizFormScreen(existingQuiz: quiz, topics: c.topics, grammars: c.grammars))),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete('bài kiểm tra "${quiz.title}"', () => ref.read(adminApiProvider).deleteQuiz(quiz.id))),
              ]),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminQuizQuestionsScreen(quizId: quiz.id, quizTitle: quiz.title)));
                _loadData();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () => _openFullScreenForm(QuizFormScreen(topics: c.topics, grammars: c.grammars)),
          child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }
}

// ================= CÁC FORM FULL MÀN HÌNH =================

Widget _levelDropdown(String value, ValueChanged<String> onChanged) => DropdownButtonFormField<String>(
      initialValue: cefrLevels.contains(value) ? value : 'A1',
      decoration: const InputDecoration(labelText: 'Cấp độ (CEFR)'),
      items: cefrLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
      onChanged: (v) => onChanged(v!),
    );

Widget _publishedSwitch(bool value, ValueChanged<bool> onChanged) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Xuất bản'),
      subtitle: const Text('Tắt = bản nháp, học viên chưa thấy'),
      value: value,
      onChanged: onChanged,
    );

// 1. TOPIC FORM
class TopicFormScreen extends ConsumerStatefulWidget {
  final Topic? existingTopic;
  const TopicFormScreen({super.key, this.existingTopic});
  @override
  ConsumerState<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends ConsumerState<TopicFormScreen> {
  late final TextEditingController titleCtrl, iconCtrl, descCtrl, minutesCtrl, sortCtrl;
  late String level;
  late bool published;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTopic;
    titleCtrl = TextEditingController(text: t?.title ?? '');
    iconCtrl = TextEditingController(text: t?.iconPath ?? '📚');
    descCtrl = TextEditingController(text: t?.description ?? '');
    minutesCtrl = TextEditingController(text: '${t?.estimatedMinutes ?? 10}');
    sortCtrl = TextEditingController(text: '${t?.sortOrder ?? 0}');
    level = t?.level ?? 'A1';
    published = t?.isPublished ?? false;
  }

  Future<void> _save() async {
    final api = ref.read(adminApiProvider);
    // Server thay toàn bộ: gửi đủ mọi field (kể cả coverColor cũ).
    final body = {
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      'iconPath': iconCtrl.text.trim(),
      'level': level,
      'coverColor': widget.existingTopic?.coverColor,
      'estimatedMinutes': parseIntOrNull(minutesCtrl.text) ?? 10,
      'sortOrder': parseIntOrNull(sortCtrl.text) ?? 0,
      'isPublished': published,
    };
    setState(() => _saving = true);
    final ok = await adminRun(context, () => widget.existingTopic == null
        ? api.createTopic(body)
        : api.updateTopic(widget.existingTopic!.id, body), success: 'Đã lưu chủ đề');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)), title: Text(widget.existingTopic == null ? 'Thêm Chủ đề' : 'Sửa Chủ đề')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: ListView(children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Chủ đề')),
              const SizedBox(height: 20),
              TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Icon (Emoji)')),
              const SizedBox(height: 20),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả')),
              const SizedBox(height: 20),
              _levelDropdown(level, (v) => setState(() => level = v)),
              const SizedBox(height: 20),
              TextField(controller: minutesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời lượng (phút)')),
              const SizedBox(height: 20),
              TextField(controller: sortCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thứ tự hiển thị')),
              const SizedBox(height: 10),
              _publishedSwitch(published, (v) => setState(() => published = v)),
            ]),
          ),
          adminDoneButton(context, onPressed: _save, loading: _saving),
        ]),
      ),
    );
  }
}

// 2. GRAMMAR FORM
class GrammarFormScreen extends ConsumerStatefulWidget {
  final Grammar? existingGrammar;
  const GrammarFormScreen({super.key, this.existingGrammar});
  @override
  ConsumerState<GrammarFormScreen> createState() => _GrammarFormScreenState();
}

class _GrammarFormScreenState extends ConsumerState<GrammarFormScreen> {
  late final TextEditingController titleCtrl, iconCtrl, descCtrl, structureCtrl, minutesCtrl, sortCtrl;
  late String level;
  late bool published;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGrammar;
    titleCtrl = TextEditingController(text: g?.title ?? '');
    iconCtrl = TextEditingController(text: g?.iconName ?? 'menu_book');
    descCtrl = TextEditingController(text: g?.description ?? '');
    structureCtrl = TextEditingController(text: g?.structure ?? '');
    minutesCtrl = TextEditingController(text: '${g?.estimatedMinutes ?? 10}');
    sortCtrl = TextEditingController(text: '${g?.sortOrder ?? 0}');
    level = g?.level ?? 'A1';
    published = g?.isPublished ?? false;
  }

  Future<void> _save() async {
    final api = ref.read(adminApiProvider);
    setState(() => _saving = true);
    final ok = await adminRun(context, () async {
      // Update thay TOÀN BỘ (kể cả ví dụ): nạp bản chi tiết để giữ content / usageNotes / examples.
      final detail = widget.existingGrammar == null ? null : await api.grammarDetail(widget.existingGrammar!.id);
      final body = {
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        'structure': structureCtrl.text.trim(),
        'content': detail?.content,
        'usageNotes': detail?.usageNotes,
        'iconName': iconCtrl.text.trim(),
        'level': level,
        'coverColor': widget.existingGrammar?.coverColor,
        'estimatedMinutes': parseIntOrNull(minutesCtrl.text) ?? 10,
        'sortOrder': parseIntOrNull(sortCtrl.text) ?? 0,
        'isPublished': published,
        'examples': grammarExamplesBody(detail?.examples ?? const []),
      };
      widget.existingGrammar == null ? await api.createGrammar(body) : await api.updateGrammar(widget.existingGrammar!.id, body);
    }, success: 'Đã lưu chủ điểm');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)), title: Text(widget.existingGrammar == null ? 'Thêm Ngữ pháp' : 'Sửa Ngữ pháp')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: ListView(children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Chủ điểm Ngữ pháp')),
              const SizedBox(height: 20),
              TextField(controller: structureCtrl, decoration: const InputDecoration(labelText: 'Cấu trúc (VD: S + am/is/are + V-ing)')),
              const SizedBox(height: 20),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả ngắn')),
              const SizedBox(height: 20),
              TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Tên Icon (VD: menu_book)')),
              const SizedBox(height: 20),
              _levelDropdown(level, (v) => setState(() => level = v)),
              const SizedBox(height: 20),
              TextField(controller: minutesCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời lượng (phút)')),
              const SizedBox(height: 20),
              TextField(controller: sortCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thứ tự hiển thị')),
              const SizedBox(height: 10),
              _publishedSwitch(published, (v) => setState(() => published = v)),
              const Text('Nội dung giải thích và câu ví dụ sửa ở màn chi tiết (chạm vào chủ điểm).',
                  style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
            ]),
          ),
          adminDoneButton(context, onPressed: _save, loading: _saving),
        ]),
      ),
    );
  }
}

// 3. QUIZ FORM
class QuizFormScreen extends ConsumerStatefulWidget {
  final Quiz? existingQuiz;
  final List<Topic> topics;
  final List<Grammar> grammars;

  const QuizFormScreen({super.key, this.existingQuiz, required this.topics, required this.grammars});
  @override
  ConsumerState<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends ConsumerState<QuizFormScreen> {
  late final TextEditingController titleCtrl, passCtrl, timeCtrl;
  late String quizType;
  String? topicId;
  String? grammarId;
  late bool published;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuiz;
    titleCtrl = TextEditingController(text: q?.title ?? '');
    passCtrl = TextEditingController(text: '${q?.passScorePercent ?? 70}');
    timeCtrl = TextEditingController(text: q?.timeLimitSeconds?.toString() ?? '');
    quizType = q?.quizType ?? 'TOPIC';
    topicId = q?.topicId;
    grammarId = q?.grammarLessonId;
    published = q?.isPublished ?? false;
  }

  Quiz _meta(String id) => Quiz(
        id: id,
        title: titleCtrl.text.trim(),
        quizType: quizType,
        topicId: quizType == 'TOPIC' ? topicId : null,
        grammarLessonId: quizType == 'GRAMMAR' ? grammarId : null,
        timeLimitSeconds: parseIntOrNull(timeCtrl.text),
        passScorePercent: parseIntOrNull(passCtrl.text) ?? 70,
        isPublished: published,
      );

  Future<void> _save() async {
    if ((quizType == 'TOPIC' ? topicId : grammarId) == null) {
      await adminRun(context, () async => throw Exception('Chọn ${quizType == 'TOPIC' ? 'chủ đề' : 'chủ điểm ngữ pháp'}'));
      return;
    }
    final api = ref.read(adminApiProvider);
    if (widget.existingQuiz == null) {
      // Quiz mới phải có ít nhất 1 câu hỏi: soạn câu hỏi rồi mới tạo.
      final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => AdminQuizQuestionsScreen.create(draft: _meta(''))),
      );
      if (created == true && mounted) Navigator.pop(context, true);
      return;
    }
    setState(() => _saving = true);
    final ok = await adminRun(context, () async {
      // Update thay TOÀN BỘ câu hỏi: gửi lại danh sách hiện có.
      final detail = await api.quizDetail(widget.existingQuiz!.id);
      await api.updateQuiz(widget.existingQuiz!.id, quizBody(_meta(widget.existingQuiz!.id), detail.questions));
    }, success: 'Đã lưu bài kiểm tra');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)), title: Text(widget.existingQuiz == null ? 'Thêm Bài kiểm tra' : 'Sửa Bài kiểm tra')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: ListView(children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Bài kiểm tra')),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: quizType,
                decoration: const InputDecoration(labelText: 'Loại'),
                items: const [
                  DropdownMenuItem(value: 'TOPIC', child: Text('Theo chủ đề từ vựng')),
                  DropdownMenuItem(value: 'GRAMMAR', child: Text('Theo chủ điểm ngữ pháp')),
                ],
                onChanged: (v) => setState(() => quizType = v!),
              ),
              const SizedBox(height: 20),
              if (quizType == 'TOPIC')
                DropdownButtonFormField<String>(
                  initialValue: widget.topics.any((t) => t.id == topicId) ? topicId : null,
                  decoration: const InputDecoration(labelText: 'Chủ đề'),
                  items: widget.topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))).toList(),
                  onChanged: (v) => setState(() => topicId = v),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: widget.grammars.any((g) => g.id == grammarId) ? grammarId : null,
                  decoration: const InputDecoration(labelText: 'Chủ điểm ngữ pháp'),
                  items: widget.grammars.map((g) => DropdownMenuItem(value: g.id, child: Text(g.title))).toList(),
                  onChanged: (v) => setState(() => grammarId = v),
                ),
              const SizedBox(height: 20),
              TextField(controller: passCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tỷ lệ đậu (%)')),
              const SizedBox(height: 20),
              TextField(controller: timeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giới hạn thời gian (giây, để trống = không giới hạn)')),
              const SizedBox(height: 10),
              _publishedSwitch(published, (v) => setState(() => published = v)),
            ]),
          ),
          adminDoneButton(context, onPressed: _save, loading: _saving, text: widget.existingQuiz == null ? 'Tiếp theo: soạn câu hỏi' : 'Xong (Done)'),
        ]),
      ),
    );
  }
}
