import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('NOTE_UPSERT pending cùng entity được gộp, giữ op_id cũ', () async {
    final a = await db.syncDao.enqueue(
        opType: 'NOTE_UPSERT', entityTable: 'user_flashcard_notes', entityId: 'n1', payload: {'content': 'a'});
    final b = await db.syncDao.enqueue(
        opType: 'NOTE_UPSERT', entityTable: 'user_flashcard_notes', entityId: 'n1', payload: {'content': 'b'});
    expect(b, a);
    final ops = await db.syncDao.nextBatch();
    expect(ops.length, 1);
    expect(ops.single.payload['content'], 'b');
  });

  test('FLASHCARD_REVIEW không bao giờ bị gộp', () async {
    for (var i = 0; i < 3; i++) {
      await db.syncDao.enqueue(
          opType: 'FLASHCARD_REVIEW', entityTable: 'flashcard_review_logs', entityId: 'l$i', payload: {'i': i});
    }
    expect((await db.syncDao.nextBatch()).length, 3);
  });

  test('op in_flight không bị gộp, và resetInFlight đưa về pending', () async {
    final first = await db.syncDao.enqueue(
        opType: 'BOOKMARK_SET', entityTable: 'user_bookmarks', entityId: 'f1', payload: {'bookmarked': true});
    final ops = await db.syncDao.nextBatch();
    await db.syncDao.markInFlight(ops.map((o) => o.id).toList());

    final second = await db.syncDao.enqueue(
        opType: 'BOOKMARK_SET', entityTable: 'user_bookmarks', entityId: 'f1', payload: {'bookmarked': false});
    expect(second, isNot(first));
    expect(await db.syncDao.pendingCount(), 2);

    expect(await db.syncDao.resetInFlight(), 1);
    expect((await db.syncDao.nextBatch()).length, 2);
  });

  test('nextBatch giữ FIFO và tôn trọng limit', () async {
    for (var i = 0; i < 5; i++) {
      await db.syncDao.enqueue(
          opType: 'LESSON_COMPLETE', entityTable: 'lesson_completions', entityId: 'x$i', payload: {'i': i});
    }
    final ops = await db.syncDao.nextBatch(limit: 3);
    expect(ops.map((o) => o.payload['i']), [0, 1, 2]);
  });

  test('scheduleRetry: backoff 5s, 10s, 20s... tối đa 30 phút, và nextBatch bỏ qua op chưa tới hạn', () async {
    await db.syncDao.enqueue(
        opType: 'LESSON_COMPLETE', entityTable: 'lesson_completions', entityId: 'x', payload: {});
    const now = 1000000;
    var op = (await db.syncDao.nextBatch(nowMs: now)).single;

    await db.syncDao.scheduleRetry(op, nowMs: now, error: 'NETWORK');
    expect(await db.syncDao.nextBatch(nowMs: now + 4999), isEmpty);
    op = (await db.syncDao.nextBatch(nowMs: now + 5000)).single;
    expect(op.attemptCount, 1);

    await db.syncDao.scheduleRetry(op, nowMs: now, error: 'NETWORK');
    expect(await db.syncDao.nextBatch(nowMs: now + 9999), isEmpty);
    expect((await db.syncDao.nextBatch(nowMs: now + 10000)).length, 1);
  });

  test('markDead và markDone', () async {
    await db.syncDao.enqueue(
        opType: 'QUEST_CLAIM', entityTable: 'user_quests', entityId: 'q', payload: {});
    final op = (await db.syncDao.nextBatch()).single;
    await db.syncDao.markDead(op.id, 'QUEST_NOT_COMPLETED');
    expect(await db.syncDao.nextBatch(), isEmpty);
    expect(await db.syncDao.pendingCount(), 0);

    await db.syncDao.markDone(op.id);
    final r = await db.customSelect('SELECT COUNT(*) AS c FROM sync_queue').getSingle();
    expect(r.read<int>('c'), 0);
  });

  test('cursor: null lúc đầu, ghi đè khi set lại', () async {
    expect(await db.syncDao.getCursor('content'), isNull);
    await db.syncDao.setCursor('content', 'c1');
    await db.syncDao.setCursor('content', 'c2');
    expect(await db.syncDao.getCursor('content'), 'c2');
    expect(await db.syncDao.getCursor('user_data'), isNull);
  });
}
