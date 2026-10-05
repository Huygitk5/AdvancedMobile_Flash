import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/quiz_review_model.dart';
import '../../providers/content_providers.dart';

/// Dựng từ `quiz_attempt_answers` ⨝ `quiz_questions` (đọc được offline).
class QuizReviewScreen extends ConsumerWidget {
  final String attemptId;

  const QuizReviewScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(quizReviewProvider(attemptId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài làm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        elevation: 0,
        centerTitle: true,
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không đọc được bài làm: $e')),
        data: (reviewData) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reviewData.length,
          itemBuilder: (context, index) => _QuestionReviewCard(questionIndex: index + 1, data: reviewData[index]),
        ),
      ),
    );
  }
}

class _QuestionReviewCard extends StatefulWidget {
  final int questionIndex;
  final QuizReviewItem data; // Sử dụng Model QuizReviewItem

  const _QuestionReviewCard({required this.questionIndex, required this.data});

  @override
  State<_QuestionReviewCard> createState() => _QuestionReviewCardState();
}

class _QuestionReviewCardState extends State<_QuestionReviewCard> {
  bool isExpanded = true; // Biến quản lý trạng thái đóng/mở giải thích
  final List<String> optionLetters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final int correctIndex = widget.data.correctIndex;
    final int userIndex = widget.data.userIndex;
    final bool isCorrect = widget.data.isCorrect;

    // Màu sắc chủ đạo của thẻ
    final Color cardBgColor = isCorrect ? const Color(0xFFEDF7ED) : const Color(0xFFFDEDED);
    final Color cardBorderColor = isCorrect ? Colors.green.shade200 : Colors.red.shade200;
    final Color mainThemeColor = isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dòng tiêu đề câu hỏi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: mainThemeColor,
                child: Text('${widget.questionIndex}', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.data.question,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: mainThemeColor, size: 16),
                    const SizedBox(width: 4),
                    Text(isCorrect ? 'Đúng' : 'Sai', style: TextStyle(color: mainThemeColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Danh sách 4 đáp án
          ...List.generate(4, (index) {
            final String optionText = index < widget.data.options.length ? widget.data.options[index] : '';
            final bool isSelected = index == userIndex;
            final bool isActualCorrect = index == correctIndex;

            // Mặc định cho đáp án chưa chọn
            Color bgColor = Colors.white;
            Color textColor = AppTheme.greyColor;
            Color circleBgColor = Colors.grey.shade200;
            Color circleTextColor = AppTheme.greyColor;
            IconData? trailingIcon;
            Color? iconColor;

            if (isSelected && isActualCorrect) {
              // User chọn ĐÚNG
              bgColor = const Color(0xFFE8F5E9);
              textColor = const Color(0xFF2E7D32);
              circleBgColor = const Color(0xFF4CAF50);
              circleTextColor = Colors.white;
              trailingIcon = Icons.check;
              iconColor = const Color(0xFF2E7D32);
            } else if (isSelected && !isActualCorrect) {
              // User chọn SAI
              bgColor = const Color(0xFFFFEBEE);
              textColor = const Color(0xFFC62828);
              circleBgColor = const Color(0xFFEF5350);
              circleTextColor = Colors.white;
              trailingIcon = Icons.close;
              iconColor = const Color(0xFFC62828);
            } else if (!isSelected && isActualCorrect) {
              // Đáp án đúng thực sự (nhưng user không chọn)
              bgColor = Colors.white;
              textColor = const Color(0xFF2E7D32);
              circleBgColor = const Color(0xFFE8F5E9);
              circleTextColor = const Color(0xFF2E7D32);
              trailingIcon = Icons.check;
              iconColor = const Color(0xFF2E7D32);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? bgColor : Colors.white),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: circleBgColor,
                    child: Text(optionLetters[index], style: TextStyle(color: circleTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(color: textColor, fontWeight: (isSelected || isActualCorrect) ? FontWeight.bold : FontWeight.normal, fontSize: 15),
                    ),
                  ),
                  if (trailingIcon != null) Icon(trailingIcon, color: iconColor, size: 20),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 10),

          // 3. Nút Đóng/Mở Giải thích
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: mainThemeColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Giải thích', style: TextStyle(color: mainThemeColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: mainThemeColor, size: 20),
                ],
              ),
            ),
          ),

          // 4. Nội dung giải thích có hiệu ứng
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 28.0),
              child: Text(
                widget.data.explanation,
                style: TextStyle( fontSize: 14, height: 1.5),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}