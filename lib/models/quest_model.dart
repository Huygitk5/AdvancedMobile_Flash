/// Nhiệm vụ của user trong kỳ hiện tại (`user_quests` ⨝ `quest_definitions`).
class Quest {
  final String id;
  final String questDefinitionId;
  final String title;

  /// Tên icon từ server; UI gọi `iconFor(iconName)`.
  final String iconName;
  final int current;
  final int target;
  final int xp;
  final bool isClaimed;

  /// 'YYYY-MM-DD'
  final String periodStart;

  const Quest({
    required this.id,
    required this.questDefinitionId,
    required this.title,
    required this.iconName,
    required this.current,
    required this.target,
    required this.xp,
    required this.isClaimed,
    required this.periodStart,
  });

  bool get isCompleted => current >= target;
  double get progress => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
}
