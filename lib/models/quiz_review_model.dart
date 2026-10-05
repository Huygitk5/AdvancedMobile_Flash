import '_json.dart';

/// Khớp `QuizReviewItemResponse`.
class QuizReviewItem {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;

  /// -1 nếu bỏ qua.
  final int userIndex;
  final bool isCorrect;
  final String explanation;

  const QuizReviewItem({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.userIndex,
    required this.isCorrect,
    required this.explanation,
  });

  factory QuizReviewItem.fromJson(Map<String, dynamic> j) => QuizReviewItem(
        id: jStr(j['id']),
        question: jStr(j['question']),
        options: (j['options'] as List? ?? const []).map((e) => e.toString()).toList(),
        correctIndex: jInt(j['correctIndex']),
        userIndex: jInt(j['userIndex'], -1),
        isCorrect: jBool(j['isCorrect']),
        explanation: jStr(j['explanation']),
      );
}
