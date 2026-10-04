import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/flashcard_model.dart';

class AdminFlashcardsScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const AdminFlashcardsScreen({Key? key, required this.topicId, required this.topicTitle}) : super(key: key);

  @override
  State<AdminFlashcardsScreen> createState() => _AdminFlashcardsScreenState();
}

class _AdminFlashcardsScreenState extends State<AdminFlashcardsScreen> {
  late List<Flashcard> flashcards;

  @override
  void initState() {
    super.initState();
    // Giả lập API GET /v1/flashcards?topicId=...
    flashcards = MockData.flashcards.where((f) => f.topicId == widget.topicId).toList();
  }

  void _deleteFlashcard(String flashcardId) {
    setState(() {
      flashcards.removeWhere((f) => f.id == flashcardId);
      MockData.flashcards.removeWhere((f) => f.id == flashcardId); // Cập nhật cả DB giả lập
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa từ vựng!'), backgroundColor: Colors.red));
  }

  void _showFlashcardFormDialog({Flashcard? existingCard}) {
    final wordController = TextEditingController(text: existingCard?.word ?? '');
    final typeController = TextEditingController(text: existingCard?.partOfSpeech ?? 'n.');
    final pronunciationController = TextEditingController(text: existingCard?.pronunciation ?? '');
    final meaningController = TextEditingController(text: existingCard?.meaning ?? '');
    final exampleController = TextEditingController(text: existingCard?.example ?? ''); // Thêm ô nhập Ví dụ
    final transController = TextEditingController(text: existingCard?.exampleTranslation ?? ''); // Thêm ô Dịch

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingCard == null ? 'Thêm Từ vựng' : 'Sửa Từ vựng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: wordController, decoration: InputDecoration(labelText: 'Từ vựng (Word)', filled: true, fillColor: const Color(0xFFF4F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 10),
              TextField(controller: typeController, decoration: InputDecoration(labelText: 'Từ loại (n., v., adj.)', filled: true, fillColor: const Color(0xFFF4F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 10),
              TextField(controller: pronunciationController, decoration: InputDecoration(labelText: 'Phiên âm', filled: true, fillColor: const Color(0xFFF4F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 10),
              TextField(controller: meaningController, decoration: InputDecoration(labelText: 'Nghĩa tiếng Việt', filled: true, fillColor: const Color(0xFFF4F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 10),
              TextField(controller: exampleController, maxLines: 2, decoration: InputDecoration(labelText: 'Câu ví dụ', filled: true, fillColor: const Color(0xFFF4F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 10),
              TextField(controller: transController, maxLines: 2, decoration: InputDecoration(labelText: 'Dịch nghĩa ví dụ', filled: true, fillColor: const Color(0xFFF4F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                if (existingCard == null) {
                  flashcards.add(Flashcard(id: DateTime.now().millisecondsSinceEpoch.toString(), topicId: widget.topicId, word: wordController.text, partOfSpeech: typeController.text, pronunciation: pronunciationController.text, meaning: meaningController.text, example: exampleController.text, exampleTranslation: transController.text));
                } else {
                  final index = flashcards.indexWhere((f) => f.id == existingCard.id);
                  flashcards[index] = Flashcard(id: existingCard.id, topicId: existingCard.topicId, word: wordController.text, partOfSpeech: typeController.text, pronunciation: pronunciationController.text, meaning: meaningController.text, example: exampleController.text, exampleTranslation: transController.text, note: existingCard.note);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,  size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Từ vựng: ${widget.topicTitle}', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: flashcards.isEmpty
          ? const Center(child: Text('Chưa có từ vựng nào trong chủ đề này.', style: TextStyle(color: AppTheme.greyColor)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final card = flashcards[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Row(
                children: [
                  Text(card.word, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, )),
                  const SizedBox(width: 8),
                  Text('(${card.partOfSpeech})', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(card.meaning, style: TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Text('VD: ${card.example}', style: TextStyle(color: AppTheme.greyColor, fontStyle: FontStyle.italic)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.amber),
                    onPressed: () => _showFlashcardFormDialog(existingCard: card),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFlashcard(card.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showFlashcardFormDialog(),
        icon: Icon(Icons.add, color: Theme.of(context).cardColor),
        label: Text('Thêm từ', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}