/// Một lần làm quiz (dòng `quiz_attempts`). `id` = attemptId do client sinh.
class QuizResult {
  final String id;
  final String quizId;
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int scorePercent;
  final int passScorePercent;
  final int timeTakenSeconds;

  /// null = server chưa chấm (đang chờ đồng bộ).
  final int? xpAwarded;
  final DateTime submittedAt;
  final bool isSynced;

  const QuizResult({
    required this.id,
    required this.quizId,
    this.quizTitle = '',
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.scorePercent,
    this.passScorePercent = 70,
    required this.timeTakenSeconds,
    this.xpAwarded,
    required this.submittedAt,
    this.isSynced = false,
  });

  bool get passed => scorePercent >= passScorePercent;
}
