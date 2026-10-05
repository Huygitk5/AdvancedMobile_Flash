import '../../core/ids.dart';
import '../../models/flashcard_model.dart';
import '../../models/quiz_model.dart';
import '../local/converters.dart';
import '../sync/srs.dart';
import '../sync/xp_estimator.dart';
import 'base_repository.dart';

/// Again / Know trên FlashcardScreen -> FLASHCARD_REVIEW.
class SrsRepository extends WriteRepository {
  SrsRepository(super.db, super.kick);

  /// [rating]: 'AGAIN' | 'KNOW'. Trả về XP ước lượng (để hiển thị).
  Future<int> rate(Flashcard card, String rating, {int? responseTimeMs}) async {
    final at = now();
    final atMs = at.toUtc().millisecondsSinceEpoch;
    final logId = newId();
    var xp = 0;

    await db.transaction(() async {
      final srs = db.srsDao;
      final prev = await srs.progressOf(card.id);
      final logs = await srs.logsOf(card.id);
      final wasLearned = prev?.isLearned ?? false;
      final everLearned = await srs.everLearned(card.id);
      final (dayStart, dayEnd) = WriteRepository.dayBounds(at);
      final knowCardsToday = await srs.knowCardsBetween(dayStart, dayEnd);
      final firstKnowToday = rating == 'KNOW' && !await srs.hasKnowBetween(card.id, dayStart, dayEnd);

      final state = Srs.replay([...logs, SrsLog(id: logId, rating: rating, reviewedAt: at.toUtc())]);
      final (before, after) = state.boxes[logId]!;
      await srs.insertLog(
        id: logId,
        cardId: card.id,
        rating: rating,
        boxBefore: before,
        boxAfter: after,
        responseTimeMs: responseTimeMs,
        reviewedAtMs: atMs,
      );
      await srs.updateLogBoxes(Map.of(state.boxes)..remove(logId));
      await srs.writeProgress(card.id, state, nowMs: atMs);

      final becameLearned = !wasLearned && state.isLearned;
      xp = XpEstimator.review(
        isKnow: rating == 'KNOW',
        firstKnowOfCardToday: firstKnowToday,
        knowXpToday: knowCardsToday * XpEstimator.knowXp,
        becameLearnedFirstTime: becameLearned && !everLearned,
      );

      await recordActivity(at);
      // Chỉ tính "từ mới học" ở lần Know đầu tiên của thẻ; Know -> Again -> Know không đếm lại (giống server)
      final newWord = becameLearned && state.knowCount == 1;
      await db.statsDao.bump(localDateKey(at), cardsReviewed: 1, wordsLearned: newWord ? 1 : 0, xpGained: xp);
      await db.profileDao.addPendingXp(xp);
      if (wasLearned != state.isLearned) await db.profileDao.setTotalWordsLearned(await srs.learnedTotal());
      await db.questDao.bump('REVIEW_CARDS', 1, at);
      if (logs.isEmpty) await db.questDao.bump('LEARN_WORDS', 1, at);
      await db.progressDao.refreshTopic(card.topicId, atMs);

      await db.syncDao.enqueue(
        opType: 'FLASHCARD_REVIEW',
        entityTable: 'flashcard_review_logs',
        entityId: logId,
        payload: {
          'logId': logId,
          'flashcardId': card.id,
          'rating': rating,
          'responseTimeMs': ?responseTimeMs,
          'reviewedAt': isoNow(at),
        },
      );
    });
    kick();
    return xp;
  }
}

/// Dialog ghi chú ở FlashcardScreen -> NOTE_UPSERT / NOTE_DELETE.
class NoteRepository extends WriteRepository {
  NoteRepository(super.db, super.kick);

  /// Nội dung rỗng = xoá ghi chú.
  Future<void> save(String cardId, String content) async {
    final text = content.trim();
    if (text.isEmpty) return delete(cardId);
    final at = now();
    await db.transaction(() async {
      final r = await db.noteDao.saveLocal(cardId, text, at.toUtc().millisecondsSinceEpoch);
      await db.syncDao.enqueue(
        opType: 'NOTE_UPSERT',
        entityTable: 'user_flashcard_notes',
        entityId: cardId,
        payload: {
          'noteId': r.noteId,
          'flashcardId': cardId,
          'content': text,
          'baseVersion': r.baseVersion,
          'clientUpdatedAt': isoNow(at),
        },
      );
    });
    kick();
  }

