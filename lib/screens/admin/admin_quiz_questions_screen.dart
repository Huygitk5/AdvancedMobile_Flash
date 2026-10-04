import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';

class AdminQuizQuestionsScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const AdminQuizQuestionsScreen({Key? key, required this.quizId, required this.quizTitle}) : super(key: key);

  @override
  State<AdminQuizQuestionsScreen> createState() => _AdminQuizQuestionsScreenState();
}

class _AdminQuizQuestionsScreenState extends State<AdminQuizQuestionsScreen> {
  // Giả lập danh sách câu hỏi cho Quiz này
  late List<QuizQuestion> questions;

  @override
  void initState() {
    super.initState();
    // Tạo sẵn vài câu hỏi mock để dễ test
    questions = [
      QuizQuestion(id: 'q1', topicId: widget.quizId, questionText: 'She ______ her homework now.', options: ['is doing', 'does', 'did', 'was doing'], correctAnswerIndex: 0, explanation: 'Thì hiện tại tiếp diễn.'),
    ];
  }

  void _showQuestionFormDialog({QuizQuestion? existingQuestion}) {
    final qController = TextEditingController(text: existingQuestion?.questionText ?? '');
    final optAController = TextEditingController(text: existingQuestion?.options.isNotEmpty == true ? existingQuestion!.options[0] : '');
    final optBController = TextEditingController(text: (existingQuestion?.options.length ?? 0) > 1 ? existingQuestion!.options[1] : '');
    final optCController = TextEditingController(text: (existingQuestion?.options.length ?? 0) > 2 ? existingQuestion!.options[2] : '');
    final optDController = TextEditingController(text: (existingQuestion?.options.length ?? 0) > 3 ? existingQuestion!.options[3] : '');
    final expController = TextEditingController(text: existingQuestion?.explanation ?? '');

    int selectedCorrectIndex = existingQuestion?.correctAnswerIndex ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(existingQuestion == null ? 'Thêm Câu hỏi' : 'Sửa Câu hỏi', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: qController, maxLines: 2, decoration: _inputDeco('Nội dung câu hỏi')),
                    const SizedBox(height: 15),
                    TextField(controller: optAController, decoration: _inputDeco('Đáp án A')),
                    const SizedBox(height: 10),
                    TextField(controller: optBController, decoration: _inputDeco('Đáp án B')),
                    const SizedBox(height: 10),
                    TextField(controller: optCController, decoration: _inputDeco('Đáp án C')),
                    const SizedBox(height: 10),
                    TextField(controller: optDController, decoration: _inputDeco('Đáp án D')),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedCorrectIndex,
                      decoration: _inputDeco('Đáp án đúng'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('A')),
                        DropdownMenuItem(value: 1, child: Text('B')),
                        DropdownMenuItem(value: 2, child: Text('C')),
                        DropdownMenuItem(value: 3, child: Text('D')),
                      ],
                      onChanged: (val) => setStateDialog(() => selectedCorrectIndex = val!),
                    ),
                    const SizedBox(height: 15),
                    TextField(controller: expController, maxLines: 2, decoration: _inputDeco('Giải thích đáp án')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  onPressed: () {
                    setState(() {
                      final newQuestion = QuizQuestion(
                        id: existingQuestion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        topicId: widget.quizId,
                        questionText: qController.text.trim(),
                        options: [optAController.text.trim(), optBController.text.trim(), optCController.text.trim(), optDController.text.trim()],
                        correctAnswerIndex: selectedCorrectIndex,
                        explanation: expController.text.trim(),
                      );

                      if (existingQuestion == null) {
                        questions.add(newQuestion);
                      } else {
                        final index = questions.indexWhere((q) => q.id == existingQuestion.id);
                        if (index != -1) questions[index] = newQuestion;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Lưu', style: TextStyle(color: Theme.of(context).cardColor)),
                ),
              ],
            );
          }
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: const Color(0xFFF4F6FA),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new,  size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Quiz: ${widget.quizTitle}', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: questions.isEmpty
          ? const Center(child: Text('Chưa có câu hỏi nào.', style: TextStyle(color: AppTheme.greyColor)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text('Câu ${index + 1}: ${q.questionText}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Đ/A đúng: ${['A', 'B', 'C', 'D'][q.correctAnswerIndex]}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _showQuestionFormDialog(existingQuestion: q)),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => questions.removeAt(index))),
                ],
              ),
            ),
          );
        },
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