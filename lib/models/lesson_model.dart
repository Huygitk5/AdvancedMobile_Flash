import 'package:flutter/material.dart';
import 'json_helpers.dart';
import 'quest_model.dart';

/// Bài học gợi ý / đang học dở trên Trang chủ: tổng hợp từ một topic (vocabulary) hoặc chủ điểm ngữ pháp (grammar).
class Lesson {
  final String id;
  final String title;
  final String type; // vocabulary | grammar
  final String level;
  final double progress;
  final int itemCount;
  final int estimatedMinutes;
  final Color? coverColor;

  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    this.level = 'A1',
    this.progress = 0,
    this.itemCount = 0,
    this.estimatedMinutes = 10,
    this.coverColor,
  });

  bool get isVocabulary => type == 'vocabulary';

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: jStr(json, 'id'),
        title: jStr(json, 'title'),
        type: jStr(json, 'type', 'vocabulary'),
        level: jStr(json, 'level', 'A1'),
        progress: jDouble(json, 'progress').clamp(0.0, 1.0),
        itemCount: jInt(json, 'itemCount'),
        estimatedMinutes: jInt(json, 'estimatedMinutes', 10),
        coverColor: json['coverColor'] is num ? Color((json['coverColor'] as num).toInt()) : null,
      );
}

class HomeSummary {
  final String fullName;
  final int streakDays;
  final int currentXp;
  final int todayDone;
  final int todayGoal;
  final Lesson? continueLesson;
  final List<Lesson> recommended;
  final Quest? todayChallenge;

  const HomeSummary({
    required this.fullName,
    this.streakDays = 0,
    this.currentXp = 0,
    this.todayDone = 0,
    this.todayGoal = 5,
    this.continueLesson,
    this.recommended = const [],
    this.todayChallenge,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    final today = asMap(json['todayLessons']);
    return HomeSummary(
      fullName: jStr(json, 'fullName'),
      streakDays: jInt(json, 'streakDays'),
      currentXp: jInt(json, 'currentXp'),
      todayDone: jInt(today, 'done'),
      todayGoal: jInt(today, 'goal', 5),
      continueLesson: json['continueLesson'] is Map ? Lesson.fromJson(asMap(json['continueLesson'])) : null,
      recommended: jList(json, 'recommended').map(Lesson.fromJson).toList(),
      todayChallenge: json['todayChallenge'] is Map ? Quest.fromJson(asMap(json['todayChallenge'])) : null,
    );
  }
}
