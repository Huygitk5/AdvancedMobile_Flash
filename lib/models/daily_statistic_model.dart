class DailyStatistic {
  final String id;
  final String userId;
  final DateTime date;
  final int wordsLearned;
  final int xpGained;

  DailyStatistic({
    required this.id, required this.userId, required this.date,
    required this.wordsLearned, required this.xpGained
  });

  factory DailyStatistic.fromJson(Map<String, dynamic> json) {
    return DailyStatistic(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      wordsLearned: json['wordsLearned'] ?? 0,
      xpGained: json['xpGained'] ?? 0,
    );
  }
}