import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/core/clock.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/remote/api_exception.dart';
import 'package:flash/data/remote/apis/gamification_api.dart';
import 'package:flash/data/repositories/study_repositories.dart';
import 'package:flash/data/repositories/user_repositories.dart';
import 'package:flash/data/storage/secure_store.dart';
import 'package:flash/data/sync/op_handlers.dart';
import 'package:flash/data/sync/pull_service.dart';
import 'package:flash/data/sync/sync_worker.dart';
import 'package:flash/models/quest_model.dart';

import 'sync_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeSyncApi api;
  late SyncWorker worker;
  final messages = <String>[];
  final now = DateTime.utc(2026, 10, 5, 3); // 10:00 giờ VN

  setUp(() async {
    Clock.override(() => now);
    FlutterSecureStorage.setMockInitialValues({SecureStore.kRefreshToken: 'rt', SecureStore.kDeviceId: 'dev'});
    db = AppDatabase(NativeDatabase.memory());
    await seed(db);
    api = FakeSyncApi();
    worker = SyncWorker(
      db: db,
      api: api,
      store: SecureStore(),
      handlers: OpHandlers(db),
      pull: PullService(db: db, api: api),
    );
    messages.clear();
    worker.messages.listen(messages.add);
  });

  tearDown(() async {
    worker.dispose();
    await db.close();
    Clock.override(null);
  });

  void noKick() {}

  /// Mọi op trong lô nhận cùng một trạng thái.
  Map<String, dynamic> Function(List<Map<String, dynamic>>) all(String status,
          {Object? Function(Map<String, dynamic> op)? data, String? errorCode}) =>
      (ops) => {
            'serverTime': now.toIso8601String(),
            'clockOffsetMs': 0,
            'results': [for (final o in ops) result(o['opId'] as String, status, data: data?.call(o), errorCode: errorCode)],
            'user': userSnapshot,
          };

  Future<Quest> seedQuest({int current = 0}) async {
    await db.questDao.applyServer({
      'id': 'uq1',
      'questDefinitionId': 'qd1',
      'periodStart': '2026-10-05',
      'currentValue': current,
      'targetValue': 2,
      'xpReward': 20,
      'isClaimed': false,
    }, 0);
    return (await db.questDao.watchCurrentQuests(now).first).single;
  }

  test('APPLIED: áp data.progress, log -> synced, op bị xoá, snapshot user ghi vào user_profile', () async {
    final card = (await db.contentDao.watchCards('t1').first).first;
    await SrsRepository(db, noKick).rate(card, 'KNOW', responseTimeMs: 800);
    expect((await db.profileDao.current())!.pendingXp, 2);

    api.onPush = all('APPLIED', data: (o) => {
          'progress': {'flashcardId': card.id, 'box': 1, 'repetitions': 1, 'isLearned': false, 'version': 7},
          'xpAwarded': 2,
        });
    await worker.flush();

    expect(await db.syncDao.pendingCount(), 0);
    expect(await count(db, 'flashcard_review_logs', "sync_status = 'synced'"), 1);
    final p = await db.customSelect('SELECT version, is_dirty FROM user_flashcard_progress').getSingle();
    expect(p.read<int>('version'), 7);
    expect(p.read<int>('is_dirty'), 0);
    final user = (await db.profileDao.current())!;
    expect(user.currentXp, 120);
    expect(user.pendingXp, 0, reason: 'hàng đợi rỗng thì bỏ XP ước lượng');
  });

  test('lỗi mạng / FAILED -> giữ op pending, tăng attempt_count và backoff', () async {
    final card = (await db.contentDao.watchCards('t1').first).first;
    await SrsRepository(db, noKick).rate(card, 'AGAIN');

    api.onPush = (_) => throw offline;
    await worker.flush();
    var op = (await db.syncDao.nextBatch(nowMs: Clock.nowMs() + 5000)).single;
    expect(op.attemptCount, 1);
    expect(await db.syncDao.nextBatch(), isEmpty, reason: 'chưa tới hạn retry');

    // 429 cũng là lỗi tạm thời.
    api.onPush = (_) => throw const ApiException(status: 429, code: 'TOO_MANY_REQUESTS', message: '');
    Clock.override(() => now.add(const Duration(seconds: 6)));
    await worker.flush();
    op = (await db.syncDao.nextBatch(nowMs: Clock.nowMs() + 10000)).single;
    expect(op.attemptCount, 2);

    api.onPush = all('FAILED', errorCode: 'NOT_PROCESSED');
    Clock.override(() => now.add(const Duration(seconds: 20)));
    await worker.flush();
    op = (await db.syncDao.nextBatch(nowMs: Clock.nowMs() + 20000)).single;
    expect(op.attemptCount, 3);
    expect(await count(db, 'flashcard_review_logs'), 1, reason: 'FAILED không rollback');
  });

  test('REJECTED FLASHCARD_REVIEW: xoá log, phát lại các log còn lại, op -> dead', () async {
    final card = (await db.contentDao.watchCards('t1').first).first;
    final repo = SrsRepository(db, noKick);
    await repo.rate(card, 'KNOW');
    Clock.override(() => now.add(const Duration(minutes: 1)));
    await repo.rate(card, 'KNOW');
    expect((await db.srsDao.progressOf(card.id))!.box, 2);

    var i = 0;
    api.onPush = (ops) => {
          'results': [
            result(ops[0]['opId'] as String, 'APPLIED', data: {}),
            result(ops[1]['opId'] as String, 'REJECTED', errorCode: 'VALIDATION_ERROR'),
          ],
          'user': userSnapshot,
          'n': i++,
        };
    await worker.flush();

    expect(await count(db, 'flashcard_review_logs'), 1);
    expect((await db.srsDao.progressOf(card.id))!.box, 1);
    expect(await count(db, 'sync_queue', "status = 'dead' AND last_error = 'VALIDATION_ERROR'"), 1);
  });

  test('DUPLICATE kèm errorCode = bị từ chối: QUEST_CLAIM trả lại "chưa nhận", trừ pending_xp, báo tiến độ', () async {
    final quest = await seedQuest(current: 1);
    await QuestRepository(db, noKick, _NoGamificationApi(), PullService(db: db, api: api)).claim(quest);
    expect((await db.questDao.byId('uq1'))!.isClaimed, isTrue);
    expect((await db.profileDao.current())!.pendingXp, 20);

    api.onPush = all('DUPLICATE', errorCode: 'QUEST_NOT_COMPLETED');
    await worker.flush();

    expect((await db.questDao.byId('uq1'))!.isClaimed, isFalse);
    expect((await db.profileDao.current())!.pendingXp, 0);
    expect(messages.single, contains('Tiến độ 1/2'));
    expect(await count(db, 'sync_queue', "status = 'dead'"), 1);
  });

  test('REJECTED BOOKMARK_SET: trả trạng thái cũ', () async {
    await BookmarkRepository(db, noKick).toggle('f1');
    expect(await db.bookmarkDao.isBookmarked('f1'), isTrue);

    api.onPush = all('REJECTED', errorCode: 'NOT_FOUND');
    await worker.flush();
    expect(await db.bookmarkDao.isBookmarked('f1'), isFalse);
  });

  test('REJECTED QUIZ_SUBMIT (đề đã đổi): xoá bài làm, báo "Đề đã được cập nhật"', () async {
    final quiz = (await db.contentDao.quiz('qz1'))!;
    final questions = await db.contentDao.questionsWithOptions('qz1');
    final id = await QuizRepository(db, noKick).submit(quiz: quiz, questions: questions, answers: [0, 0], startedAt: now);
    expect(await count(db, 'quiz_attempts'), 1);

    api.onPush = all('REJECTED', errorCode: 'BUSINESS_RULE_VIOLATION');
    await worker.flush();
    expect(await db.quizDao.watchAttempt(id).first, isNull);
    expect(await count(db, 'quiz_attempt_answers'), 0);
    expect(messages.single, contains('Đề đã được cập nhật'));
  });

  test('CONFLICT_SERVER_WINS NOTE_UPSERT: ghi đè bằng bản server và báo "cập nhật từ thiết bị khác"', () async {
    final notes = NoteRepository(db, noKick);
    await notes.save('f1', 'ghi chú 1');
    await notes.save('f1', 'ghi chú 2'); // gộp vào op cũ
    expect(await db.syncDao.pendingCount(), 1);
    expect((await db.syncDao.nextBatch()).single.payload['content'], 'ghi chú 2');

    api.onPush = all('CONFLICT_SERVER_WINS', data: (o) => {
          'note': {'noteId': 'srv', 'flashcardId': 'f1', 'content': 'bản của máy khác', 'version': 5},
          'resolution': 'CONFLICT_SERVER_WINS',
        });
    await worker.flush();

    final n = (await db.noteDao.byFlashcard('f1'))!;
    expect(n.content, 'bản của máy khác');
    expect(n.version, 5);
    expect(n.isDirty, isFalse);
    expect(messages.single, 'Đã cập nhật từ thiết bị khác');
  });

  test('> 50 op: gửi nhiều lô liên tiếp theo FIFO', () async {
    for (var i = 0; i < 120; i++) {
      await db.syncDao.enqueue(opType: 'LESSON_COMPLETE', entityTable: 'lesson_completions', entityId: 'x$i', payload: {'i': i});
    }
    api.onPush = all('APPLIED', data: (_) => {});
    await worker.flush();
    expect(api.pushed.map((b) => b.length), [50, 50, 20]);
    expect(api.pushed.expand((b) => b).map((o) => o['payload']['i']), List.generate(120, (i) => i));
    expect(await db.syncDao.pendingCount(), 0);
  });

  test('op in_flight còn sót (app bị kill) được gửi lại ở lần flush đầu', () async {
    await db.syncDao.enqueue(opType: 'LESSON_COMPLETE', entityTable: 'lesson_completions', entityId: 'x', payload: {});
    await db.syncDao.markInFlight((await db.syncDao.nextBatch()).map((o) => o.id).toList());
    api.onPush = all('APPLIED', data: (_) => {});
    await worker.flush();
    expect(api.pushed.single.length, 1);
    expect(await db.syncDao.pendingCount(), 0);
  });
}

/// Repository nhiệm vụ trong test không gọi mạng.
class _NoGamificationApi implements GamificationApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
