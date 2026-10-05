import 'package:flutter/material.dart';

/// Server trả `icon_name` (grammar_lessons, quest_definitions) dạng chuỗi tên Material icon.
/// Thêm tên mới vào bảng này mỗi khi admin thêm icon mới.
const Map<String, IconData> _iconByName = {
  // grammar_lessons.icon_name (seed V2 + bộ ngữ pháp đầy đủ V4)
  'account_tree': Icons.account_tree_outlined,
  'person': Icons.person_outline,
  'access_alarm': Icons.access_alarm,
  'place': Icons.place_outlined,
  'label': Icons.label_outline,
  'format_list_numbered': Icons.format_list_numbered,
  'scale': Icons.scale_outlined,
  'people': Icons.people_outline,
  'pin_drop': Icons.pin_drop_outlined,
  'help_outline': Icons.help_outline,
  'check_circle': Icons.check_circle_outline,
  'repeat': Icons.repeat,
  'trending_up': Icons.trending_up,
  'history_edu': Icons.history_edu,
  'schedule': Icons.schedule,
  'bolt': Icons.bolt,
  'directions_run': Icons.directions_run,
  'verified_user': Icons.verified_user_outlined,
  'priority_high': Icons.priority_high,
  'restore': Icons.restore,
  'link': Icons.link,
  'tune': Icons.tune,
  'swap_horiz': Icons.swap_horiz,
  'hourglass_bottom': Icons.hourglass_bottom,
  'undo': Icons.undo,
  'update': Icons.update,
  'event_available': Icons.event_available,
  'compare_arrows': Icons.compare_arrows,
  'alt_route': Icons.alt_route,
  'record_voice_over': Icons.record_voice_over,
  'psychology': Icons.psychology_outlined,
  'question_answer': Icons.question_answer_outlined,
  'star_border': Icons.star_border,
  'build': Icons.build_outlined,
  'flip': Icons.flip,
  'menu_book': Icons.menu_book,
  // quest_definitions.icon_name (seed V2)
  'style': Icons.style,
  'fact_check': Icons.fact_check,
  'local_fire_department': Icons.local_fire_department,
  // dự phòng cho các loại nhiệm vụ khác (QuestType)
  'timer': Icons.timer_outlined,
  'quiz': Icons.quiz,
  'school': Icons.school,
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
