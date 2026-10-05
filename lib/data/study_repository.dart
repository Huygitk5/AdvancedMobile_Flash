import '../models/flashcard_model.dart';
import '../models/json_helpers.dart';
import '../models/quiz_model.dart';
import '../core/utils.dart';
import 'api/api_client.dart';
import 'app_state.dart';

/// Kết quả một lần ôn thẻ: XP vừa nhận (server tính, đã chống cộng trùng).
class ReviewOutcome {
  final int xpAwarded;
  final bool isLearned;
  final bool duplicate;

  const ReviewOutcome({this.xpAwarded = 0, this.isLearned = false, this.duplicate = false});
}

class LessonOutcome {
  final int xpAwarded;
  final int todayDone;
  final int todayGoal;

  const LessonOutcome({this.xpAwarded = 0, this.todayDone = 0, this.todayGoal = 5});
}

/// Các thao tác ghi tiến độ học. XP, streak, từ đã học, bài hoàn thành đều do server tính;
/// app chỉ gửi sự kiện (kèm id sinh ở client để gửi lại không bị cộng trùng) rồi nhận lại UserSnapshot.
class StudyRepository {
  StudyRepository._();

  static ApiClient get _api => ApiClient.I;

  /// Chấm "Know" / "Again" cho một thẻ.
  static Future<ReviewOutcome> review(Flashcard card, {required bool know, int responseTimeMs = 0}) async {
    final data = asMap(await _api.post('/v1/flashcards/review', body: {
      'logId': uuidV4(),
      'flashcardId': card.id,
      'rating': know ? 'KNOW' : 'AGAIN',
      'responseTimeMs': responseTimeMs.clamp(0, 3600000),
      'reviewedAt': DateTime.now().toUtc().toIso8601String(),
    }));
    AppState.I.applySnapshot(data['user']);
    final progress = asMap(data['progress']);
    card.isLearned = jBool(progress, 'isLearned');
    card.srsBox = jInt(progress, 'box');
    return ReviewOutcome(
        xpAwarded: jInt(data, 'xpAwarded'), isLearned: card.isLearned, duplicate: jBool(data, 'duplicate'));
  }

  /// Hoàn thành một bài học (hết bộ thẻ của chủ đề, hoặc đọc xong chủ điểm ngữ pháp).
  static Future<LessonOutcome> completeLesson(
      {String? topicId, String? grammarLessonId, int cardsReviewed = 0, int durationSeconds = 0}) async {
    assert((topicId == null) != (grammarLessonId == null));
    final data = asMap(await _api.post('/v1/lessons/complete', body: {
      'id': uuidV4(),
      'lessonType': topicId != null ? 'TOPIC' : 'GRAMMAR',
      'topicId': topicId,
      'grammarLessonId': grammarLessonId,
      'cardsReviewed': cardsReviewed,
      'durationSeconds': durationSeconds.clamp(0, 86400),
      'completedAt': DateTime.now().toUtc().toIso8601String(),
    }));
    AppState.I.applySnapshot(data['user']);
    final today = asMap(data['todayLessons']);
    return LessonOutcome(
        xpAwarded: jInt(data, 'xpAwarded'), todayDone: jInt(today, 'done'), todayGoal: jInt(today, 'goal', 5));
  }

  /// Nộp bài kiểm tra: server chấm lại từ danh sách đáp án (-1 / null = bỏ qua).
  static Future<QuizResult> submitQuiz({
    required String quizId,
    required List<QuizQuestion> questions,
    required List<int?> answers,
    required DateTime startedAt,
  }) async {
    final now = DateTime.now();
    final seconds = now.difference(startedAt).inSeconds;
    final data = asMap(await _api.post('/v1/quizzes/submit', body: {
      'attemptId': uuidV4(),
      'quizId': quizId,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'submittedAt': now.toUtc().toIso8601String(),
      // Server yêu cầu thời gian làm bài ≥ số câu (1 giây/câu)
      'timeTakenSeconds': seconds < questions.length ? questions.length : seconds,
      'answers': [
        for (var i = 0; i < questions.length; i++) {'questionId': questions[i].id, 'selectedOptionIndex': answers[i]}
      ],
    }));
    // Quiz cộng XP / streak ở server nên tải lại hồ sơ để có con số mới nhất
    await AppState.I.refreshAll();
    return QuizResult.fromJson(data);
  }

  static Future<List<QuizReviewItem>> attemptReview(String attemptId) async {
    final data = await _api.get('/v1/quizzes/attempts/get/$attemptId/review');
    return asMapList(data).map(QuizReviewItem.fromJson).toList();
  }

  static Future<void> setBookmark(Flashcard card, bool bookmarked) async {
    if (bookmarked) {
      await _api.post('/v1/flashcards/bookmarks/create',
          body: {'flashcardId': card.id, 'clientUpdatedAt': DateTime.now().toUtc().toIso8601String()});
    } else {
      await _api.delete('/v1/flashcards/bookmarks/delete/${card.id}');
    }
    card.isBookmarked = bookmarked;
  }

  /// Lưu ghi chú cá nhân của một từ (rỗng = xoá ghi chú).
  static Future<void> saveNote(Flashcard card, String content) async {
    final text = content.trim();
    if (text.isEmpty) {
      if ((card.note ?? '').isNotEmpty) await _api.delete('/v1/flashcards/notes/delete/${card.id}');
      card.note = null;
      card.noteVersion = null;
      return;
    }
    final data = asMap(await _api.put('/v1/flashcards/notes/update', body: {
      'noteId': uuidV4(),
      'flashcardId': card.id,
      'content': text,
      'baseVersion': card.noteVersion,
      'clientUpdatedAt': DateTime.now().toUtc().toIso8601String(),
    }));
    final note = asMap(data['note']);
    card.note = jStrOrNull(note, 'content') ?? text;
    card.noteVersion = note['version'] == null ? card.noteVersion : jInt(note, 'version');
  }
}
