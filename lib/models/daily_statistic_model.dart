import '../core/utils.dart';
import 'json_helpers.dart';

class DailyStatistic {
  final DateTime date;
  final int wordsLearned;
  final int cardsReviewed;
  final int xpGained;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int correctAnswers;
  final int totalAnswers;

  const DailyStatistic({
    required this.date,
    this.wordsLearned = 0,
    this.cardsReviewed = 0,
    this.xpGained = 0,
    this.lessonsCompleted = 0,
    this.quizzesCompleted = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
  });

  factory DailyStatistic.fromJson(Map<String, dynamic> json) => DailyStatistic(
        date: parseApiDate(jStrOrNull(json, 'date')) ?? DateTime.now(),
        wordsLearned: jInt(json, 'wordsLearned'),
        cardsReviewed: jInt(json, 'cardsReviewed'),
        xpGained: jInt(json, 'xpGained'),
        lessonsCompleted: jInt(json, 'lessonsCompleted'),
        quizzesCompleted: jInt(json, 'quizzesCompleted'),
        correctAnswers: jInt(json, 'correctAnswers'),
        totalAnswers: jInt(json, 'totalAnswers'),
      );
}

/// Phản hồi của /v1/users/me/statistics.
class Statistics {
  final String range;
  final DateTime from;
  final DateTime to;
  final List<DailyStatistic> daily;
  final double accuracy;
  final int xpGained;
  final int wordsLearned;
  final int studySeconds;
  final int streakDays;
  final int longestStreak;
  final int totalWordsLearned;

  const Statistics({
    required this.range,
    required this.from,
    required this.to,
    required this.daily,
    this.accuracy = 0,
    this.xpGained = 0,
    this.wordsLearned = 0,
    this.studySeconds = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.totalWordsLearned = 0,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    final now = dateOnly(DateTime.now());
    return Statistics(
      range: jStr(json, 'range'),
      from: parseApiDate(jStrOrNull(json, 'from')) ?? now,
      to: parseApiDate(jStrOrNull(json, 'to')) ?? now,
      daily: jList(json, 'daily').map(DailyStatistic.fromJson).toList(),
      accuracy: jDouble(json, 'accuracy'),
      xpGained: jInt(json, 'xpGained'),
      wordsLearned: jInt(json, 'wordsLearned'),
      studySeconds: jInt(json, 'studySeconds'),
      streakDays: jInt(json, 'streakDays'),
      longestStreak: jInt(json, 'longestStreak'),
      totalWordsLearned: jInt(json, 'totalWordsLearned'),
    );
  }
}
