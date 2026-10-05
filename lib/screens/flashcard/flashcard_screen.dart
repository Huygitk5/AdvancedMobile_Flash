import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../../core/speech.dart';
import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../home/completion_screen.dart';
import '../quiz/quiz_screen.dart';

/// Học một chủ đề bằng thẻ ghi nhớ. Mỗi lần chấm "Know" / "Again" ghi SQLite + FLASHCARD_REVIEW (SRS + XP ước lượng),
/// chấm thẻ cuối cùng thì ghi nhận hoàn thành bài học (LESSON_COMPLETE).
class FlashcardScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String topicTitle;

  const FlashcardScreen({super.key, required this.topicId, required this.topicTitle});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;

  /// Thứ tự thẻ chốt lúc mở màn (thẻ đến hạn trước). Danh sách từ SQLite vẫn được watch để cập nhật
  /// ghi chú / bookmark, nhưng không đảo thứ tự khi box thay đổi giữa buổi học.
  List<String>? _order;
  Map<String, Flashcard> _cards = const {};
  final Set<String> _reviewed = {};
  final DateTime _startedAt = Clock.now();
  DateTime _shownAt = Clock.now();
  bool _rating = false;

  int get _count => _order?.length ?? 0;
  Flashcard? get _current => _count == 0 ? null : _cards[_order![currentIndex]];

  @override
  void dispose() {
    SpeechService.stop();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() {
      currentIndex = index;
      isFlipped = false;
      _shownAt = Clock.now();
    });
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      // responseTimeMs đo từ lúc lật thẻ tới lúc bấm Again / Know.
      if (isFlipped) _shownAt = Clock.now();
    });
  }

  /// Lần đầu có dữ liệu: chốt thứ tự và tiếp tục từ thẻ đầu tiên cần học (đến hạn ôn hoặc chưa thuộc);
  /// đã thuộc hết và chưa đến hạn thì ôn lại từ đầu.
  void _initOrder(List<Flashcard> list) {
    _order = list.map((c) => c.id).toList();
    final now = Clock.now();
    final first = list.indexWhere((c) => !c.isLearned || (c.dueAt != null && !c.dueAt!.isAfter(now)));
    currentIndex = first < 0 ? 0 : first;
  }

  /// Again / Know: ghi lạc quan + enqueue FLASHCARD_REVIEW, rồi sang thẻ tiếp; thẻ cuối -> hoàn thành bài.
  Future<void> _rate(String rating) async {
    final card = _current;
    if (card == null || _rating) return;
    setState(() => _rating = true);
    try {
      final responseMs = Clock.now().difference(_shownAt).inMilliseconds.clamp(0, 3600000);
      final xp = await ref.read(srsRepositoryProvider).rate(card, rating, responseTimeMs: responseMs);
      _reviewed.add(card.id);
      if (!mounted) return;
      if (xp > 0) showAppSnack(context, '+$xp XP', icon: Icons.stars);
      if (currentIndex < _count - 1) {
        setState(() => _rating = false);
        _goTo(currentIndex + 1);
      } else {
        await _finishLesson();
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _rating = false);
    }
  }

  Future<void> _finishLesson() async {
    final r = await ref.read(lessonRepositoryProvider).completeTopic(
          widget.topicId,
          cardsReviewed: _reviewed.length,
          durationSeconds: Clock.now().difference(_startedAt).inSeconds,
        );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(
          lessonCompletionId: r.id,
          xpEstimate: r.xpEstimate,
          topicId: widget.topicId,
          title: widget.topicTitle,
        ),
      ),
    );
  }

  /// BOOKMARK_SET: ghi local ngay (danh sách thẻ đang watch nên tự đổi icon), đồng bộ sau.
  Future<void> _toggleBookmark(Flashcard card) async {
    try {
      final saved = await ref.read(bookmarkRepositoryProvider).toggle(card.id);
      if (mounted) {
        showAppSnack(context, saved ? tr('Đã lưu từ vào danh sách của bạn') : tr('Đã bỏ lưu từ'),
            icon: saved ? Icons.bookmark_added : Icons.bookmark_remove);
      }
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  Future<void> _speak(Flashcard card) async {
    final ok = await SpeechService.speak(card.word);
    if (ok || !mounted) return;
    showAppSnack(
      context,
      SpeechService.soundEnabled ? tr('Thiết bị chưa hỗ trợ đọc từ vựng') : tr('Âm thanh đang tắt trong Cài đặt'),
      error: true,
    );
  }


  void _showNoteDialog(Flashcard card) {
    final noteController = TextEditingController(text: card.note);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(trf('Ghi chú cho "{w}"', {'w': card.word}), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          maxLength: 5000,
          decoration: InputDecoration(
            hintText: tr('Nhập mẹo nhớ, ngữ cảnh sử dụng...'),
            hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
            filled: true,
            fillColor: Theme.of(dialogContext).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          if (card.hasNote)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(noteRepositoryProvider).delete(card.id);
              },
              child: Text(tr('Xóa'), style: const TextStyle(color: Colors.red)),
            ),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              Navigator.pop(dialogContext);
              // Ghi SQLite + NOTE_UPSERT; danh sách thẻ đang watch nên tự hiện ghi chú mới.
              ref.read(noteRepositoryProvider).save(card.id, noteController.text);
            },
            child: Text(tr('Lưu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((_) => noteController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider(widget.topicId));
    final quiz = ref.watch(topicQuizProvider(widget.topicId)).value;
    final list = cards.value;
    if (list != null) {
      _cards = {for (final c in list) c.id: c};
      if (_order == null) _initOrder(list);
      // Thẻ bị xoá (admin gỡ khi đang học) thì bỏ khỏi thứ tự.
      _order!.removeWhere((id) => !_cards.containsKey(id));
      if (currentIndex >= _count && _count > 0) currentIndex = _count - 1;
    }
    final currentCard = _current;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(widget.topicTitle,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          if (quiz != null && quiz.questionCount > 0)
            IconButton(
              tooltip: tr('Kiểm tra'),
              icon: const Icon(Icons.quiz_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen(quizId: quiz.id, title: quiz.title)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: currentCard == null
            ? (cards.isLoading
                ? const LoadingView()
                : EmptyView(message: tr('Chủ đề này chưa có từ vựng'), icon: Icons.style_outlined))
            : _body(context, currentCard),
      ),
    );
  }

  Widget _body(BuildContext context, Flashcard card) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Phần cố định bên dưới thẻ (tiến độ, chấm trang, nút Again/Know, ghi chú) cao khoảng 320px
        final cardHeight = (constraints.maxHeight - 320).clamp(300.0, double.infinity);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
            child: Column(
              children: [
                _buildProgressSection(card),
                const SizedBox(height: 18),
                SizedBox(
                  height: cardHeight,
                  child: Row(
                    children: [
                      _buildNavButton(Icons.chevron_left, () => _goTo(currentIndex - 1), currentIndex > 0),
                      const SizedBox(width: 6),
                      Expanded(child: _buildAnimatedFlashcard(card)),
                      const SizedBox(width: 6),
                      _buildNavButton(Icons.chevron_right, () => _goTo(currentIndex + 1), currentIndex < _count - 1),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaginationDots(),
                const SizedBox(height: 18),
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

  Widget _buildProgressSection(Flashcard card) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${currentIndex + 1}/$_count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Flexible(
              child: Text(
                card.isLearned ? tr('Đã thuộc') : tr('Chưa thuộc'),
                style: TextStyle(color: card.isLearned ? Colors.green : AppTheme.greyColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentIndex + 1) / _count,
          backgroundColor: Colors.grey.shade300,
          color: AppTheme.primaryColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  /// Lật thẻ 3D.
  Widget _buildAnimatedFlashcard(Flashcard card) {
    return GestureDetector(
      onTap: _flipCard,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(card.id),
        tween: Tween<double>(begin: isFlipped ? 1 : 0, end: isFlipped ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          // value > 0.5 tức là đã lật qua nửa chừng: hiện mặt sau (xoay ngược pi để chữ không bị ngược).
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
              onTap: () => _toggleBookmark(card),
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
              onTap: () => _speak(card),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton(
      {required IconData icon, required Color color, required Color bg, required String tooltip, required VoidCallback onTap}) {
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
      child: Text('(${card.partOfSpeech})',
          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
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
    final example = card.example ?? '';
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
          if (example.isNotEmpty) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Ví dụ:'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(example, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(card.exampleTranslation ?? '', style: const TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4)),
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

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        // Nhiều thẻ thì chỉ vẽ tối đa 12 chấm quanh thẻ hiện tại.
        min(_count, 12),
        (i) {
          final index = i + (_count <= 12 ? 0 : (currentIndex - 6).clamp(0, _count - 12));
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: currentIndex == index ? 8 : 6,
            height: currentIndex == index ? 8 : 6,
            decoration: BoxDecoration(
              color: currentIndex == index ? AppTheme.primaryColor : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
          );
        },
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
            onTap: () => _rate('AGAIN'),
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
            onTap: () => _rate('KNOW'),
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
    final hasNote = card.hasNote;
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
