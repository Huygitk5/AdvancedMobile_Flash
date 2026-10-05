import '_json.dart';

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String slogan;

  /// ARGB, rỗng = không trang bị viền.
  final List<int> equippedBorderColors;
  final int score;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.slogan = '',
    this.equippedBorderColors = const [],
    required this.score,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: jInt(j['rank']),
        userId: jStr(j['userId']),
        fullName: jStr(j['fullName']),
        avatarUrl: j['avatarUrl'] as String?,
        slogan: jStr(j['slogan']),
        equippedBorderColors: jIntList(j['equippedBorderColors']),
        score: jInt(j['score']),
      );
}

class LeaderboardMe {
  /// null = chưa có hạng.
  final int? rank;
  final int score;

  const LeaderboardMe({this.rank, required this.score});

  factory LeaderboardMe.fromJson(Map<String, dynamic> j) =>
      LeaderboardMe(rank: jIntN(j['rank']), score: jInt(j['score']));
}

class Leaderboard {
  final List<LeaderboardEntry> items;
  final LeaderboardMe? me;
  final DateTime? fetchedAt;

  const Leaderboard({required this.items, this.me, this.fetchedAt});
}
