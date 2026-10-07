import '../../../models/_json.dart';
import '../../sync/srs.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `flashcard_review_logs` (sự kiện Again/Know) và `user_flashcard_progress` (trạng thái Leitner).
class SrsDao extends BaseDao {
  SrsDao(super.db);

  static const _logs = 'flashcard_review_logs';
  static const _progress = 'user_flashcard_progress';

  Future<List<SrsLog>> logsOf(String cardId) async {
    final rows = await select(
      'SELECT id, rating, reviewed_at FROM $_logs WHERE flashcard_id = ? ORDER BY reviewed_at',
      [cardId],
    ).get();
    return rows
        .map((r) => SrsLog(id: r.s('id'), rating: r.s('rating'), reviewedAt: fromEpoch(r.i('reviewed_at'))!))
        .toList();
  }

  Future<void> insertLog({
    required String id,
    required String cardId,
    required String rating,
    required int boxBefore,
    required int boxAfter,
    required int? responseTimeMs,
    required int reviewedAtMs,
  }) =>
      upsert(_logs, {
        'id': id,
        'flashcard_id': cardId,
        'rating': rating,
        'box_before': boxBefore,
        'box_after': boxAfter,
        'response_time_ms': responseTimeMs,
        'reviewed_at': reviewedAtMs,
        'sync_status': 'pending_create',
      }, const ['id']);

  Future<String?> cardOfLog(String logId) async {
    final rows = await select('SELECT flashcard_id FROM $_logs WHERE id = ?', [logId]).get();
    return rows.isEmpty ? null : rows.first.s('flashcard_id');
  }

  Future<void> deleteLog(String id) => deleteWhere(_logs, 'id = ?', [id]);

  Future<void> markLogSynced(String id, int nowMs) =>
      update("UPDATE $_logs SET sync_status = 'synced', last_synced_at = ? WHERE id = ?", [nowMs, id], const [_logs]);

  /// Ghi lại box_before/box_after sau khi phát lại (log đến muộn làm các log sau đổi box).
  Future<void> updateLogBoxes(Map<String, (int, int)> boxes) async {
    for (final e in boxes.entries) {
      await update('UPDATE $_logs SET box_before = ?, box_after = ? WHERE id = ?', [e.value.$1, e.value.$2, e.key],
          const [_logs]);
    }
  }

  Future<({int box, bool isLearned})?> progressOf(String cardId) async {
    final rows = await select('SELECT box, is_learned FROM $_progress WHERE flashcard_id = ?', [cardId]).get();
    return rows.isEmpty ? null : (box: rows.first.i('box'), isLearned: rows.first.b('is_learned'));
  }

  /// Thẻ này đã từng "thuộc" (box_after >= Srs.learnedBox) ở một log nào chưa: +5 XP chỉ cho lần đầu.
  Future<bool> everLearned(String cardId, {String? excludeLogId}) async {
    final r = await select(
      'SELECT COUNT(*) AS c FROM $_logs WHERE flashcard_id = ? AND box_after >= ? AND id <> ?',
      [cardId, Srs.learnedBox, excludeLogId ?? ''],
    ).getSingle();
    return r.i('c') > 0;
  }

  /// Đã có log KNOW nào của thẻ trong khoảng [fromMs, toMs) chưa (Know lần đầu trong ngày mới được +2).
  Future<bool> hasKnowBetween(String cardId, int fromMs, int toMs, {String? excludeLogId}) async {
    final r = await select(
      "SELECT COUNT(*) AS c FROM $_logs WHERE flashcard_id = ? AND rating = 'KNOW' "
      'AND reviewed_at >= ? AND reviewed_at < ? AND id <> ?',
      [cardId, fromMs, toMs, excludeLogId ?? ''],
    ).getSingle();
    return r.i('c') > 0;
  }

  /// Số thẻ khác nhau đã được Know trong khoảng thời gian (ước lượng XP Know đã nhận hôm nay).
  Future<int> knowCardsBetween(int fromMs, int toMs) async => (await select(
        "SELECT COUNT(DISTINCT flashcard_id) AS c FROM $_logs WHERE rating = 'KNOW' AND reviewed_at >= ? AND reviewed_at < ?",
        [fromMs, toMs],
      ).getSingle())
          .i('c');

  Future<void> writeProgress(String cardId, SrsState s, {required int nowMs}) => upsert(_progress, {
        'flashcard_id': cardId,
        'box': s.box,
        'repetitions': s.repetitions,
        'again_count': s.againCount,
        'know_count': s.knowCount,
        'last_rating': s.lastRating,
        'is_learned': s.isLearned,
        'last_reviewed_at': s.lastReviewedAt?.millisecondsSinceEpoch,
        'due_at': s.dueAt?.millisecondsSinceEpoch,
        'client_updated_at': nowMs,
        'is_dirty': 1,
        'sync_status': 'pending_update',
      }, const ['flashcard_id']);

  Future<void> deleteProgress(String cardId) => deleteWhere(_progress, 'flashcard_id = ?', [cardId]);

  /// `SrsProgressResponse` (kết quả review hoặc pull). [skipIfDirty]: pull không đè bản lạc quan.
  Future<void> applyServerProgress(Map<String, dynamic> p, {required int nowMs, bool skipIfDirty = false}) async {
    final cardId = p['flashcardId'] as String;
    if (skipIfDirty && await _isDirty(cardId)) return;
    if (!await _cardExists(cardId)) return;
    await upsert(_progress, {
      'flashcard_id': cardId,
      'box': jInt(p['box']),
      'repetitions': jInt(p['repetitions']),
      'again_count': jInt(p['againCount']),
      'know_count': jInt(p['knowCount']),
      'last_rating': p['lastRating'],
      'is_learned': jBool(p['isLearned']),
      'last_reviewed_at': toEpoch(p['lastReviewedAt'] as String?),
      'due_at': toEpoch(p['dueAt'] as String?),
      'version': jInt(p['version']),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['flashcard_id']);
  }

  Future<int> learnedInTopic(String topicId) async => (await select(
        'SELECT COUNT(*) AS c FROM $_progress p JOIN flashcards f ON f.id = p.flashcard_id '
        'WHERE f.topic_id = ? AND p.is_learned = 1',
        [topicId],
      ).getSingle())
          .i('c');

  Future<int> learnedTotal() async =>
      (await select('SELECT COUNT(*) AS c FROM $_progress WHERE is_learned = 1').getSingle()).i('c');

  Future<bool> _isDirty(String cardId) async {
    final rows = await select('SELECT is_dirty FROM $_progress WHERE flashcard_id = ?', [cardId]).get();
    return rows.isNotEmpty && rows.first.b('is_dirty');
  }

  Future<bool> _cardExists(String cardId) async =>
      (await select('SELECT COUNT(*) AS c FROM flashcards WHERE id = ?', [cardId]).getSingle()).i('c') > 0;
}
