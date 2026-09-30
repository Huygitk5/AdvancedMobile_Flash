class QuizQuestion {
  final String id;
  final String topicId;
  final String questionText;
  final List<String> options; // Danh sách 4 đáp án (A, B, C, D)
  final int correctAnswerIndex; // Vị trí đáp án đúng (0, 1, 2, 3)

  QuizQuestion({
    required this.id,
    required this.topicId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      topicId: json['topicId'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
    );
  }
}