import '_json.dart';

class Topic {
  final String id;
  final String title;
  final String? description;

  /// Hiện là emoji ('☀️'); xem `isIconName()` ở core/icons.dart.
  final String iconPath;
  final String level;
  final int? coverColor;
  final int estimatedMinutes;
  final int totalWords;
  final int learnedWords;

  /// 'NOT_STARTED' | 'IN_PROGRESS' | 'COMPLETED'
  final String status;
  final int sortOrder;
  final DateTime? lastStudiedAt;

  /// Chỉ có ở API admin.
  final bool isPublished;

  const Topic({
    required this.id,
    required this.title,
    this.description,
    required this.iconPath,
    this.level = 'A1',
    this.coverColor,
    this.estimatedMinutes = 10,
    this.totalWords = 0,
    this.learnedWords = 0,
    this.status = 'NOT_STARTED',
    this.sortOrder = 0,
    this.lastStudiedAt,
    this.isPublished = true,
  });

  double get progress => totalWords == 0 ? 0 : (learnedWords / totalWords).clamp(0.0, 1.0);

  /// `TopicResponse` (admin).
  factory Topic.fromJson(Map<String, dynamic> j) => Topic(
        id: j['id'] as String,
        title: jStr(j['title']),
        description: j['description'] as String?,
        iconPath: jStr(j['iconPath']),
        level: jStr(j['level'], 'A1'),
        coverColor: jIntN(j['coverColor']),
        estimatedMinutes: jInt(j['estimatedMinutes'], 10),
        totalWords: jInt(j['totalWords']),
        learnedWords: jInt(j['learnedWords']),
        status: jStr(j['status'], 'NOT_STARTED'),
        isPublished: jBool(j['isPublished'], true),
      );
}
