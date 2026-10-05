import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';

/// Sửa / xoá từng thẻ gọi API ngay.
class AdminFlashcardsScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String topicTitle;

  const AdminFlashcardsScreen({super.key, required this.topicId, required this.topicTitle});

  @override
  ConsumerState<AdminFlashcardsScreen> createState() => _AdminFlashcardsScreenState();
}

class _AdminFlashcardsScreenState extends ConsumerState<AdminFlashcardsScreen> {
  Future<List<Flashcard>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() { _future = ref.read(adminApiProvider).flashcards(widget.topicId); });

  Future<void> _deleteFlashcard(Flashcard card) async {
    if (!await confirmDelete(context, 'từ "${card.word}"')) return;
    if (!mounted) return;
    if (await adminRun(context, () => ref.read(adminApiProvider).deleteFlashcard(card.id), success: 'Đã xóa từ vựng!')) _load();
  }

  void _showFlashcardFormDialog({Flashcard? existingCard}) {
    final wordController = TextEditingController(text: existingCard?.word ?? '');
    final typeController = TextEditingController(text: existingCard?.partOfSpeech ?? 'n.');
    final pronunciationController = TextEditingController(text: existingCard?.pronunciation ?? '');
    final meaningController = TextEditingController(text: existingCard?.meaning ?? '');
    final exampleController = TextEditingController(text: existingCard?.example ?? '');
    final transController = TextEditingController(text: existingCard?.exampleTranslation ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingCard == null ? 'Thêm Từ vựng' : 'Sửa Từ vựng', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: wordController, decoration: adminInputDeco('Từ vựng (Word)')),
              const SizedBox(height: 10),
              TextField(controller: typeController, decoration: adminInputDeco('Từ loại (n., v., adj.)')),
              const SizedBox(height: 10),
              TextField(controller: pronunciationController, decoration: adminInputDeco('Phiên âm')),
              const SizedBox(height: 10),
              TextField(controller: meaningController, decoration: adminInputDeco('Nghĩa tiếng Việt')),
              const SizedBox(height: 10),
              TextField(controller: exampleController, maxLines: 2, decoration: adminInputDeco('Câu ví dụ')),
              const SizedBox(height: 10),
              TextField(controller: transController, maxLines: 2, decoration: adminInputDeco('Dịch nghĩa ví dụ')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
              final body = {
                'topicId': widget.topicId,
                'word': wordController.text.trim(),
                'partOfSpeech': typeController.text.trim(),
                'pronunciation': pronunciationController.text.trim(),
                'meaning': meaningController.text.trim(),
                'example': opt(exampleController),
                'exampleTranslation': opt(transController),
                'audioUrl': existingCard?.audioUrl,
                'imageUrl': existingCard?.imageUrl,
                'sortOrder': existingCard?.sortOrder,
              };
              final api = ref.read(adminApiProvider);
              final ok = await adminRun(context, () => existingCard == null
                  ? api.createFlashcard(body)
                  : api.updateFlashcard(existingCard.id, body), success: 'Đã lưu từ vựng');
              if (ok) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _load();
              }
            },
            child: Text('Lưu', style: TextStyle(color: Theme.of(dialogContext).cardColor)),
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
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Từ vựng: ${widget.topicTitle}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: AdminAsync<List<Flashcard>>(
        future: _future,
        onRetry: _load,
        builder: (flashcards) => flashcards.isEmpty
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
                          Flexible(child: Text(card.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          const SizedBox(width: 8),
                          Text('(${card.partOfSpeech})', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(card.meaning, style: const TextStyle(fontSize: 15)),
                          if ((card.example ?? '').isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text('VD: ${card.example}', style: const TextStyle(color: AppTheme.greyColor, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _showFlashcardFormDialog(existingCard: card)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteFlashcard(card)),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
