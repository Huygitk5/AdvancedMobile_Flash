class DailyStatistic {
  /// Ngày theo giờ địa phương (00:00).
  final DateTime date;
  final int wordsLearned;
  final int cardsReviewed;
  final int xpGained;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int correctAnswers;
  final int totalAnswers;
  final int studySeconds;

  const DailyStatistic({
    required this.date,
    this.wordsLearned = 0,
    this.cardsReviewed = 0,
    this.xpGained = 0,
    this.lessonsCompleted = 0,
    this.quizzesCompleted = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.studySeconds = 0,
  });
}
