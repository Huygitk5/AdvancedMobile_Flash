import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/topic_model.dart';
import '../../models/grammar_model.dart';
import 'admin_flashcards_screen.dart';
import 'admin_quiz_questions_screen.dart';
import 'admin_grammar_examples_screen.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({Key? key}) : super(key: key);

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  late List<Topic> topics;
  late List<Grammar> grammars;
  late List<Map<String, dynamic>> quizzes;
  String searchQuery = ''; // Tìm kiếm

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    topics = List.from(MockData.vocabularyTopics);
    grammars = List.from(MockData.grammarTopics);
    quizzes = [
      {'id': 'q1', 'title': 'Test: Daily Life', 'questions': 10, 'pass': '70%'},
      {'id': 'q2', 'title': 'Test: Present Simple', 'questions': 15, 'pass': '80%'},
    ];
  }

  void _openFullScreenForm(Widget formScreen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => formScreen));
    setState(() => _loadData()); // Tải lại sau khi tắt form
  }

  void _deleteTopic(String id) => setState(() { MockData.vocabularyTopics.removeWhere((t) => t.id == id); _loadData(); });
  void _deleteGrammar(String id) => setState(() { MockData.grammarTopics.removeWhere((g) => g.id == id); _loadData(); });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0, automaticallyImplyLeading: false,
          title: Text('Kho Nội dung', style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: const TabBar(labelColor: AppTheme.primaryColor, unselectedLabelColor: AppTheme.greyColor, tabs: [Tab(text: 'Từ vựng'), Tab(text: 'Ngữ pháp'), Tab(text: 'Quiz')]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(hintText: 'Tìm kiếm nội dung...', prefixIcon: Icon(Icons.search), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [ _buildTopicTab(), _buildGrammarTab(), _buildQuizTab() ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTab() {
    final filteredTopics = topics.where((t) => t.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Text(topic.iconPath, style: TextStyle(fontSize: 24))),
              title: Text(topic.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${topic.totalWords} từ vựng'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(TopicFormScreen(existingTopic: topic))), IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTopic(topic.id))]),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminFlashcardsScreen(topicId: topic.id, topicTitle: topic.title))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(const TopicFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }

  Widget _buildGrammarTab() {
    final filteredGrammar = grammars.where((g) => g.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.menu_book, color: Colors.purple)),
              title: Text(grammar.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Cấu trúc, Ví dụ & Bài tập'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(GrammarFormScreen(existingGrammar: grammar))), IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteGrammar(grammar.id))]),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminGrammarExamplesScreen(grammarId: grammar.id, grammarTitle: grammar.title))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.purple, onPressed: () => _openFullScreenForm(const GrammarFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }

  Widget _buildQuizTab() {
    final filteredQuizzes = quizzes.where((q) => q['title'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.quiz, color: Colors.redAccent)),
              title: Text(quiz['title'].toString(), style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${quiz['questions']} câu hỏi • Pass: ${quiz['pass']}'),
              trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.amber),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizFormScreen(
                    existingQuiz: quiz,
                    onSave: (updatedQuiz) {
                      setState(() {
                        quizzes[quizzes.indexWhere((q) => q['id'] == updatedQuiz['id'])] = updatedQuiz;
                      });
                    },
                  )))
              ),              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminQuizQuestionsScreen(quizId: quiz['id'].toString(), quizTitle: quiz['title'].toString()))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizFormScreen(
            onSave: (newQuiz) {
              setState(() {
                quizzes.add(newQuiz);
              });
            },
          ))),
          child: Icon(Icons.add, color: Theme.of(context).cardColor)
      ),    );
  }
}

// ================= CÁC FORM FULL MÀN HÌNH =================

