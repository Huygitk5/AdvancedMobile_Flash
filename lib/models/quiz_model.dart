class QuizQuestion {
  final String id;
  final String topicId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation; // THÊM TRƯỜNG NÀY ĐỂ LƯU GIẢI THÍCH

  QuizQuestion({
    required this.id,
    required this.topicId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation, // BẮT BUỘC TRUYỀN
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      topicId: json['topicId'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}