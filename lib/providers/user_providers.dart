import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../data/local/converters.dart';
import '../data/local/daos/content_dao.dart';
import '../data/repositories/base_repository.dart';
import '../models/daily_statistic_model.dart';
import '../models/leaderboard_model.dart';
import '../models/lesson_model.dart';
import '../models/quest_model.dart';
import '../models/reward_item_model.dart';
import '../models/user_model.dart';
import 'providers.dart';

/// `user_profile` + viền / avatar đang trang bị.
final profileProvider = StreamProvider<UserModel?>((ref) => ref.watch(dbProvider).profileDao.watchProfile());

/// Số liệu hôm nay ("3/5 bài").
final todayStatsProvider = StreamProvider.autoDispose<DailyStatistic?>(
  (ref) => ref.watch(dbProvider).statsDao.watchDay(localDateKey(Clock.now())),
);

/// "3/5 bài" hôm nay: số bài KHÁC NHAU đã hoàn thành (học lại cùng một bài chỉ tính một lần, giống server).
final todayLessonsDoneProvider = StreamProvider.autoDispose<int>((ref) {
  final (start, end) = WriteRepository.dayBounds(Clock.now());
  return ref.watch(dbProvider).lessonDao.watchDistinctBetween(start, end);
});

/// Nhiệm vụ kỳ hiện tại (ngày / tuần / một lần).
final questsProvider = StreamProvider.autoDispose<List<Quest>>(
  (ref) => ref.watch(dbProvider).questDao.watchCurrentQuests(Clock.now()),
);

/// Danh mục Shop từ SQLite (offline được).
final shopItemsProvider = StreamProvider.autoDispose<List<RewardItem>>(
  (ref) => ref.watch(dbProvider).shopDao.watchShopItems(),
);

/// `canAfford` / `meetsRankRequirement` theo server; null khi offline.
final shopOnlineStatusProvider = FutureProvider.autoDispose<Map<String, RewardItem>?>(
  (ref) => ref.watch(shopRepositoryProvider).onlineStatus(),
);

/// [board]: 'XP' | 'STREAK'.
final leaderboardProvider = FutureProvider.autoDispose.family<Leaderboard?, String>(
  (ref, board) => ref.watch(leaderboardRepositoryProvider).load(board),
);

/// 'WEEK' | 'MONTH' | 'ALL'. Màn Tiến độ đọc 'ALL' rồi tự lọc theo khoảng (gồm cả Năm / Tuỳ chọn)
/// bằng `Statistics.of`.
final statsRangeProvider = StreamProvider.autoDispose.family<List<DailyStatistic>, String>((ref, range) {
  final dao = ref.watch(dbProvider).statsDao;
  final today = Clock.now();
  return switch (range) {
    'WEEK' => dao.watchDaily(localDateKey(today.subtract(const Duration(days: 6))), localDateKey(today)),
    'MONTH' => dao.watchDaily(localDateKey(today.subtract(const Duration(days: 29))), localDateKey(today)),
    _ => dao.watchAll(),
  };
});

/// Home: "Tiếp tục học" = topic IN_PROGRESS học gần nhất; gợi ý = topic / ngữ pháp chưa học theo sort_order.
final homeLessonsProvider = StreamProvider.autoDispose<({Lesson? continueLesson, List<Lesson> recommended})>((ref) {
  final dao = ref.watch(dbProvider).contentDao;
  final topics = dao.watchTopicsWithProgress();
  return topics.asyncMap((ts) async {
    final grammar = await dao.watchGrammarWithProgress().first;
    final inProgress = ts.where((t) => t.status == 'IN_PROGRESS').toList()
      ..sort((a, b) => (b.lastStudiedAt ?? DateTime(0)).compareTo(a.lastStudiedAt ?? DateTime(0)));
    Lesson topicLesson(t) => Lesson(
          id: t.id,
          refId: t.id,
          title: t.title,
          type: 'vocabulary',
          level: t.level,
          progress: t.progress,
          itemCount: t.totalWords,
          estimatedMinutes: t.estimatedMinutes,
          coverColor: t.coverColor,
        );
    final recommended = <Lesson>[
      ...ts.where((t) => t.status == 'NOT_STARTED').take(3).map(topicLesson),
      ...grammar.where((g) => g.status == 'NOT_STARTED').take(2).map((g) => Lesson(
            id: g.id,
            refId: g.id,
            title: g.title,
            type: 'grammar',
            level: g.level,
            progress: g.progress,
            itemCount: 1,
            estimatedMinutes: g.estimatedMinutes,
            coverColor: g.coverColor,
          )),
    ];
    return (continueLesson: inProgress.isEmpty ? null : topicLesson(inProgress.first), recommended: recommended);
  });
});

/// Tổng số từ vựng / chủ đề trong cache (thẻ "Từ vựng" ở Home).
final contentCountsProvider = StreamProvider.autoDispose<({int topics, int words})>((ref) =>
    ref.watch(dbProvider).contentDao.watchTopicsWithProgress(filter: ProgressFilter.all).map(
          (ts) => (topics: ts.length, words: ts.fold(0, (s, t) => s + t.totalWords)),
        ));

/// Số chủ điểm ngữ pháp trong cache (thẻ "Ngữ pháp" ở Home).
final grammarCountProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(dbProvider).contentDao.watchGrammarWithProgress().map((gs) => gs.length),
);
