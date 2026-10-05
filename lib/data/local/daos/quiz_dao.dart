import '../../../models/_json.dart';
import '../../../models/quiz_result_model.dart';
import '../../../models/quiz_review_model.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `quiz_attempts` + `quiz_attempt_answers`. Client chấm tạm, server chấm lại và ghi đè khi sync.
class QuizDao extends BaseDao {
  QuizDao(super.db);

  static const _a = 'quiz_attempts';
  static const _ans = 'quiz_attempt_answers';

  Future<void> insertAttempt({
    required String id,
    required String quizId,
    required int totalQuestions,
    required int correct,
    required int scorePercent,
    required int timeTakenSeconds,
    required int startedAtMs,
    required int submittedAtMs,
    required List<({String questionId, int? selected, bool isCorrect})> answers,
  }) async {
    await upsert(_a, {
      'id': id,
      'quiz_id': quizId,
      'total_questions': totalQuestions,
      'correct_answers': correct,
      'wrong_answers': totalQuestions - correct,
      'score_percent': scorePercent,
      'time_taken_seconds': timeTakenSeconds,
      'started_at': startedAtMs,
      'submitted_at': submittedAtMs,
      'xp_awarded': null,
      'sync_status': 'pending_create',
    }, const ['id']);
    for (final a in answers) {
      await upsert(_ans, {
        'attempt_id': id,
        'question_id': a.questionId,
        'selected_option_index': a.selected,
        'is_correct': a.isCorrect,
        'answered_at': submittedAtMs,
      }, const ['attempt_id', 'question_id']);
    }
  }

  Stream<QuizResult?> watchAttempt(String id) => select(
        'SELECT a.*, q.title AS quiz_title, q.pass_score_percent FROM $_a a '
        'LEFT JOIN quizzes q ON q.id = a.quiz_id WHERE a.id = ?',
        [id],
        const [_a, 'quizzes'],
      ).watch().map((rows) {
        if (rows.isEmpty) return null;
        final r = rows.first;
        return QuizResult(
          id: r.s('id'),
          quizId: r.s('quiz_id'),
          quizTitle: r.sN('quiz_title') ?? '',
          totalQuestions: r.i('total_questions'),
          correctAnswers: r.i('correct_answers'),
          wrongAnswers: r.i('wrong_answers'),
          scorePercent: r.i('score_percent'),
          passScorePercent: r.iN('pass_score_percent') ?? 70,
          timeTakenSeconds: r.i('time_taken_seconds'),
          xpAwarded: r.iN('xp_awarded'),
          submittedAt: fromEpoch(r.i('submitted_at'))!,
          isSynced: r.s('sync_status') == 'synced',
        );
      });

  /// Dựng màn xem lại từ `quiz_attempt_answers` ⨝ `quiz_questions` (+ 4 đáp án).
  Future<List<QuizReviewItem>> reviewItems(String attemptId) async {
    final rows = await select(
      'SELECT qq.id, qq.question_text, qq.correct_option_index, qq.explanation, ans.selected_option_index, ans.is_correct '
      'FROM $_ans ans JOIN quiz_questions qq ON qq.id = ans.question_id '
      'WHERE ans.attempt_id = ? ORDER BY qq.sort_order',
      [attemptId],
    ).get();
    final out = <QuizReviewItem>[];
    for (final r in rows) {
      final opts = await select(
        'SELECT option_text FROM quiz_question_options WHERE question_id = ? ORDER BY option_index',
        [r.s('id')],
      ).get();
      out.add(QuizReviewItem(
        id: r.s('id'),
        question: r.s('question_text'),
        options: opts.map((o) => o.s('option_text')).toList(),
        correctIndex: r.i('correct_option_index'),
        userIndex: r.iN('selected_option_index') ?? -1,
        isCorrect: r.b('is_correct'),
        explanation: r.sN('explanation') ?? '',
      ));
    }
    return out;
  }

  Future<({String quizId, int scorePercent})?> byId(String id) async {
    final rows = await select('SELECT quiz_id, score_percent FROM $_a WHERE id = ?', [id]).get();
    return rows.isEmpty ? null : (quizId: rows.first.s('quiz_id'), scorePercent: rows.first.i('score_percent'));
  }

  /// `QuizResultResponse`: server chấm lại.
  Future<void> applyServer(Map<String, dynamic> r, int nowMs) => update(
        "UPDATE $_a SET correct_answers = ?, wrong_answers = ?, score_percent = ?, xp_awarded = ?, "
        "sync_status = 'synced', last_synced_at = ? WHERE id = ?",
        [
          jInt(r['correctAnswers']),
          jInt(r['wrongAnswers']),
          jInt(r['scorePercent']),
          jInt(r['xpAwarded']),
          nowMs,
          r['id'],
        ],
        const [_a],
      );

  Future<void> delete(String id) => deleteWhere(_a, 'id = ?', [id]);

  Future<int> attemptsBetween(String quizId, int fromMs, int toMs, {String? excludeId}) async => (await select(
        'SELECT COUNT(*) AS c FROM $_a WHERE quiz_id = ? AND submitted_at >= ? AND submitted_at < ? AND id <> ?',
        [quizId, fromMs, toMs, excludeId ?? ''],
      ).getSingle())
          .i('c');
}
