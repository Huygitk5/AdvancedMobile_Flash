class LeaderboardUser {
  final String id;
  final String name;
  final int totalXp;
  final int longestStreak;
  final String note;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.totalXp,
    required this.longestStreak,
    required this.note,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      totalXp: json['totalXp'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      note: json['note'] ?? '',
    );
  }
}