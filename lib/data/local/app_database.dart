import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/bookmark_dao.dart';
import 'daos/content_dao.dart';
import 'daos/leaderboard_dao.dart';
import 'daos/lesson_dao.dart';
import 'daos/note_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/quest_dao.dart';
import 'daos/quiz_dao.dart';
import 'daos/shop_dao.dart';
import 'daos/srs_dao.dart';
import 'daos/stats_dao.dart';
import 'daos/sync_dao.dart';

part 'app_database.g.dart';

/// 25 bảng khai báo trong `schema.drift` (copy từ docs/sql/client_sqlite.sql, bỏ dòng PRAGMA).
///
/// Lưu ý tên lớp: Drift sinh row class theo tên bảng số ít (`topics` -> `Topic`,
/// `reward_items` -> `RewardItem`...) và trùng với model trong `lib/models/`.
/// Khi dùng chung một file, import model kèm prefix: `import '../../models/topic_model.dart' as m;`.
@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  /// `shareAcrossIsolates`: isolate nền của workmanager mở cùng file DB mà không tranh khoá.
  AppDatabase([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(name: 'flash.db', native: const DriftNativeOptions(shareAcrossIsolates: true)));

  late final SyncDao syncDao = SyncDao(this);
  late final ContentDao contentDao = ContentDao(this);
  late final SrsDao srsDao = SrsDao(this);
  late final ProgressDao progressDao = ProgressDao(this);
  late final NoteDao noteDao = NoteDao(this);
  late final BookmarkDao bookmarkDao = BookmarkDao(this);
  late final LessonDao lessonDao = LessonDao(this);
  late final QuizDao quizDao = QuizDao(this);
  late final QuestDao questDao = QuestDao(this);
  late final ShopDao shopDao = ShopDao(this);
  late final ProfileDao profileDao = ProfileDao(this);
  late final StatsDao statsDao = StatsDao(this);
  late final LeaderboardDao leaderboardDao = LeaderboardDao(this);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // SQLite mặc định TẮT khoá ngoại; ON DELETE CASCADE ở schema chỉ chạy khi bật.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Đăng xuất / đổi tài khoản: xoá nhóm B (User data, 13 bảng) và nhóm C (Sync, 2 bảng).
  /// Giữ nhóm A (content cache và leaderboard_cache).
  Future<void> clearUserData() => transaction(() async {
        await delete(quizAttemptAnswers).go();
        await delete(quizAttempts).go();
        await delete(lessonCompletions).go();
        await delete(flashcardReviewLogs).go();
        await delete(userFlashcardProgress).go();
        await delete(userFlashcardNotes).go();
        await delete(userBookmarks).go();
        await delete(userTopicProgress).go();
        await delete(userGrammarProgress).go();
        await delete(userQuests).go();
        await delete(userInventories).go();
        await delete(dailyStatistics).go();
        await delete(userProfile).go();
        await delete(syncQueue).go();
        await delete(syncMeta).go();
      });
}
