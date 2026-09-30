import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/flashcard_model.dart';

class VocabularyBottomSheet {
  static void show(BuildContext context, Flashcard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Từ vựng', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.greyColor),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(card.word, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                const Icon(Icons.volume_up, color: AppTheme.primaryColor, size: 28),
              ],
            ),
            const SizedBox(height: 5),
            Text(card.pronunciation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('(${card.partOfSpeech})', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),                const SizedBox(width: 8),
                Text(card.meaning, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Color(0xFFF4F6FA), thickness: 1.5),
            ),
            const Text('Ví dụ:', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(card.example, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(card.exampleTranslation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.greyColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.bookmark_outline, color: Color(0xFF1E293B)),
                label: const Text('Thêm vào danh sách', style: TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20), // Tương thích các dòng máy không có viền đáy
          ],
        ),
      ),
    );
  }
}