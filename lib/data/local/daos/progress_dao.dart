import '../../../models/_json.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `user_topic_progress`, `user_grammar_progress`: client tính lạc quan theo đúng luật của
/// `ContentProgressService` ở server, server trả giá trị chuẩn khi pull.
class ProgressDao extends BaseDao {
  ProgressDao(super.db);

  static const _topic = 'user_topic_progress';
  static const _grammar = 'user_grammar_progress';

  /// Đếm lại số từ đã thuộc (không +1/-1). Mọi lần ôn đều làm topic thành IN_PROGRESS,
  /// đủ số từ thì COMPLETED.
  Future<void> refreshTopic(String topicId, int studiedAtMs) async {
    final r = await select(
      'SELECT t.total_words, '
      '(SELECT COUNT(*) FROM user_flashcard_progress p JOIN flashcards f ON f.id = p.flashcard_id '
      ' WHERE f.topic_id = t.id AND p.is_learned = 1) AS learned, '
      'up.completed_at, up.last_studied_at '
      'FROM topics t LEFT JOIN $_topic up ON up.topic_id = t.id WHERE t.id = ?',
      [topicId],
    ).get();
    if (r.isEmpty) return;
    final total = r.first.i('total_words');
    final learned = r.first.i('learned');
    final done = total > 0 && learned >= total;
    final last = r.first.iN('last_studied_at');
    await upsert(_topic, {
      'topic_id': topicId,
      'learned_words': learned,
      'status': done ? 'COMPLETED' : 'IN_PROGRESS',
      'completed_at': done ? (r.first.iN('completed_at') ?? studiedAtMs) : null,
      'last_studied_at': last == null || studiedAtMs > last ? studiedAtMs : last,
      'is_dirty': 1,
      'sync_status': 'pending_update',
    }, const ['topic_id']);
  }

  /// Đọc xong bài ngữ pháp: chủ điểm không có quiz thì COMPLETED, có quiz thì IN_PROGRESS (progress >= 0.5).
  Future<void> grammarLessonCompleted(String grammarId, {required bool hasQuiz, required int atMs}) async {
    final cur = await _grammarRow(grammarId);
    if (cur?.status == 'COMPLETED') {
      await _touchGrammar(grammarId, atMs);
      return;
    }
    await upsert(_grammar, {
      'grammar_lesson_id': grammarId,
      'progress': hasQuiz ? ((cur?.progress ?? 0) > 0.5 ? cur!.progress : 0.5) : 1.0,
      'status': hasQuiz ? 'IN_PROGRESS' : 'COMPLETED',
      'completed_at': hasQuiz ? null : atMs,
      'last_studied_at': atMs,
      'is_dirty': 1,
      'sync_status': 'pending_update',
    }, const ['grammar_lesson_id']);
  }

  Future<void> grammarQuizScored(String grammarId, {required int scorePercent, required bool passed, required int atMs}) async {
    final cur = await _grammarRow(grammarId);
    final best = cur?.best == null ? scorePercent : (cur!.best! > scorePercent ? cur.best! : scorePercent);
    final status = passed ? 'COMPLETED' : (cur == null || cur.status == 'NOT_STARTED' ? 'IN_PROGRESS' : cur.status);
    await upsert(_grammar, {
      'grammar_lesson_id': grammarId,
      'progress': passed ? 1.0 : (cur?.progress ?? 0.0),
      'status': status,
      'best_score_percent': best,
      'completed_at': passed ? (cur?.completedAt ?? atMs) : cur?.completedAt,
      'last_studied_at': atMs,
      'is_dirty': 1,
      'sync_status': 'pending_update',
    }, const ['grammar_lesson_id']);
  }

  /// Pull: `TopicProgressRow`.
  Future<void> applyServerTopic(Map<String, dynamic> p, int nowMs) async {
    final id = p['topicId'] as String;
    if (await _dirty(_topic, 'topic_id', id) || !await _exists('topics', id)) return;
    await upsert(_topic, {
      'topic_id': id,
      'learned_words': jInt(p['learnedWords']),
      'status': jStr(p['status'], 'NOT_STARTED'),
      'last_studied_at': toEpoch(p['lastStudiedAt'] as String?),
      'completed_at': toEpoch(p['completedAt'] as String?),
      'version': jInt(p['version']),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['topic_id']);
  }

  /// Pull: `GrammarProgressRow`.
  Future<void> applyServerGrammar(Map<String, dynamic> p, int nowMs) async {
    final id = p['grammarLessonId'] as String;
    if (await _dirty(_grammar, 'grammar_lesson_id', id) || !await _exists('grammar_lessons', id)) return;
    await upsert(_grammar, {
      'grammar_lesson_id': id,
      'progress': jDouble(p['progress']).clamp(0.0, 1.0),
      'status': jStr(p['status'], 'NOT_STARTED'),
      'best_score_percent': jIntN(p['bestScorePercent']),
      'last_studied_at': toEpoch(p['lastStudiedAt'] as String?),
      'completed_at': toEpoch(p['completedAt'] as String?),
      'version': jInt(p['version']),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['grammar_lesson_id']);
  }

  Future<({double progress, String status, int? best, int? completedAt})?> _grammarRow(String id) async {
    final rows = await select('SELECT * FROM $_grammar WHERE grammar_lesson_id = ?', [id]).get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return (progress: r.d('progress'), status: r.s('status'), best: r.iN('best_score_percent'), completedAt: r.iN('completed_at'));
  }

  Future<void> _touchGrammar(String id, int atMs) => update(
        'UPDATE $_grammar SET last_studied_at = MAX(COALESCE(last_studied_at, 0), ?) WHERE grammar_lesson_id = ?',
        [atMs, id],
        const [_grammar],
      );

  Future<bool> _dirty(String table, String pk, String id) async {
    final rows = await select('SELECT is_dirty FROM $table WHERE $pk = ?', [id]).get();
    return rows.isNotEmpty && rows.first.b('is_dirty');
  }

  Future<bool> _exists(String table, String id) async =>
      (await select('SELECT COUNT(*) AS c FROM $table WHERE id = ?', [id]).getSingle()).i('c') > 0;
}
