import 'json_helpers.dart';

class Topic {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final String level;
  final int estimatedMinutes;
  final int totalWords;
  final int learnedWords;
  final double progress;
  final String status; // NOT_STARTED | IN_PROGRESS | COMPLETED
  final bool isPublished;

  const Topic({
    required this.id,
    required this.title,
    this.description = '',
    this.iconPath = '',
    this.level = 'A1',
    this.estimatedMinutes = 10,
    this.totalWords = 0,
    this.learnedWords = 0,
    this.progress = 0,
    this.status = 'NOT_STARTED',
    this.isPublished = true,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: jStr(json, 'id'),
      title: jStr(json, 'title'),
      description: jStr(json, 'description'),
      iconPath: jStr(json, 'iconPath'),
      level: jStr(json, 'level', 'A1'),
      estimatedMinutes: jInt(json, 'estimatedMinutes', 10),
      totalWords: jInt(json, 'totalWords'),
      learnedWords: jInt(json, 'learnedWords'),
      progress: jDouble(json, 'progress').clamp(0.0, 1.0),
      status: jStr(json, 'status', 'NOT_STARTED'),
      isPublished: jBool(json, 'isPublished', true),
    );
  }
}
