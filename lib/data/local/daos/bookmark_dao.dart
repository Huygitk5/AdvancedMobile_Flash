import '../../../models/_json.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `user_bookmarks`: bỏ bookmark = tombstone `deleted_at` (UI lọc `deleted_at IS NULL`).
class BookmarkDao extends BaseDao {
  BookmarkDao(super.db);

  static const _t = 'user_bookmarks';

  Future<bool> isBookmarked(String cardId) async {
    final rows = await select('SELECT deleted_at FROM $_t WHERE flashcard_id = ?', [cardId]).get();
    return rows.isNotEmpty && rows.first.iN('deleted_at') == null;
  }

  Future<void> setLocal(String cardId, bool bookmarked, int nowMs) async {
    final rows = await select('SELECT created_at FROM $_t WHERE flashcard_id = ?', [cardId]).get();
    await upsert(_t, {
      'flashcard_id': cardId,
      'created_at': rows.isEmpty ? nowMs : rows.first.i('created_at'),
      'client_updated_at': nowMs,
      'deleted_at': bookmarked ? null : nowMs,
      'is_dirty': 1,
      'sync_status': rows.isEmpty ? 'pending_create' : 'pending_update',
    }, const ['flashcard_id']);
  }

  /// `BookmarkResult` (op) hoặc `BookmarkRow` (pull).
  Future<void> applyServer(Map<String, dynamic> b, {required int nowMs, bool skipIfDirty = false}) async {
    final cardId = b['flashcardId'] as String;
    final rows = await select('SELECT created_at, is_dirty FROM $_t WHERE flashcard_id = ?', [cardId]).get();
    if (skipIfDirty && rows.isNotEmpty && rows.first.b('is_dirty')) return;
    if ((await select('SELECT COUNT(*) AS c FROM flashcards WHERE id = ?', [cardId]).getSingle()).i('c') == 0) return;
    final deletedAt = toEpoch(b['deletedAt'] as String?);
    final isBookmarked = b.containsKey('isBookmarked') ? jBool(b['isBookmarked']) : deletedAt == null;
    await upsert(_t, {
      'flashcard_id': cardId,
      'created_at': toEpoch(b['createdAt'] as String?) ?? (rows.isEmpty ? nowMs : rows.first.i('created_at')),
      'version': jInt(b['version']),
      'client_updated_at': toEpoch(b['clientUpdatedAt'] as String?) ?? nowMs,
      'deleted_at': isBookmarked ? null : (deletedAt ?? nowMs),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['flashcard_id']);
  }
}