  Future<void> delete(String cardId) async {
    final at = now();
    await db.transaction(() async {
      final r = await db.noteDao.deleteLocal(cardId, at.toUtc().millisecondsSinceEpoch);
      if (r == null) return;
      await db.syncDao.enqueue(
        opType: 'NOTE_DELETE',
        entityTable: 'user_flashcard_notes',
        entityId: cardId,
        payload: {
          'noteId': r.noteId,
          'flashcardId': cardId,
          'baseVersion': r.baseVersion,
          'clientUpdatedAt': isoNow(at),
        },
      );
    });
    kick();
  }
}

/// Nút lưu từ trên thẻ (FlashcardScreen) / màn Từ đã lưu -> BOOKMARK_SET.
class BookmarkRepository extends WriteRepository {
  BookmarkRepository(super.db, super.kick);

  /// Trả về trạng thái mới.
  Future<bool> toggle(String cardId) async {
    final at = now();
    late bool next;
    await db.transaction(() async {
      next = !await db.bookmarkDao.isBookmarked(cardId);
      await db.bookmarkDao.setLocal(cardId, next, at.toUtc().millisecondsSinceEpoch);
      await db.syncDao.enqueue(
        opType: 'BOOKMARK_SET',
        entityTable: 'user_bookmarks',
        entityId: cardId,
        payload: {'flashcardId': cardId, 'bookmarked': next, 'clientUpdatedAt': isoNow(at)},
      );
    });
    kick();
    return next;
  }
}

/// Hoàn thành bài học (thẻ cuối của topic, hoặc đọc xong bài ngữ pháp) -> LESSON_COMPLETE.
class LessonRepository extends WriteRepository {
  LessonRepository(super.db, super.kick);

  Future<({String id, int xpEstimate})> completeTopic(String topicId,
          {required int cardsReviewed, required int durationSeconds}) =>
      _complete('TOPIC', topicId: topicId, cardsReviewed: cardsReviewed, durationSeconds: durationSeconds);

  Future<({String id, int xpEstimate})> completeGrammar(String grammarId, {required int durationSeconds}) =>
      _complete('GRAMMAR', grammarLessonId: grammarId, durationSeconds: durationSeconds);

  Future<({String id, int xpEstimate})> _complete(
    String type, {
    String? topicId,
    String? grammarLessonId,
    int cardsReviewed = 0,
    required int durationSeconds,
  }) async {
    final at = now();
    final atMs = at.toUtc().millisecondsSinceEpoch;
    final id = newId();
    final duration = durationSeconds.clamp(0, 86400);
    var xp = 0;
    await db.transaction(() async {
      final (dayStart, dayEnd) = WriteRepository.dayBounds(at);
      final lessonDao = db.lessonDao;
      // "Bài học hoàn thành" đếm số bài khác nhau: học lại một bài đã xong chỉ ghi nhận lượt học (giống server)
      final firstCompletion = !await lessonDao.existsFor(topicId: topicId, grammarLessonId: grammarLessonId);
      xp = XpEstimator.lesson(
        lessonsBeforeToday: await lessonDao.countBetween(dayStart, dayEnd),
        sameLessonToday:
            await lessonDao.existsFor(topicId: topicId, grammarLessonId: grammarLessonId, fromMs: dayStart, toMs: dayEnd),
      );
      await lessonDao.insert(
        id: id,
        lessonType: type,
        topicId: topicId,
        grammarLessonId: grammarLessonId,
        cardsReviewed: cardsReviewed,
        durationSeconds: duration,
        completedAtMs: atMs,
      );
      await recordActivity(at);
      await db.statsDao.bump(localDateKey(at), lessonsCompleted: 1, xpGained: xp, studySeconds: duration);
      if (firstCompletion) await db.profileDao.bumpCounters(completedLessons: 1);
      await db.profileDao.addPendingXp(xp);
      await db.questDao.bump('COMPLETE_LESSON', 1, at);
      await db.questDao.bump('STUDY_MINUTES', duration ~/ 60, at);
      if (grammarLessonId != null) {
        final hasQuiz = await db.contentDao.quizForGrammar(grammarLessonId) != null;
        await db.progressDao.grammarLessonCompleted(grammarLessonId, hasQuiz: hasQuiz, atMs: atMs);
      }
      await db.syncDao.enqueue(
        opType: 'LESSON_COMPLETE',
        entityTable: 'lesson_completions',
        entityId: id,
        payload: {
          'id': id,
          'lessonType': type,
          'topicId': ?topicId,
          'grammarLessonId': ?grammarLessonId,
          'cardsReviewed': cardsReviewed,
          'durationSeconds': duration,
          'completedAt': isoNow(at),
        },
      );
    });
    kick();
    return (id: id, xpEstimate: xp);
  }
}

