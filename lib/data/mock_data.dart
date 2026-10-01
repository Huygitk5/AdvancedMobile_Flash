import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/flashcard_model.dart';
import '../models/quest_model.dart';
import '../models/reward_item_model.dart';
import '../models/user_model.dart';
import '../models/grammar_model.dart';
import '../models/quiz_result_model.dart';
import '../models/daily_statistic_model.dart';
import '../models/user_inventory_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_review_model.dart';

class MockData {
  static List<Topic> vocabularyTopics = [
    Topic(id: 't1',
        title: 'Daily Life',
        totalWords: 25,
        progress: 0.6,
        iconPath: '☀️'),
    Topic(id: 't2',
        title: 'Travel',
        totalWords: 30,
        progress: 0.3,
        iconPath: '✈️'),
    Topic(id: 't3',
        title: 'Food & Drink',
        totalWords: 25,
        progress: 0.2,
        iconPath: '🍔'),
    Topic(id: 't4',
        title: 'Technology',
        totalWords: 30,
        progress: 0.1,
        iconPath: '💻'),
    Topic(id: 't5',
        title: 'Business',
        totalWords: 25,
        progress: 0.0,
        iconPath: '💼'),
  ];

  static List<UserModel> users = [
    UserModel(
      id: 'u1',
      fullName: 'Đoàn Quốc Huy',
      email: 'huy_dev@gmail.com',
      level: 'A2',
      currentXp: 1200,
      targetXp: 2000,
      streakDays: 7,
      totalWordsLearned: 248,
      completedLessons: 18,
      totalLifetimeXp: 3500,
      longestStreak: 45,
      slogan: 'Kẻ hủy diệt từ vựng! 🔥',
    ),
    UserModel(
      id: 'u2',
      fullName: 'Nguyễn Văn A',
      email: 'nva@gmail.com',
      level: 'A1',
      currentXp: 500,
      targetXp: 1000,
      streakDays: 5,
      totalWordsLearned: 150,
      completedLessons: 10,
      totalLifetimeXp: 3200,
      longestStreak: 30,
      slogan: 'Chăm chỉ mỗi ngày 📚',
    ),
    UserModel(
      id: 'u3',
      fullName: 'Trần Thị B',
      email: 'ttb@gmail.com',
      level: 'B1',
      currentXp: 800,
      targetXp: 3000,
      streakDays: 12,
      totalWordsLearned: 500,
      completedLessons: 35,
      totalLifetimeXp: 2800,
      longestStreak: 50,
      slogan: 'Chúa tể ngữ pháp 👑',
    ),
  ];

  // Hàm tiện ích lấy User đang đăng nhập (Tài khoản của bạn)
  static UserModel get currentUser => users.firstWhere((u) => u.id == 'u1');

