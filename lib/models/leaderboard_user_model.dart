class LeaderboardUser {
  final String id;
  final String name;
  final int totalLifetimeXp;
  final int longestStreak;
  String note;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.totalLifetimeXp,
    required this.longestStreak,
    required this.note,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      totalLifetimeXp: json['totalLifetimeXp'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      note: json['note'] ?? '',
    );
  }
}