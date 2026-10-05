import 'dart:math'; // Import thêm thư viện toán học để dùng hằng số pi
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/vocabulary_bottom_sheet.dart';
import '../home/completion_screen.dart';
import '../quiz/quiz_screen.dart';

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
  bool _busy = false;

  int get _count => _order?.length ?? 0;
  Flashcard? get _current => _count == 0 ? null : _cards[_order![currentIndex]];

  void _goTo(int index) {
    setState(() {
      currentIndex = index;
      isFlipped = false;
      _shownAt = Clock.now();
    });
  }

  void _nextCard() {
    if (currentIndex < _count - 1) _goTo(currentIndex + 1);
  }

  void _prevCard() {
    if (currentIndex > 0) _goTo(currentIndex - 1);
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      // responseTimeMs đo từ lúc lật thẻ tới lúc bấm Again / Know.
      if (isFlipped) _shownAt = Clock.now();
    });
  }

  /// Again / Know: ghi lạc quan + enqueue FLASHCARD_REVIEW, rồi sang thẻ tiếp; thẻ cuối -> hoàn thành bài.
  Future<void> _rate(String rating) async {
    final card = _current;
    if (card == null || _busy) return;
    _busy = true;
    try {
      final responseMs = Clock.now().difference(_shownAt).inMilliseconds.clamp(0, 3600000);
      await ref.read(srsRepositoryProvider).rate(card, rating, responseTimeMs: responseMs);
      _reviewed.add(card.id);
      if (!mounted) return;
      if (currentIndex < _count - 1) {
        _goTo(currentIndex + 1);
      } else {
        await _finishLesson();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      _busy = false;
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
        ),
      ),
    );
  }

  void _showNoteDialog(Flashcard card) {
    final noteController = TextEditingController(text: card.note);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            'Ghi chú cho "${card.word}"',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        content: TextField(
          controller: noteController,
          maxLines: 4, // Ô nhập liệu rộng 4 dòng
          maxLength: 5000,
          decoration: InputDecoration(
            hintText: 'Nhập mẹo nhớ, ngữ cảnh sử dụng...',
            hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF4F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          if (card.hasNote)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(noteRepositoryProvider).delete(card.id);
              },
              child: const Text('Xoá', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              // Ghi SQLite + NOTE_UPSERT; danh sách thẻ đang watch nên tự hiện ghi chú mới.
              ref.read(noteRepositoryProvider).save(card.id, noteController.text);
            },
            child: Text('Lưu', style: TextStyle(color: Theme.of(dialogContext).cardColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider(widget.topicId));
    final quiz = ref.watch(topicQuizProvider(widget.topicId)).value;
    final list = cards.value;
    if (list != null) {
      _cards = {for (final c in list) c.id: c};
      _order ??= list.map((c) => c.id).toList();
      // Thẻ bị xoá (admin gỡ khi đang học) thì bỏ khỏi thứ tự.
      _order!.removeWhere((id) => !_cards.containsKey(id));
      if (currentIndex >= _count && _count > 0) currentIndex = _count - 1;
    }
    final Flashcard? currentCard = _current;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,  size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.topicTitle,
          style: TextStyle(
            
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          if (quiz != null && quiz.questionCount > 0)
            IconButton(
              tooltip: 'Kiểm tra',
              icon: const Icon(Icons.quiz_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen(quizId: quiz.id, title: quiz.title)),
              ),
            ),
        ],
      ),
      body: currentCard == null
          ? Center(
              child: cards.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Chủ đề này chưa có từ vựng.', style: TextStyle(color: AppTheme.greyColor)),
            )
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              _buildProgressSection(),
              const SizedBox(height: 20),

              // Cụm Card
              Expanded(
                child: Row(
                  children: [
                    _buildNavButton(Icons.chevron_left, _prevCard, currentIndex > 0),
                    const SizedBox(width: 10),
                    Expanded(child: _buildAnimatedFlashcard(currentCard)),
                    const SizedBox(width: 10),
                    _buildNavButton(Icons.chevron_right, _nextCard, currentIndex < _count - 1),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildPaginationDots(),
              const SizedBox(height: 25),
              _buildActionButtons(),
              const SizedBox(height: 20),
              _buildNoteSection(currentCard),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currentIndex + 1}/$_count',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Bài học: ${widget.topicTitle}',
              style: TextStyle(color: AppTheme.greyColor, fontSize: 12),
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

  // Widget tạo hiệu ứng lật 3D
  Widget _buildAnimatedFlashcard(Flashcard card) {
    return GestureDetector(
      onTap: _flipCard,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isFlipped ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        builder: (context, value, child) {
          // value chạy từ 0 đến 1. Nếu > 0.5 tức là đã lật qua nửa chừng, ta hiện mặt sau.
          bool isUnder = value > 0.5;
          return Transform(
            // Ma trận xoay trục Y tạo hiệu ứng 3D
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Hiệu ứng chiều sâu (perspective)
              ..rotateY(value * pi),
            alignment: Alignment.center,
            child: isUnder
            // Khi hiển thị mặt sau, cần xoay ngược lại một góc pi (180 độ) để chữ không bị ngược
                ? Transform(
              transform: Matrix4.identity()..rotateY(pi),
              alignment: Alignment.center,
              child: _buildCardContainer(card, isBack: true),
            )
            // Mặt trước
                : _buildCardContainer(card, isBack: false),
          );
        },
      ),
    );
  }

  // Khung viền và cấu trúc chung của thẻ
  Widget _buildCardContainer(Flashcard card, {required bool isBack}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              child: isBack ? _buildBackContent(card) : _buildFrontContent(card),
            ),
          ),

          // Icon loa giữ nguyên cố định ở góc trên
          Positioned(
            top: 15,
            right: 15,
            child: GestureDetector(
              onTap: () {
                // Hiển thị Bottom Sheet chi tiết từ vựng
                VocabularyBottomSheet.show(
                  context,
                  card,
                  onToggleBookmark: () => ref.read(bookmarkRepositoryProvider).toggle(card.id),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.volume_up, color: AppTheme.primaryColor, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontContent(Flashcard card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.word,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          card.pronunciation,
          style: TextStyle(fontSize: 18, color: AppTheme.greyColor),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '(${card.partOfSpeech})', // Xóa chữ 'const' trước Text và dùng nội suy chuỗi
            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14), // Thêm 'const' vào TextStyle để tối ưu
          ),
        ),
      ],
    );
  }

  Widget _buildBackContent(Flashcard card) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text(
            card.word,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            card.pronunciation,
            style: TextStyle(fontSize: 16, color: AppTheme.greyColor),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '(${card.partOfSpeech})', // Xóa chữ 'const' trước Text và dùng nội suy chuỗi
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14), // Thêm 'const' vào TextStyle để tối ưu
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFEEF2FF), thickness: 1.5),
          ),

          Text(
            card.meaning,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ví dụ:', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  card.example ?? '',
                  style: TextStyle(fontSize: 16,  fontWeight: FontWeight.w500, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  card.exampleTranslation ?? '',
                  style: TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap, bool isActive) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
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
            subtitle: 'Chưa nhớ',
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
            subtitle: 'Đã nhớ',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Theme.of(context).cardColor, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Thêm tham số Flashcard card vào hàm
  Widget _buildNoteSection(Flashcard card) {
    // Kiểm tra xem thẻ này đã có ghi chú chưa
    final hasNote = card.hasNote;

    return GestureDetector(
      onTap: () => _showNoteDialog(card), // Mở hộp thoại khi bấm vào
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: hasNote ? Colors.white : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: hasNote ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.transparent),
          boxShadow: hasNote ? [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: hasNote ? Colors.blue.shade50 : Colors.white,
                  shape: BoxShape.circle
              ),
              child: Icon(Icons.edit_note, color: hasNote ? AppTheme.primaryColor : Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ghi chú cá nhân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, )),
                  const SizedBox(height: 4),
                  // Hiển thị ghi chú thật nếu có, ngược lại hiện chữ gợi ý
                  Text(
                    hasNote ? card.note! : 'Nhấn vào để thêm ghi chú cho từ này...',
                    style: TextStyle(
                      color: hasNote ? const Color(0xFF1E293B) : AppTheme.greyColor,
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