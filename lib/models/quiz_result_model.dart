class QuizResult {
  final String id;
  final String userId;
  final String topicId;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeTakenSeconds; // Thời gian làm bài tính bằng giây
  final List<String> wrongQuestionIds; // Danh sách ID các câu sai để review lại

  QuizResult({
    required this.id, required this.userId, required this.topicId,
    required this.correctAnswers, required this.wrongAnswers,
    required this.timeTakenSeconds, required this.wrongQuestionIds
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      topicId: json['topicId'] ?? '',
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      timeTakenSeconds: json['timeTakenSeconds'] ?? 0,
      wrongQuestionIds: List<String>.from(json['wrongQuestionIds'] ?? []),
    );
  }
}