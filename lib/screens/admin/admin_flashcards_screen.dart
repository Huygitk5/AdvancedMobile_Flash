import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'admin_common.dart';

/// Quản lý từ vựng của một chủ đề. Sửa / xoá từng thẻ gọi API ngay.
class AdminFlashcardsScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String topicTitle;

  const AdminFlashcardsScreen({super.key, required this.topicId, required this.topicTitle});

  @override
  ConsumerState<AdminFlashcardsScreen> createState() => _AdminFlashcardsScreenState();
}

class _AdminFlashcardsScreenState extends ConsumerState<AdminFlashcardsScreen> {
  Future<List<Flashcard>>? _future;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() {
        _future = ref.read(adminApiProvider).flashcards(widget.topicId);
      });

  Future<void> _delete(Flashcard card) async {
    if (!await confirmDelete(context, card.word)) return;
    if (!mounted) return;
    if (await adminRun(context, () => ref.read(adminApiProvider).deleteFlashcard(card.id), success: tr('Đã xóa từ vựng!'))) _load();
  }

  Future<void> _openForm([Flashcard? card]) async {
    final saved = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => FlashcardFormScreen(topicId: widget.topicId, existing: card)));
    if (saved == true) _load();
  }

  bool _match(Flashcard c) {
    final k = _keyword.toLowerCase();
    return c.word.toLowerCase().contains(k) || c.meaning.toLowerCase().contains(k);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(trf('Từ vựng: {t}', {'t': widget.topicTitle}),
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: AdminAsync<List<Flashcard>>(
        future: _future,
        onRetry: _load,
        builder: (cards) {
          final shown = cards.where(_match).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: adminSearchField(context, hint: tr('Tìm từ vựng...'), onChanged: (v) => setState(() => _keyword = v)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(trf('{n} từ', {'n': cards.length}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _load();
                    await _future;
                  },
                  child: shown.isEmpty
                      ? ListView(children: [
                          SizedBox(
                              height: 260,
                              child: EmptyView(message: tr('Chưa có từ vựng nào trong chủ đề này.'), icon: Icons.style_outlined)),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                          itemCount: shown.length,
                          itemBuilder: (context, i) => _cardTile(shown[i]),
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(tr('Thêm từ'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _cardTile(Flashcard card) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Row(
          children: [
            Flexible(child: Text(card.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(width: 8),
            if (card.partOfSpeech.isNotEmpty)
              Text('(${card.partOfSpeech})',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            if (card.pronunciation.isNotEmpty) Text(card.pronunciation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
            Text(card.meaning, style: const TextStyle(fontSize: 15)),
            if ((card.example ?? '').isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(trf('VD: {e}', {'e': card.example!}),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.greyColor, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openForm(card)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(card)),
          ],
        ),
      ),
    );
  }
}

class FlashcardFormScreen extends ConsumerStatefulWidget {
  final String topicId;
  final Flashcard? existing;

  const FlashcardFormScreen({super.key, required this.topicId, this.existing});

  @override
  ConsumerState<FlashcardFormScreen> createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends ConsumerState<FlashcardFormScreen> {
  late final TextEditingController _word = TextEditingController(text: widget.existing?.word ?? '');
  late final TextEditingController _pos = TextEditingController(text: widget.existing?.partOfSpeech ?? 'n.');
  late final TextEditingController _ipa = TextEditingController(text: widget.existing?.pronunciation ?? '');
  late final TextEditingController _meaning = TextEditingController(text: widget.existing?.meaning ?? '');
  late final TextEditingController _example = TextEditingController(text: widget.existing?.example ?? '');
  late final TextEditingController _translation = TextEditingController(text: widget.existing?.exampleTranslation ?? '');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_word, _pos, _ipa, _meaning, _example, _translation]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (_word.text.trim().isEmpty || _meaning.text.trim().isEmpty || _ipa.text.trim().isEmpty || _pos.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập từ, loại từ, phiên âm và nghĩa'), error: true);
      return;
    }
    final existing = widget.existing;
    // Server thay toàn bộ: giữ lại audio / ảnh / thứ tự cũ.
    final body = {
      'topicId': widget.topicId,
      'word': _word.text.trim(),
      'partOfSpeech': _pos.text.trim(),
      'pronunciation': _ipa.text.trim(),
      'meaning': _meaning.text.trim(),
      'example': _opt(_example),
      'exampleTranslation': _opt(_translation),
      'audioUrl': existing?.audioUrl,
      'imageUrl': existing?.imageUrl,
      'sortOrder': existing?.sortOrder,
    };
    final api = ref.read(adminApiProvider);
    setState(() => _saving = true);
    final ok = await adminRun(context, () => existing == null ? api.createFlashcard(body) : api.updateFlashcard(existing.id, body),
        success: tr('Đã lưu từ vựng'));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormShell(
      title: widget.existing == null ? tr('Thêm từ vựng') : tr('Sửa từ vựng'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _word, decoration: formDecoration(tr('Từ vựng'))),
        formGap(),
        TextField(controller: _pos, decoration: formDecoration(tr('Loại từ'), hint: 'n. / v. / adj.')),
        formGap(),
        TextField(controller: _ipa, decoration: formDecoration(tr('Phiên âm'), hint: '/ˈbjuːtɪfl/')),
        formGap(),
        TextField(controller: _meaning, decoration: formDecoration(tr('Nghĩa'))),
        formGap(),
        TextField(controller: _example, maxLines: 2, decoration: formDecoration(tr('Câu ví dụ'))),
        formGap(),
        TextField(controller: _translation, maxLines: 2, decoration: formDecoration(tr('Dịch câu ví dụ'))),
      ],
    );
  }
}
