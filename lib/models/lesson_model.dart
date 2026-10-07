/// Thẻ bài học ở Home ("Tiếp tục học", "Bài học gợi ý").
class Lesson {
  final String id;

  /// id của topic (vocabulary) hoặc grammar lesson (grammar).
  final String refId;
  final String title;

  /// 'vocabulary' | 'grammar'
  final String type;
  final String level;
  final double progress;
  final int itemCount;
  final int estimatedMinutes;

  /// ARGB, null = màu mặc định theo [type].
  final int? coverColor;

  const Lesson({
    required this.id,
    required this.refId,
    required this.title,
    required this.type,
    required this.level,
    required this.progress,
    required this.itemCount,
    required this.estimatedMinutes,
    this.coverColor,
  });

  bool get isVocabulary => type == 'vocabulary';
}
