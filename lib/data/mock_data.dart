import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/flashcard_model.dart';
import '../models/quest_model.dart';
import '../models/reward_item_model.dart';
import '../models/leaderboard_user_model.dart';

class MockData {
  static List<Topic> vocabularyTopics = [
    Topic(id: 't1', title: 'Daily Life', totalWords: 25, progress: 0.6, iconPath: '☀️'),
    Topic(id: 't2', title: 'Travel', totalWords: 30, progress: 0.3, iconPath: '✈️'),
    Topic(id: 't3', title: 'Food & Drink', totalWords: 25, progress: 0.2, iconPath: '🍔'),
    Topic(id: 't4', title: 'Technology', totalWords: 30, progress: 0.1, iconPath: '💻'),
    Topic(id: 't5', title: 'Business', totalWords: 25, progress: 0.0, iconPath: '💼'),
  ];

  static List<Map<String, dynamic>> grammarTopics = [
    {
      'id': 'g1',
      'title': 'Present Simple',
      'progress': 1.0,
      'status': 'Đã học 100%',
      'icon': Icons.account_tree_outlined,
    },
    {
      'id': 'g2',
      'title': 'Present Continuous',
      'progress': 0.6,
      'status': 'Đang học 60%',
      'icon': Icons.access_alarm,
    },
    {
      'id': 'g3',
      'title': 'Past Simple',
      'progress': 0.0,
      'status': 'Chưa học 0%',
      'icon': Icons.history_edu,
    },
    {
      'id': 'g4',
      'title': 'Present Perfect',
      'progress': 0.0,
      'status': 'Chưa học 0%',
      'icon': Icons.verified_user_outlined,
    },
    {
      'id': 'g5',
      'title': 'Conditional',
      'progress': 0.0,
      'status': 'Chưa học 0%',
      'icon': Icons.alt_route,
    },
  ];

  static List<Flashcard> flashcards = [
    Flashcard(
      id: 'f1',
      topicId: 't1',
      word: 'beautiful',
      partOfSpeech: 'adj.',
      pronunciation: '/ˈbjuːtɪfl/',
      meaning: 'đẹp, xinh đẹp',
      example: 'She is a beautiful girl.',
      exampleTranslation: 'Cô ấy là một cô gái xinh đẹp.',
    ),
    Flashcard(
      id: 'f2',
      topicId: 't5',
      word: 'opportunity',
      partOfSpeech: 'n.',
      pronunciation: '/ˌɒpəˈtjuːnəti/',
      meaning: 'cơ hội',
      example: 'This is a great opportunity for you.',
      exampleTranslation: 'Đây là một cơ hội tuyệt vời cho bạn.',
    ),
  ];

  static List<Quest> quests = [
    Quest(
      id: 'q1',
      icon: Icons.style,
      title: 'Học 20 Flashcard mới',
      current: 12,
      target: 20,
      xp: 50,
      isClaimed: false,
    ),
    Quest(
      id: 'q2',
      icon: Icons.fact_check,
      title: 'Đạt 100% 1 bài kiểm tra',
      current: 1,
      target: 1,
      xp: 100,
      isClaimed: false,
    ),
    Quest(
      id: 'q3',
      icon: Icons.local_fire_department,
      title: 'Duy trì Streak',
      current: 1,
      target: 1,
      xp: 20,
      isClaimed: true,
    ),
  ];

  static List<RewardItem> shopItems = [
    RewardItem(
      id: 'b1',
      name: 'Tân binh',
      type: 'border',
      xpCost: 0,
      borderColors: [0xFFE2E8F0, 0xFFCBD5E1], // Xám
      isUnlocked: true,
      isEquipped: false,
    ),
    RewardItem(
      id: 'b2',
      name: 'Hỏa thần',
      type: 'border',
      xpCost: 500,
      borderColors: [0xFFFF4D4F, 0xFFFF7A45, 0xFFFFA940], // Đỏ - Cam
      isUnlocked: true,
      isEquipped: true, // Đang dùng viền này
    ),
    RewardItem(
      id: 'b3',
      name: 'Tinh tú',
      type: 'border',
      xpCost: 1500,
      borderColors: [0xFF722ED1, 0xFFB37FEB, 0xFF531DAB], // Tím Nebula
      isUnlocked: false,
    ),
    RewardItem(
      id: 'b4',
      name: 'Hoàng kim',
      type: 'border',
      xpCost: 3000,
      borderColors: [0xFFFAAD14, 0xFFFFE58F, 0xFFFA8C16], // Vàng Gold
      isUnlocked: false,
    ),
  ];

  static List<LeaderboardUser> leaderboardUsers = [
    LeaderboardUser(id: 'u1', name: 'Đoàn Quốc Huy', totalXp: 3500, longestStreak: 45, note: 'Kẻ hủy diệt từ vựng! 🔥'),
    LeaderboardUser(id: 'u2', name: 'Nguyễn Văn A', totalXp: 3200, longestStreak: 30, note: 'Chăm chỉ mỗi ngày 📚'),
    LeaderboardUser(id: 'u3', name: 'Trần Thị B', totalXp: 2800, longestStreak: 50, note: 'Chúa tể ngữ pháp 👑'),
    LeaderboardUser(id: 'u4', name: 'Lê Hoàng C', totalXp: 2500, longestStreak: 14, note: 'Đang tăng tốc... 🚀'),
    LeaderboardUser(id: 'u5', name: 'Phạm Thị D', totalXp: 2100, longestStreak: 21, note: 'Không bỏ cuộc 💪'),
    LeaderboardUser(id: 'u6', name: 'Vũ Đức E', totalXp: 1800, longestStreak: 10, note: 'Mới nhú 🌱'),
    LeaderboardUser(id: 'u7', name: 'Hoàng Văn F', totalXp: 1500, longestStreak: 7, note: 'Cần cố gắng hơn 🎯'),
  ];
}