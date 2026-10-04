import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AdminGrammarExamplesScreen extends StatefulWidget {
  final String grammarId;
  final String grammarTitle;

  const AdminGrammarExamplesScreen({Key? key, required this.grammarId, required this.grammarTitle}) : super(key: key);

  @override
  State<AdminGrammarExamplesScreen> createState() => _AdminGrammarExamplesScreenState();
}

class _AdminGrammarExamplesScreenState extends State<AdminGrammarExamplesScreen> {
  // Giả lập dữ liệu chi tiết của 1 bài Ngữ pháp
  String structure = 'S + V + O';
  String explanation = 'Mô tả cách dùng của chủ điểm ngữ pháp này...';

  // Giả lập danh sách ví dụ
  List<Map<String, String>> examples = [
    {'sentence': 'I am learning English.', 'translation': 'Tôi đang học tiếng Anh.', 'highlight': 'am learning'},
  ];

  void _showExampleFormDialog({Map<String, String>? existingExample, int? index}) {
    final sentenceController = TextEditingController(text: existingExample?['sentence'] ?? '');
    final transController = TextEditingController(text: existingExample?['translation'] ?? '');
    final highlightController = TextEditingController(text: existingExample?['highlight'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingExample == null ? 'Thêm Ví dụ' : 'Sửa Ví dụ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: sentenceController, decoration: _inputDeco('Câu tiếng Anh')),
              const SizedBox(height: 10),
              TextField(controller: transController, decoration: _inputDeco('Nghĩa tiếng Việt')),
              const SizedBox(height: 10),
              TextField(controller: highlightController, decoration: _inputDeco('Cụm từ cần in đậm (VD: am learning)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                final newExample = {
                  'sentence': sentenceController.text.trim(),
                  'translation': transController.text.trim(),
                  'highlight': highlightController.text.trim(),
                };
                if (existingExample == null) {
                  examples.add(newExample);
                } else if (index != null) {
                  examples[index] = newExample;
                }
              });
              Navigator.pop(context);
            },
            child: Text('Lưu', style: TextStyle(color: Theme.of(context).cardColor)),
          ),
        ],
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
        title: Text('Ngữ pháp: ${widget.grammarTitle}', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Phần cấu trúc & Giải thích
          Card(
            elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cấu trúc & Giải thích', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: Icon(Icons.edit, color: Colors.amber, size: 20), onPressed: () {}),
                    ],
                  ),
                  const Divider(),
                  Text('Công thức:', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                  Text(structure, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Giải thích:', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                  Text(explanation, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Danh sách Câu ví dụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, )),
          const SizedBox(height: 10),

          ...List.generate(examples.length, (index) {
            final ex = examples[index];
            return Card(
              elevation: 2, margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                title: Text(ex['sentence']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex['translation']!, style: TextStyle(color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Highlight: ${ex['highlight']}', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _showExampleFormDialog(existingExample: ex, index: index)),
                    IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => examples.removeAt(index))),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        onPressed: () => _showExampleFormDialog(),
        icon: Icon(Icons.add, color: Theme.of(context).cardColor),
        label: Text('Thêm Ví dụ', style: TextStyle(color: Theme.of(context).cardColor)),
      ),
    );
  }
}