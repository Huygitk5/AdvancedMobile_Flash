import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/core/clock.dart';
import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/remote/apis/gamification_api.dart';
import 'package:flash/data/repositories/study_repositories.dart';
import 'package:flash/data/repositories/user_repositories.dart';

import '../sync/sync_fixtures.dart';

/// Ghi lạc quan + enqueue nằm cùng transaction (G7.3).
void main() {
  late AppDatabase db;
  var kicks = 0;
  final now = DateTime.utc(2026, 10, 5, 3);

  setUp(() async {
    Clock.override(() => now);
    db = AppDatabase(NativeDatabase.memory());
    await seed(db);
    await db.questDao.applyServer({
      'id': 'uq1',
      'questDefinitionId': 'qd1',
      'periodStart': '2026-10-05',
      'currentValue': 0,
      'targetValue': 2,
      'xpReward': 20,
      'isClaimed': false,
    }, 0);
    kicks = 0;
  });

  tearDown(() async {
    await db.close();
    Clock.override(null);
  });

  void kick() => kicks++;

  test('rate: log + progress + quest + thống kê + tiến độ topic, payload đúng body REST, rồi kick', () async {
    final repo = SrsRepository(db, kick);
    final card = (await db.contentDao.watchCards('t1').first).first;
    final xp = await repo.rate(card, 'KNOW', responseTimeMs: 1200);

    expect(xp, 2);
    expect(kicks, 1);
    final op = (await db.syncDao.nextBatch()).single;
    expect(op.opType, 'FLASHCARD_REVIEW');
    expect(op.payload.keys, containsAll(['logId', 'flashcardId', 'rating', 'responseTimeMs', 'reviewedAt']));
    expect(op.payload['rating'], 'KNOW');
    expect((await db.srsDao.progressOf(card.id))!.box, 1);
    expect((await db.questDao.byId('uq1'))!.current, 1);
    expect((await db.statsDao.watchDay('2026-10-05').first)!.cardsReviewed, 1);
    final topic = (await db.contentDao.watchTopic('t1').first)!;
    expect(topic.status, 'IN_PROGRESS');
    expect((await db.profileDao.current())!.displayXp, 102);
  });

  test('3 lần Know -> thẻ thuộc: +5 XP lần đầu, đếm lại số từ đã thuộc', () async {
    final repo = SrsRepository(db, kick);
    final card = (await db.contentDao.watchCards('t1').first).firstWhere((c) => c.id == 'f1');
    await repo.rate(card, 'KNOW');
    Clock.override(() => now.add(const Duration(days: 1)));
    await repo.rate(card, 'KNOW');
    Clock.override(() => now.add(const Duration(days: 4)));
    final xp = await repo.rate(card, 'KNOW');
    expect(xp, 2 + 5);
    expect((await db.profileDao.current())!.totalWordsLearned, 1);
    expect((await db.contentDao.watchTopic('t1').first)!.learnedWords, 1);
  });

  test('quiz: chấm tạm, gửi ĐỦ mọi câu (câu bỏ qua = null), xp_awarded NULL tới khi server chấm', () async {
    final quiz = (await db.contentDao.quiz('qz1'))!;
    final questions = await db.contentDao.questionsWithOptions('qz1');
    final id = await QuizRepository(db, kick)
        .submit(quiz: quiz, questions: questions, answers: [0, null], startedAt: now.subtract(const Duration(seconds: 30)));

    final attempt = (await db.quizDao.watchAttempt(id).first)!;
    expect(attempt.correctAnswers, 1);
    expect(attempt.scorePercent, 50);
    expect(attempt.xpAwarded, isNull);
    final answers = (await db.syncDao.nextBatch()).single.payload['answers'] as List;
    expect(answers, [
      {'questionId': 'qq1', 'selectedOptionIndex': 0},
      {'questionId': 'qq2', 'selectedOptionIndex': null},
    ]);
    expect((await db.quizDao.reviewItems(id)).map((r) => r.userIndex), [0, -1]);
  });

  test('lesson complete: lesson_completions + completed_lessons + lessons_completed hôm nay', () async {
    final r = await LessonRepository(db, kick).completeTopic('t1', cardsReviewed: 2, durationSeconds: 125);
    expect(r.xpEstimate, 10);
    expect(await count(db, 'lesson_completions'), 1);
    expect((await db.profileDao.current())!.completedLessons, 1);
    expect((await db.statsDao.watchDay('2026-10-05').first)!.lessonsCompleted, 1);
    final op = (await db.syncDao.nextBatch()).single;
    expect(op.payload['lessonType'], 'TOPIC');
    expect(op.payload['durationSeconds'], 125);
  });

  test('trang bị vật phẩm: tháo món cùng loại, ITEM_EQUIP gộp theo inventoryId', () async {
    final nowMs = Clock.nowMs();
    await db.contentDao.upsertRewardItem({'id': 'r2', 'code': 'B2', 'name': 'Băng', 'itemType': 'BORDER', 'borderColors': [1, 2]});
    await db.shopDao.applyInventory({'id': 'i1', 'rewardItemId': 'r1', 'isEquipped': true}, nowMs: nowMs);
    await db.shopDao.applyInventory({'id': 'i2', 'rewardItemId': 'r2', 'isEquipped': false}, nowMs: nowMs);
    final items = await db.shopDao.watchInventoryWithItems().first;

    await ShopRepository(db, kick, _NoApi()).setEquipped(items.firstWhere((i) => i.id == 'r2'), true);
    final after = {for (final i in await db.shopDao.watchInventoryWithItems().first) i.id: i.isEquipped};
    expect(after, {'r1': false, 'r2': true});
    expect((await db.syncDao.nextBatch()).single.payload, containsPair('inventoryId', 'i2'));
    expect((await db.profileDao.current())!.equippedBorderColors, [1, 2]);
  });

  test('đổi slogan: user_profile dirty, pull user không đè slogan local', () async {
    await ProfileRepository(db, kick).updateSlogan('Mới');
    final op = (await db.syncDao.nextBatch()).single;
    expect(op.payload, containsPair('baseVersion', 1));
    await db.profileDao.upsertFromUser({...seedUser, 'slogan': 'Server cũ', 'currentXp': 50}, 0);
    final u = (await db.profileDao.current())!;
    expect(u.slogan, 'Mới');
    expect(u.currentXp, 50);
  });
}

class _NoApi implements GamificationApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
