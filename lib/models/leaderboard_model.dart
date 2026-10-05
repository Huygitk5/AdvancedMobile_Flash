import 'package:flutter/material.dart';
import 'json_helpers.dart';

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String slogan;
  final List<int> borderColors;
  final int score;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.slogan = '',
    this.borderColors = const [],
    this.score = 0,
  });

  List<Color> get colors => borderColors.map((v) => Color(v)).toList();

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: jInt(json, 'rank'),
        userId: jStr(json, 'userId'),
        fullName: jStr(json, 'fullName'),
        avatarUrl: jStrOrNull(json, 'avatarUrl'),
        slogan: jStr(json, 'slogan'),
        borderColors: (json['equippedBorderColors'] is List)
            ? (json['equippedBorderColors'] as List).whereType<num>().map((e) => e.toInt()).toList()
            : const [],
        score: jInt(json, 'score'),
      );
}

class Leaderboard {
  final List<LeaderboardEntry> items;
  final int? myRank;
  final int myScore;

  const Leaderboard({required this.items, this.myRank, this.myScore = 0});

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    final me = asMap(json['me']);
    return Leaderboard(
      items: jList(json, 'items').map(LeaderboardEntry.fromJson).toList(),
      myRank: me['rank'] == null ? null : jInt(me, 'rank'),
      myScore: jInt(me, 'score'),
    );
  }
}
