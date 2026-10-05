import 'package:flutter/material.dart';

/// Server trả `icon_name` (grammar_lessons, quest_definitions) dạng chuỗi tên Material icon.
/// Thêm tên mới vào bảng này mỗi khi admin thêm icon mới.
const Map<String, IconData> _iconByName = {
  // grammar_lessons.icon_name (seed V2)
  'account_tree': Icons.account_tree_outlined,
  'access_alarm': Icons.access_alarm,
  'history_edu': Icons.history_edu,
  'verified_user': Icons.verified_user_outlined,
  'alt_route': Icons.alt_route,
  'menu_book': Icons.menu_book,
  // quest_definitions.icon_name (seed V2)
  'style': Icons.style,
  'fact_check': Icons.fact_check,
  'local_fire_department': Icons.local_fire_department,
  // dự phòng cho các loại nhiệm vụ khác (QuestType)
  'timer': Icons.timer_outlined,
  'quiz': Icons.quiz,
  'task_alt': Icons.task_alt,
  'stars': Icons.stars,
  'emoji_events': Icons.emoji_events,
};

/// Tên icon (từ server) -> IconData. Tên lạ trả về [fallback], không ném lỗi.
IconData iconFor(String? name, {IconData fallback = Icons.star}) {
  if (name == null) return fallback;
  return _iconByName[name] ?? fallback;
}

/// `topics.icon_path` hiện là emoji ('☀️', '✈️'), không phải tên icon.
/// Nếu `iconPath` có trong bảng icon thì dùng Icon, ngược lại UI hiển thị nó như văn bản.
bool isIconName(String? value) => value != null && _iconByName.containsKey(value);
