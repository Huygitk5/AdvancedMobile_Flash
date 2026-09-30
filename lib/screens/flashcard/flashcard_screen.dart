import 'dart:math'; // Import thêm thư viện toán học để dùng hằng số pi
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/flashcard_model.dart';
import '../../core/theme.dart';

class FlashcardScreen extends StatefulWidget {
  final String topicTitle;

  const FlashcardScreen({Key? key, required this.topicTitle}) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;

  void _nextCard() {
    if (currentIndex < MockData.flashcards.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hoàn thành bài học! Chuẩn bị kiểm tra.')),
      );
    }
  }

  void _prevCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isFlipped = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    Flashcard currentCard = MockData.flashcards[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.topicTitle,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
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
                    _buildNavButton(Icons.chevron_right, _nextCard, currentIndex < MockData.flashcards.length - 1),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildPaginationDots(),
              const SizedBox(height: 25),
              _buildActionButtons(),
              const SizedBox(height: 20),
              _buildNoteSection(),
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
              '${currentIndex + 1}/${MockData.flashcards.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Bài học: ${widget.topicTitle}',
              style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentIndex + 1) / MockData.flashcards.length,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
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
                // Xử lý phát âm thanh
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up, color: AppTheme.primaryColor, size: 20),
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
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          card.pronunciation,
          style: const TextStyle(fontSize: 18, color: AppTheme.greyColor),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '(n.)',
            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
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
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            card.pronunciation,
            style: const TextStyle(fontSize: 16, color: AppTheme.greyColor),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '(n.)',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFEEF2FF), thickness: 1.5),
          ),

          Text(
            card.meaning,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ví dụ:', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  card.example,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B), fontWeight: FontWeight.w500, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  card.exampleTranslation,
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4),
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
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : null,
        ),
        child: Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey.shade400),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        MockData.flashcards.length,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 8 : 6,
          height: currentIndex == index ? 8 : 6,
          decoration: BoxDecoration(
            color: currentIndex == index ? AppTheme.primaryColor : Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
        ),
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
            onTap: _nextCard,
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
            onTap: _nextCard,
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
          border: Border.all(color: color.withOpacity(0.3)),
        ),
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
                Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.star, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('Nhấn để thêm ghi chú cho từ này', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: AppTheme.greyColor, size: 20),
        ],
      ),
    );
  }
}