  static List<Grammar> grammarTopics = [
    Grammar(id: 'g1',
        title: 'Present Simple',
        progress: 1.0,
        status: 'Đã học 100%',
        iconName: 'account_tree'),
    Grammar(id: 'g2',
        title: 'Present Continuous',
        progress: 0.6,
        status: 'Đang học 60%',
        iconName: 'access_alarm'),
    Grammar(id: 'g3',
        title: 'Past Simple',
        progress: 0.0,
        status: 'Chưa học 0%',
        iconName: 'history_edu'),
    Grammar(id: 'g4',
        title: 'Present Perfect',
        progress: 0.0,
        status: 'Chưa học 0%',
        iconName: 'verified_user'),
    Grammar(id: 'g5',
        title: 'Conditional',
        progress: 0.0,
        status: 'Chưa học 0%',
        iconName: 'alt_route'),
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

  // 2. Dữ liệu Shop (Có item yêu cầu Top)
  static List<RewardItem> shopItems = [
    RewardItem(id: 'b1',
        name: 'Tân binh',
        type: 'border',
        xpCost: 0,
        borderColors: [0xFFE2E8F0, 0xFFCBD5E1],
        isUnlocked: true,
        isEquipped: false),
    RewardItem(id: 'b2',
        name: 'Hỏa thần',
        type: 'border',
        xpCost: 500,
        borderColors: [0xFFFF4D4F, 0xFFFF7A45, 0xFFFFA940],
        isUnlocked: true,
        isEquipped: true),
    RewardItem(id: 'b3',
        name: 'Tinh tú',
        type: 'border',
        xpCost: 1500,
        borderColors: [0xFF722ED1, 0xFFB37FEB, 0xFF531DAB],
        isUnlocked: false),
    // Item VIP yêu cầu lọt Top 3
    RewardItem(
        id: 'b4',
        name: 'Vua Trò Chơi',
        type: 'border',
        xpCost: 3000,
        borderColors: [0xFFFAAD14, 0xFFFFE58F, 0xFFFA8C16],
        requiredRank: 3,
        // Bổ sung điều kiện
        isUnlocked: false
    ),
  ];

  static QuizResult latestQuizResult = QuizResult(
    id: 'qr1',
    userId: 'u1',
    topicId: 't1',
    correctAnswers: 8,
    wrongAnswers: 2,
    timeTakenSeconds: 272,
    // 4 phút 32 giây
    wrongQuestionIds: ['q2', 'q5'],
  );

  static List<DailyStatistic> weeklyStats = [
    DailyStatistic(id: 's1',
        userId: 'u1',
        date: DateTime.now().subtract(const Duration(days: 6)),
        wordsLearned: 15,
        xpGained: 50),
    DailyStatistic(id: 's2',
        userId: 'u1',
        date: DateTime.now().subtract(const Duration(days: 5)),
        wordsLearned: 40,
        xpGained: 120),
    DailyStatistic(id: 's3',
        userId: 'u1',
        date: DateTime.now().subtract(const Duration(days: 4)),
        wordsLearned: 25,
        xpGained: 80),
    DailyStatistic(id: 's4',
        userId: 'u1',
        date: DateTime.now().subtract(const Duration(days: 3)),
        wordsLearned: 60,
        xpGained: 200),
    DailyStatistic(id: 's5',
        userId: 'u1',
        date: DateTime.now().subtract(const Duration(days: 2)),
        wordsLearned: 10,
        xpGained: 30),
    DailyStatistic(id: 's6',
        userId: 'u1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        wordsLearned: 45,
        xpGained: 150),
    DailyStatistic(id: 's7',
        userId: 'u1',
        date: DateTime.now(),
        wordsLearned: 80,
        xpGained: 250), // Hôm nay
  ];

  // Tủ đồ của người dùng hiện tại (Ví dụ đã sở hữu 2 viền, đang dùng viền b2)
  static List<UserInventory> myInventory = [
    UserInventory(id: 'inv1',
        userId: 'u1',
        rewardItemId: 'b1',
        isEquipped: false,
        unlockedAt: DateTime.now()),
    UserInventory(id: 'inv2',
        userId: 'u1',
        rewardItemId: 'b2',
        isEquipped: true,
        unlockedAt: DateTime.now()),
  ];

  static List<Lesson> suggestedLessons = [
    Lesson(id: 'ls1',
        title: 'Travel Vocabulary',
        type: 'vocabulary',
        level: 'A2',
        progress: 0.6,
        itemCounts: '20 từ',
        estimatedTime: '8 phút',
        imageBg: Colors.blue.shade100),
    Lesson(id: 'ls2',
        title: 'Present Simple',
        type: 'grammar',
        level: 'A2',
        progress: 0.4,
        itemCounts: '3 bài',
        estimatedTime: '12 phút',
        imageBg: Colors.purple.shade100),
    Lesson(id: 'ls3',
        title: 'Daily Conversation',
        type: 'vocabulary',
        level: 'B1',
        progress: 0.2,
        itemCounts: '15 câu',
        estimatedTime: '10 phút',
        imageBg: Colors.orange.shade100),
  ];

  static List<QuizReviewItem> mockReviewData = [
    QuizReviewItem(
      id: 'q1',
      question: 'She ______ her homework now.',
      options: ['is doing', 'does', 'did', 'was doing'],
      correctIndex: 0,
      userIndex: 0,
      explanation: 'Câu ở thì hiện tại tiếp diễn, nên dùng "is doing".',
    ),
    QuizReviewItem(
      id: 'q2',
      question: 'The weather is very ______ today.',
      options: ['good', 'well', 'bad', 'nice'],
      correctIndex: 3,
      userIndex: 0,
      explanation: 'Sau "is" (thời tiết) ta dùng tính từ, nên đáp án đúng là "nice".',
    ),
    QuizReviewItem(
      id: 'q5',
      question: 'I ______ to the store yesterday.',
      options: ['went', 'go', 'goes', 'going'],
      correctIndex: 0,
      userIndex: 0,
      explanation: 'Câu ở thì quá khứ đơn, dấu hiệu "yesterday" nên dùng "went".',
    ),
  ];
}