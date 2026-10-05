import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../data/content_repository.dart';
import '../../data/study_repository.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/common.dart';

/// Toàn bộ từ vựng người dùng đã lưu (dấu trang trên thẻ từ).
class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  List<Flashcard> _words = const [];
  bool _loading = true;
  String? _error;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _words.isEmpty;
      _error = null;
    });
    try {
      final words = await ContentRepository.allPages<Flashcard>((page) => ContentRepository.bookmarks(page: page, size: 100));
      if (!mounted) return;
      setState(() {
        _words = words;
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

  Future<void> _remove(Flashcard word) async {
    try {
      await StudyRepository.setBookmark(word, false);
      if (!mounted) return;
      setState(() => _words = _words.where((w) => w.id != word.id).toList());
      showAppSnack(context, tr('Đã bỏ lưu từ'), icon: Icons.bookmark_remove);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  Future<void> _speak(Flashcard word) async {
    final ok = await SpeechService.speak(word.word);
    if (!ok && mounted) {
      showAppSnack(context, AppSettings.soundEnabled ? tr('Thiết bị chưa hỗ trợ đọc từ vựng') : tr('Âm thanh đang tắt trong Cài đặt'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Từ đã lưu'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _words.isEmpty
                  ? EmptyView(message: tr('Chưa có từ nào được lưu'), icon: Icons.bookmark_border)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
                        itemCount: _words.length,
                        itemBuilder: (context, i) => _wordCard(context, _words[i]),
                      ),
                    ),
    );
  }

  Widget _wordCard(BuildContext context, Flashcard word) {
    final open = _expanded.contains(word.id);
    return GestureDetector(
      onTap: () => setState(() => open ? _expanded.remove(word.id) : _expanded.add(word.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${word.word}  ${word.partOfSpeech.isEmpty ? '' : '(${word.partOfSpeech})'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 2),
                      Text(word.pronunciation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(word.meaning, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: tr('Nghe phát âm'),
                  icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                  onPressed: () => _speak(word),
                ),
                IconButton(
                  tooltip: tr('Bỏ lưu'),
                  icon: Icon(Icons.bookmark, color: Colors.amber.shade700),
                  onPressed: () => _remove(word),
                ),
              ],
            ),
            if (open && word.example.isNotEmpty) ...[
              const Divider(height: 18),
              Text(word.example, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
              const SizedBox(height: 4),
              Text(word.exampleTranslation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }
}
