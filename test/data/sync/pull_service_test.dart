import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/core/clock.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/repositories/study_repositories.dart';
import 'package:flash/data/sync/pull_service.dart';

import 'sync_fixtures.dart';

void main() {
  late AppDatabase db;
  late FakeSyncApi api;
  late PullService pull;
  Map<String, dynamic>? appliedSettings;
  final now = DateTime.utc(2026, 10, 5, 3);

  setUp(() async {
    Clock.override(() => now);
    db = AppDatabase(NativeDatabase.memory());
    api = FakeSyncApi();
    appliedSettings = null;
    pull = PullService(db: db, api: api, onSettings: (s) async => appliedSettings = s);
  });

  tearDown(() async {
    await db.close();
    Clock.override(null);
  });

  void noKick() {}

  test('content: lần đầu bỏ since, lặp khi hasMore, lưu cursor; con thiếu cha bị bỏ qua', () async {
    final c = seedContent();
    api.contentPages
      ..add({
        'cursor': '2026-10-01T00:00:00Z',
        'hasMore': true,
        'changes': {
          // Thẻ của topic chưa về (trang sau server gửi kèm lại toàn bộ con của topic)
          'flashcards': [
            {'id': 'orphan', 'topicId': 't9', 'word': 'x', 'partOfSpeech': 'n.', 'pronunciation': '', 'meaning': ''},
          ],
          'topics': c['topics'],
        },
      })
      ..add({'cursor': '2026-10-02T00:00:00Z', 'hasMore': false, 'changes': c});
    await pull.pullContent();

    expect(api.contentSince, [null, '2026-10-01T00:00:00Z']);
    expect(await db.syncDao.getCursor(PullService.contentScope), '2026-10-02T00:00:00Z');
    expect(await count(db, 'flashcards'), 2);
    expect(await count(db, 'flashcards', "id = 'orphan'"), 0);
    expect(await count(db, 'quiz_question_options'), 8);
  });

  test('content.deleted xoá đúng dòng; FK cascade dọn tiến độ / ghi chú; upsert không xoá con', () async {
    await seed(db);
    final card = (await db.contentDao.watchCards('t1').first).first;
    await SrsRepository(db, noKick).rate(card, 'KNOW');
    await db.noteDao.saveLocal('f1', 'note', 0);

    // Cập nhật lại topic (upsert, không REPLACE) thì thẻ / tiến độ vẫn còn.
    api.contentPages.add({'cursor': 'c1', 'hasMore': false, 'changes': {'topics': seedContent()['topics']}});
    await pull.pullContent();
    expect(await count(db, 'flashcards'), 2);
    expect(await count(db, 'user_flashcard_progress'), 1);

    api.contentPages.add({
      'cursor': 'c2',
      'hasMore': false,
      'changes': {
        'deleted': {'flashcards': ['f1'], 'quizzes': ['qz1']},
      },
    });
    await pull.pullContent();
    expect(await count(db, 'flashcards'), 1);
    expect(await count(db, 'user_flashcard_progress'), 0);
    expect(await count(db, 'user_flashcard_notes'), 0);
    expect(await count(db, 'quiz_questions'), 0);

    api.contentPages.add({'cursor': 'c3', 'hasMore': false, 'changes': {'deleted': {'topics': ['t1']}}});
    await pull.pullContent();
    expect(await count(db, 'flashcards'), 0);
  });

  test('user data: không đè dòng is_dirty = 1, ghi đè dòng sạch; user + settings luôn áp', () async {
    await seed(db);
    // f1 có ghi chú lạc quan chưa đồng bộ (dirty), f2 không.
    await db.noteDao.saveLocal('f1', 'local chưa gửi', 0);

    api.pullPages.add({
      'cursor': 'u1',
      'hasMore': false,
      'changes': {
        'user': {...seedUser, 'currentXp': 999, 'streakDays': 7},
        'settings': {'isDarkMode': true},
        'userFlashcardNotes': [
          {'noteId': 'n-srv-1', 'flashcardId': 'f1', 'content': 'bản server cũ', 'version': 2},
          {'noteId': 'n-srv-2', 'flashcardId': 'f2', 'content': 'từ máy khác', 'version': 1},
        ],
        'userTopicProgress': [
          {'topicId': 't1', 'learnedWords': 1, 'status': 'IN_PROGRESS', 'version': 3},
        ],
        'dailyStatistics': [
          {'date': '2026-10-04', 'cardsReviewed': 12, 'wordsLearned': 3, 'correctAnswers': 4, 'totalAnswers': 5},
        ],
        'userBookmarks': [
          {'flashcardId': 'f2', 'version': 1, 'createdAt': '2026-10-01T00:00:00Z', 'deletedAt': '2026-10-02T00:00:00Z'},
        ],
      },
    });
    await pull.pullUserData();

    expect((await db.noteDao.byFlashcard('f1'))!.content, 'local chưa gửi');
    expect((await db.noteDao.byFlashcard('f2'))!.content, 'từ máy khác');
    expect((await db.profileDao.current())!.currentXp, 999);
    expect(appliedSettings, {'isDarkMode': true});
    expect((await db.contentDao.watchTopic('t1').first)!.learnedWords, 1);
    expect((await db.statsDao.watchDay('2026-10-04').first)!.cardsReviewed, 12);
    expect(await db.bookmarkDao.isBookmarked('f2'), isFalse, reason: 'tombstone giữ lại, UI lọc deleted_at');
    expect(await count(db, 'user_bookmarks'), 1);
  });

  test('settings không áp khi còn SETTINGS_UPDATE chưa gửi', () async {
    await seed(db);
    await db.syncDao.enqueue(opType: 'SETTINGS_UPDATE', entityTable: 'user_settings', entityId: 'u1', payload: {});
    api.pullPages.add({'cursor': 'u1', 'hasMore': false, 'changes': {'settings': {'isDarkMode': true}}});
    await pull.pullUserData();
    expect(appliedSettings, isNull);
  });
}
