import 'base_dao.dart';

/// `lesson_completions`: append-only, mỗi lần hoàn thành một bài (topic hoặc ngữ pháp).
class LessonDao extends BaseDao {
  LessonDao(super.db);

  static const _t = 'lesson_completions';

  Future<void> insert({
    required String id,
    required String lessonType,
    String? topicId,
    String? grammarLessonId,
    int cardsReviewed = 0,
    int durationSeconds = 0,
    required int completedAtMs,
  }) =>
      upsert(_t, {
        'id': id,
        'lesson_type': lessonType,
        'topic_id': topicId,
        'grammar_lesson_id': grammarLessonId,
        'cards_reviewed': cardsReviewed,
        'duration_seconds': durationSeconds,
        'completed_at': completedAtMs,
        'sync_status': 'pending_create',
      }, const ['id']);

  Future<({String lessonType, String? topicId, String? grammarLessonId, int completedAt})?> byId(String id) async {
    final rows = await select('SELECT * FROM $_t WHERE id = ?', [id]).get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return (
      lessonType: r.s('lesson_type'),
      topicId: r.sN('topic_id'),
      grammarLessonId: r.sN('grammar_lesson_id'),
      completedAt: r.i('completed_at'),
    );
  }

  Future<void> delete(String id) => deleteWhere(_t, 'id = ?', [id]);

  Future<void> markSynced(String id, int nowMs) =>
      update("UPDATE $_t SET sync_status = 'synced', last_synced_at = ? WHERE id = ?", [nowMs, id], const [_t]);

  Future<int> countBetween(int fromMs, int toMs) async => (await select(
        'SELECT COUNT(*) AS c FROM $_t WHERE completed_at >= ? AND completed_at < ?',
        [fromMs, toMs],
      ).getSingle())
          .i('c');
}
