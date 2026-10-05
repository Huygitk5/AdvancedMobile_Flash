import 'package:flutter/material.dart';
import 'json_helpers.dart';

class Quest {
  /// id của user_quest (dùng để nhận thưởng).
  final String id;
  final String title;
  final String iconName;
  final int current;
  final int target;
  final int xp;
  bool isClaimed;

  Quest({
    required this.id,
    required this.title,
    this.iconName = '',
    this.current = 0,
    this.target = 1,
    this.xp = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => current >= target;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);

  IconData get icon => questIcon(iconName);

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
        id: jStr(json, 'id'),
        title: jStr(json, 'title'),
        iconName: jStr(json, 'iconName'),
        current: jInt(json, 'current'),
        target: jInt(json, 'target', 1),
        xp: jInt(json, 'xp'),
        isClaimed: jBool(json, 'isClaimed'),
      );
}

/// Tên Material icon do server trả về -> IconData.
IconData questIcon(String name) {
  switch (name) {
    case 'style':
      return Icons.style;
    case 'fact_check':
      return Icons.fact_check;
    case 'local_fire_department':
      return Icons.local_fire_department;
    case 'menu_book':
      return Icons.menu_book;
    case 'quiz':
      return Icons.quiz;
    case 'timer':
      return Icons.timer;
    case 'school':
      return Icons.school;
    default:
      return Icons.star;
  }
}
