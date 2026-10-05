import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/admin_repository.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';

/// Quản lý từ vựng của một chủ đề.
class AdminFlashcardsScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const AdminFlashcardsScreen({super.key, required this.topicId, required this.topicTitle});

  @override
  State<AdminFlashcardsScreen> createState() => _AdminFlashcardsScreenState();
}

class _AdminFlashcardsScreenState extends State<AdminFlashcardsScreen> {
  List<Flashcard> _cards = const [];
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
      final cards = await AdminRepository.flashcards(widget.topicId);
      if (!mounted) return;
      setState(() {
        _cards = cards;
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

  Future<void> _delete(Flashcard card) async {
    if (!await confirmDelete(context, card.word)) return;
    try {
      await AdminRepository.deleteFlashcard(card.id);
      if (!mounted) return;
      showAppSnack(context, tr('Đã xóa từ vựng!'));
      _load();
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  Future<void> _openForm([Flashcard? card]) async {
    final saved = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => FlashcardFormScreen(topicId: widget.topicId, existing: card)));
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _cards.where((c) => c.word.toLowerCase().contains(_keyword.toLowerCase()) || c.meaning.toLowerCase().contains(_keyword.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(widget.topicTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: adminSearchField(context, hint: tr('Tìm từ vựng...'), onChanged: (v) => setState(() => _keyword = v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(alignment: Alignment.centerLeft, child: Text(trf('{n} từ', {'n': _cards.length}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12))),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : shown.isEmpty
                        ? EmptyView(message: tr('Chưa có từ vựng nào'), icon: Icons.style_outlined)
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                              itemCount: shown.length,
                              itemBuilder: (context, i) {
                                final card = shown[i];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: ListTile(
                                    title: Text('${card.word}  ${card.partOfSpeech.isEmpty ? '' : '(${card.partOfSpeech})'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${card.pronunciation}\n${card.meaning}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                    isThreeLine: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openForm(card)),
                                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(card)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class FlashcardFormScreen extends StatefulWidget {
  final String topicId;
  final Flashcard? existing;

  const FlashcardFormScreen({super.key, required this.topicId, this.existing});

  @override
  State<FlashcardFormScreen> createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends State<FlashcardFormScreen> {
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

  Future<void> _save() async {
    if (_word.text.trim().isEmpty || _meaning.text.trim().isEmpty || _ipa.text.trim().isEmpty || _pos.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập từ, loại từ, phiên âm và nghĩa'), error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await AdminRepository.saveFlashcard(widget.existing?.id, {
        'topicId': widget.topicId,
        'word': _word.text.trim(),
        'partOfSpeech': _pos.text.trim(),
        'pronunciation': _ipa.text.trim(),
        'meaning': _meaning.text.trim(),
        'example': _example.text.trim(),
        'exampleTranslation': _translation.text.trim(),
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
