class QuizReviewItem {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int userIndex;
  final String explanation;

  QuizReviewItem({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.userIndex,
    required this.explanation,
  });

  factory QuizReviewItem.fromJson(Map<String, dynamic> json) {
    return QuizReviewItem(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      userIndex: json['userIndex'] ?? -1, // -1 nếu user không chọn đáp án nào
      explanation: json['explanation'] ?? '',
    );
  }
}