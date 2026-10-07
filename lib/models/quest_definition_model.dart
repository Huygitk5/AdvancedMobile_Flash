import '_json.dart';

/// `QuestDefinitionResponse` (chỉ dùng ở màn admin).
class QuestDefinition {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String questType;
  final String frequency;
  final int targetValue;
  final int xpReward;
  final String iconName;
  final bool isActive;
  final int sortOrder;

  const QuestDefinition({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.questType,
    required this.frequency,
    required this.targetValue,
    required this.xpReward,
    required this.iconName,
    this.isActive = true,
    this.sortOrder = 0,
  });

  static const questTypes = [
    'LEARN_WORDS',
    'REVIEW_CARDS',
    'COMPLETE_LESSON',
    'COMPLETE_QUIZ',
    'PERFECT_QUIZ',
    'STUDY_MINUTES',
    'KEEP_STREAK',
  ];
  static const frequencies = ['DAILY', 'WEEKLY', 'ONE_TIME'];

  factory QuestDefinition.fromJson(Map<String, dynamic> j) => QuestDefinition(
        id: j['id'] as String,
        code: jStr(j['code']),
        title: jStr(j['title']),
        description: j['description'] as String?,
        questType: jStr(j['questType'], 'REVIEW_CARDS'),
        frequency: jStr(j['frequency'], 'DAILY'),
        targetValue: jInt(j['targetValue'], 1),
        xpReward: jInt(j['xpReward']),
        iconName: jStr(j['iconName'], 'stars'),
        isActive: jBool(j['isActive'], true),
        sortOrder: jInt(j['sortOrder']),
      );
}