// 1. TOPIC FORM
class TopicFormScreen extends StatefulWidget {
  final Topic? existingTopic;
  const TopicFormScreen({Key? key, this.existingTopic}) : super(key: key);
  @override
  State<TopicFormScreen> createState() => _TopicFormScreenState();
}
class _TopicFormScreenState extends State<TopicFormScreen> {
  late TextEditingController titleCtrl, iconCtrl;
  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.existingTopic?.title ?? '');
    iconCtrl = TextEditingController(text: widget.existingTopic?.iconPath ?? '📚');
  }
  void _save() {
    final newTopic = Topic(id: widget.existingTopic?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), title: titleCtrl.text, totalWords: widget.existingTopic?.totalWords ?? 0, progress: widget.existingTopic?.progress ?? 0.0, iconPath: iconCtrl.text);
    if (widget.existingTopic == null) MockData.vocabularyTopics.add(newTopic);
    else MockData.vocabularyTopics[MockData.vocabularyTopics.indexWhere((t) => t.id == widget.existingTopic!.id)] = newTopic;
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.close, ), onPressed: () => Navigator.pop(context)), title: Text(widget.existingTopic == null ? 'Thêm Chủ đề' : 'Sửa Chủ đề', style: TextStyle())),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Expanded(child: ListView(children: [TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Chủ đề')), const SizedBox(height: 20), TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Icon (Emoji)'))])), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _save, child: Text('Xong (Done)', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold))))])),
    );
  }
}

// 2. GRAMMAR FORM
class GrammarFormScreen extends StatefulWidget {
  final Grammar? existingGrammar;
  const GrammarFormScreen({Key? key, this.existingGrammar}) : super(key: key);
  @override
  State<GrammarFormScreen> createState() => _GrammarFormScreenState();
}
class _GrammarFormScreenState extends State<GrammarFormScreen> {
  late TextEditingController titleCtrl, iconCtrl;
  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.existingGrammar?.title ?? '');
    iconCtrl = TextEditingController(text: widget.existingGrammar?.iconName ?? 'menu_book');
  }
  void _save() {
    final newGrammar = Grammar(id: widget.existingGrammar?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), title: titleCtrl.text, progress: widget.existingGrammar?.progress ?? 0.0, status: widget.existingGrammar?.status ?? 'Chưa học 0%', iconName: iconCtrl.text);
    if (widget.existingGrammar == null) MockData.grammarTopics.add(newGrammar);
    else MockData.grammarTopics[MockData.grammarTopics.indexWhere((g) => g.id == widget.existingGrammar!.id)] = newGrammar;
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.close, ), onPressed: () => Navigator.pop(context)), title: Text(widget.existingGrammar == null ? 'Thêm Ngữ pháp' : 'Sửa Ngữ pháp', style: TextStyle())),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Expanded(child: ListView(children: [TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Chủ điểm Ngữ pháp')), const SizedBox(height: 20), TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Tên Icon (VD: menu_book)'))])), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _save, child: Text('Xong (Done)', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold))))])),
    );
  }
}

// 3. QUIZ FORM
class QuizFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingQuiz;
  // Truyền thêm hàm callback để cập nhật state ở màn hình trước
  final Function(Map<String, dynamic>)? onSave;

  const QuizFormScreen({Key? key, this.existingQuiz, this.onSave}) : super(key: key);
  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}
class _QuizFormScreenState extends State<QuizFormScreen> {
  late TextEditingController titleCtrl, qtyCtrl, passCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.existingQuiz?['title'] ?? '');
    qtyCtrl = TextEditingController(text: widget.existingQuiz?['questions']?.toString() ?? '10');
    passCtrl = TextEditingController(text: widget.existingQuiz?['pass']?.toString().replaceAll('%', '') ?? '70');
  }
  void _save() {
    // Tạo object quiz mới
    final newQuiz = {
      'id': widget.existingQuiz?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': titleCtrl.text.trim(),
      'questions': int.tryParse(qtyCtrl.text) ?? 10,
      'pass': '${passCtrl.text.trim()}%'
    };

    // Gọi hàm callback nếu có
    if (widget.onSave != null) {
      widget.onSave!(newQuiz);
    }

    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: Icon(Icons.close, ), onPressed: () => Navigator.pop(context)), title: Text(widget.existingQuiz == null ? 'Thêm Bài kiểm tra' : 'Sửa Bài kiểm tra', style: TextStyle())),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Expanded(child: ListView(children: [TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Bài kiểm tra')), const SizedBox(height: 20), TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Số lượng câu hỏi')), const SizedBox(height: 20), TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Tỷ lệ đậu (%)'))])), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _save, child: Text('Xong (Done)', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold))))])),
    );
  }
}