/// Nộp bài trên QuizScreen -> QUIZ_SUBMIT. Chấm tạm ở client; server chấm lại.
class QuizRepository extends WriteRepository {
  QuizRepository(super.db, super.kick);

  /// [answers][i] = đáp án chọn cho [questions][i] (null = bỏ qua). Phải gửi đủ mọi câu của đề.
  Future<String> submit({
    required Quiz quiz,
    required List<QuizQuestion> questions,
    required List<int?> answers,
    required DateTime startedAt,
  }) async {
    final at = now();
    final atMs = at.toUtc().millisecondsSinceEpoch;
    final attemptId = newId();
    final total = questions.length;
    var correct = 0;
    final rows = <({String questionId, int? selected, bool isCorrect})>[];
    for (var i = 0; i < total; i++) {
      final selected = i < answers.length ? answers[i] : null;
      final ok = selected != null && selected == questions[i].correctAnswerIndex;
      if (ok) correct++;
      rows.add((questionId: questions[i].id, selected: selected, isCorrect: ok));
    }
    final score = total == 0 ? 0 : (correct * 100 / total).round();
    final timeTaken = at.difference(startedAt).inSeconds.clamp(total, 86400);

    await db.transaction(() async {
      final (dayStart, dayEnd) = WriteRepository.dayBounds(at);
      final first = await db.quizDao.attemptsBetween(quiz.id, dayStart, dayEnd) == 0;
      final xp = XpEstimator.quiz(correct: correct, total: total, firstAttemptToday: first);
      await db.quizDao.insertAttempt(
        id: attemptId,
        quizId: quiz.id,
        totalQuestions: total,
        correct: correct,
        scorePercent: score,
        timeTakenSeconds: timeTaken,
        startedAtMs: startedAt.toUtc().millisecondsSinceEpoch,
        submittedAtMs: atMs,
        answers: rows,
      );
      await recordActivity(at);
      await db.statsDao.bump(localDateKey(at),
          quizzesCompleted: 1, correctAnswers: correct, totalAnswers: total, xpGained: xp, studySeconds: timeTaken);
      await db.profileDao.addPendingXp(xp);
      await db.questDao.bump('COMPLETE_QUIZ', 1, at);
      if (total > 0 && correct == total) await db.questDao.bump('PERFECT_QUIZ', 1, at);
      await db.questDao.bump('STUDY_MINUTES', timeTaken ~/ 60, at);
      if (quiz.grammarLessonId != null) {
        await db.progressDao.grammarQuizScored(quiz.grammarLessonId!,
            scorePercent: score, passed: score >= quiz.passScorePercent, atMs: atMs);
      }
      await db.syncDao.enqueue(
        opType: 'QUIZ_SUBMIT',
        entityTable: 'quiz_attempts',
        entityId: attemptId,
        payload: {
          'attemptId': attemptId,
          'quizId': quiz.id,
          'startedAt': isoNow(startedAt),
          'submittedAt': isoNow(at),
          'timeTakenSeconds': timeTaken,
          'answers': [
            for (final r in rows) {'questionId': r.questionId, 'selectedOptionIndex': r.selected},
          ],
        },
      );
    });
    kick();
    return attemptId;
  }
}
