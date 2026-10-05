import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../data/content_repository.dart';
import '../../data/study_repository.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/common.dart';
import '../home/completion_screen.dart';

/// Học một chủ đề bằng thẻ ghi nhớ. Mỗi lần chấm "Know" / "Again" gửi lên server (SRS + XP),
/// chấm thẻ cuối cùng thì ghi nhận hoàn thành bài học.
class FlashcardScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const FlashcardScreen({super.key, required this.topicId, required this.topicTitle});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> _cards = const [];
  int _index = 0;
  bool _isFlipped = false;
  bool _loading = true;
  bool _rating = false;
  String? _error;

  final Stopwatch _session = Stopwatch()..start();
  DateTime _cardShownAt = DateTime.now();
  int _reviewed = 0;
  int _xpEarned = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    SpeechService.stop();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cards = await ContentRepository.flashcards(widget.topicId);
      if (!mounted) return;
      // Tiếp tục từ thẻ đầu tiên chưa thuộc; đã thuộc hết thì ôn lại từ đầu
      final firstNew = cards.indexWhere((c) => !c.isLearned);
      setState(() {
        _cards = cards;
        _index = firstNew < 0 ? 0 : firstNew;
        _loading = false;
        _cardShownAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  Flashcard get _card => _cards[_index];

  void _goTo(int index) {
    setState(() {
      _index = index;
      _isFlipped = false;
      _cardShownAt = DateTime.now();
    });
  }

  Future<void> _rate(bool know) async {
    if (_rating) return;
    setState(() => _rating = true);
    final card = _card;
    try {
      final outcome = await StudyRepository.review(card,
          know: know, responseTimeMs: DateTime.now().difference(_cardShownAt).inMilliseconds);
      _reviewed++;
      _xpEarned += outcome.xpAwarded;
      if (!mounted) return;
      if (outcome.xpAwarded > 0) {
        showAppSnack(context, '+${outcome.xpAwarded} XP', icon: Icons.stars);
      }
      if (_index < _cards.length - 1) {
        setState(() => _rating = false);
        _goTo(_index + 1);
      } else {
        await _finish();
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _rating = false);
    }
  }

  Future<void> _finish() async {
    int lessonXp = 0;
    try {
      final lesson = await StudyRepository.completeLesson(
        topicId: widget.topicId,
        cardsReviewed: _reviewed,
        durationSeconds: _session.elapsed.inSeconds,
      );
      lessonXp = lesson.xpAwarded;
    } catch (_) {
      // Việc ôn thẻ đã được lưu; chỉ không ghi nhận được lượt hoàn thành bài
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CompletionScreen(
          title: widget.topicTitle,
          xpEarned: _xpEarned + lessonXp,
          topicId: widget.topicId,
        ),
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    final card = _card;
    final target = !card.isBookmarked;
    setState(() => card.isBookmarked = target); // cập nhật ngay, lỗi thì hoàn lại
    try {
      await StudyRepository.setBookmark(card, target);
      if (mounted) {
        showAppSnack(context, target ? tr('Đã lưu từ vào danh sách của bạn') : tr('Đã bỏ lưu từ'),
            icon: target ? Icons.bookmark_added : Icons.bookmark_remove);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => card.isBookmarked = !target);
      showAppSnack(context, errorMessage(e), error: true);
    }
  }

  Future<void> _speak() async {
    final ok = await SpeechService.speak(_card.word);
    if (ok || !mounted) return;
    showAppSnack(
      context,
      AppSettings.soundEnabled ? tr('Thiết bị chưa hỗ trợ đọc từ vựng') : tr('Âm thanh đang tắt trong Cài đặt'),
      error: true,
    );
  }

  void _showNoteDialog(Flashcard card) {
    final controller = TextEditingController(text: card.note);
    showDialog(
      context: context,
      builder: (dialogContext) {
        var saving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(trf('Ghi chú cho "{w}"', {'w': card.word}), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: tr('Nhập mẹo nhớ, ngữ cảnh sử dụng...'),
                hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: saving
                    ? null
                    : () async {
                        setDialogState(() => saving = true);
                        try {
                          await StudyRepository.saveNote(card, controller.text);
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                          if (mounted) setState(() {});
                        } catch (e) {
                          setDialogState(() => saving = false);
                          if (mounted) showAppSnack(this.context, errorMessage(e), error: true);
                        }
                      },
                child: Text(tr('Lưu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(widget.topicTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_cards.isEmpty) return EmptyView(message: tr('Chủ đề này chưa có từ vựng'), icon: Icons.style_outlined);
    final card = _card;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Phần cố định bên dưới thẻ (tiến độ, nút Again/Know, ghi chú) cao khoảng 290px
        final cardHeight = (constraints.maxHeight - 290).clamp(300.0, double.infinity);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
            child: Column(
              children: [
                _buildProgressSection(),
                const SizedBox(height: 18),
                SizedBox(
                  height: cardHeight,
                  child: Row(
                    children: [
                      _buildNavButton(Icons.chevron_left, () => _goTo(_index - 1), _index > 0),
                      const SizedBox(width: 6),
                      Expanded(child: _buildAnimatedFlashcard(card)),
                      const SizedBox(width: 6),
                      _buildNavButton(Icons.chevron_right, () => _goTo(_index + 1), _index < _cards.length - 1),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 16),
                _buildNoteSection(card),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_index + 1}/${_cards.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Flexible(
              child: Text(
                _card.isLearned ? tr('Đã thuộc') : tr('Chưa thuộc'),
                style: TextStyle(color: _card.isLearned ? Colors.green : AppTheme.greyColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_index + 1) / _cards.length,
          backgroundColor: Colors.grey.shade300,
          color: AppTheme.primaryColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildAnimatedFlashcard(Flashcard card) {
    return GestureDetector(
      onTap: () => setState(() => _isFlipped = !_isFlipped),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(card.id),
        tween: Tween<double>(begin: _isFlipped ? 1 : 0, end: _isFlipped ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          final isUnder = value > 0.5;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi),
            alignment: Alignment.center,
            child: isUnder
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardContainer(card, isBack: true),
                  )
                : _buildCardContainer(card, isBack: false),
          );
        },
      ),
    );
  }

  Widget _buildCardContainer(Flashcard card, {required bool isBack}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              child: isBack ? _buildBackContent(card) : _buildFrontContent(card),
            ),
          ),
          // Nút lưu từ ở góc trên bên trái
          Positioned(
            top: 12,
            left: 12,
            child: _roundIconButton(
              icon: card.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: card.isBookmarked ? Colors.amber.shade700 : AppTheme.primaryColor,
              bg: card.isBookmarked ? Colors.amber.shade50 : Colors.blue.shade50,
              tooltip: tr('Lưu từ'),
              onTap: _toggleBookmark,
            ),
          ),
          // Nút loa ở góc trên bên phải: đọc to từ vựng
          Positioned(
            top: 12,
            right: 12,
            child: _roundIconButton(
              icon: Icons.volume_up,
              color: AppTheme.primaryColor,
              bg: Colors.blue.shade50,
              tooltip: tr('Nghe phát âm'),
              onTap: _speak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({required IconData icon, required Color color, required Color bg, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _posChip(Flashcard card) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
      child: Text('(${card.partOfSpeech})', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildFrontContent(Flashcard card) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card.word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(card.pronunciation, style: const TextStyle(fontSize: 18, color: AppTheme.greyColor)),
            const SizedBox(height: 20),
            _posChip(card),
            const SizedBox(height: 18),
            Text(tr('Chạm vào thẻ để xem nghĩa'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackContent(Flashcard card) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 44),
          Text(card.word, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(card.pronunciation, style: const TextStyle(fontSize: 16, color: AppTheme.greyColor)),
          const SizedBox(height: 12),
          _posChip(card),
          const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider(color: Color(0xFFEEF2FF), thickness: 1.5)),
          Text(card.meaning, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (card.example.isNotEmpty) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Ví dụ:'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(card.example, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(card.exampleTranslation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap, bool isActive) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).cardColor : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
        ),
        child: Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey.shade400),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            title: 'Again',
            subtitle: tr('Chưa nhớ'),
            icon: Icons.refresh,
            color: const Color(0xFFFF4D4F),
            bgColor: const Color(0xFFFFF1F0),
            onTap: () => _rate(false),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            title: 'Know',
            subtitle: tr('Đã nhớ'),
            icon: Icons.check,
            color: const Color(0xFF52C41A),
            bgColor: const Color(0xFFF6FFED),
            onTap: () => _rate(true),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: _rating ? 0.5 : 1,
      child: GestureDetector(
        onTap: _rating ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection(Flashcard card) {
    final hasNote = (card.note ?? '').isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showNoteDialog(card),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasNote ? Theme.of(context).cardColor : (isDark ? const Color(0xFF273449) : const Color(0xFFEEF2FF)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: hasNote ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: hasNote ? Colors.blue.shade50 : Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.edit_note, color: hasNote ? AppTheme.primaryColor : Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Ghi chú cá nhân'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    hasNote ? card.note! : tr('Nhấn vào để thêm ghi chú cho từ này...'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasNote ? null : AppTheme.greyColor,
                      fontSize: 13,
                      fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Icon(hasNote ? Icons.edit : Icons.add_circle_outline, color: AppTheme.greyColor, size: 20),
          ],
        ),
      ),
    );
  }
}
