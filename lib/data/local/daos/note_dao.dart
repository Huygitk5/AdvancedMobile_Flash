import '../../../core/ids.dart';
import '../../../models/_json.dart';
import '../converters.dart';
import 'base_dao.dart';

typedef LocalNote = ({String id, int version, String content, int? deletedAt, bool isDirty});

/// `user_flashcard_notes`: mỗi thẻ tối đa 1 ghi chú (UNIQUE flashcard_id). Xoá = tombstone `deleted_at`.
class NoteDao extends BaseDao {
  NoteDao(super.db);

  static const _t = 'user_flashcard_notes';

  Future<LocalNote?> byFlashcard(String cardId) async {
    final rows = await select('SELECT * FROM $_t WHERE flashcard_id = ?', [cardId]).get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return (
      id: r.s('id'),
      version: r.i('version'),
      content: r.s('content'),
      deletedAt: r.iN('deleted_at'),
      isDirty: r.b('is_dirty'),
    );
  }

  /// Sửa / tạo ghi chú lạc quan. Trả `(noteId, baseVersion)` để đưa vào payload NOTE_UPSERT.
  Future<({String noteId, int baseVersion})> saveLocal(String cardId, String content, int nowMs) async {
    final cur = await byFlashcard(cardId);
    final id = cur?.id ?? newId();
    await upsert(_t, {
      'id': id,
      'flashcard_id': cardId,
      'content': content,
      'version': cur?.version ?? 0,
      'client_updated_at': nowMs,
      'deleted_at': null,
      'is_dirty': 1,
      'sync_status': cur == null ? 'pending_create' : 'pending_update',
    }, const ['flashcard_id']);
    return (noteId: id, baseVersion: cur?.version ?? 0);
  }

  /// Xoá lạc quan (tombstone). null nếu chưa từng có ghi chú.
  Future<({String noteId, int baseVersion})?> deleteLocal(String cardId, int nowMs) async {
    final cur = await byFlashcard(cardId);
    if (cur == null) return null;
    await update(
      "UPDATE $_t SET deleted_at = ?, client_updated_at = ?, is_dirty = 1, sync_status = 'pending_delete' "
      'WHERE flashcard_id = ?',
      [nowMs, nowMs, cardId],
      const [_t],
    );
    return (noteId: cur.id, baseVersion: cur.version);
  }

  /// `NoteResponse` của server (kết quả op hoặc pull). id ghi chú có thể khác id local nếu
  /// ghi chú được tạo ở máy khác: luôn khoá theo flashcard_id.
  Future<void> applyServer(Map<String, dynamic> n, {required int nowMs, bool skipIfDirty = false}) async {
    final cardId = n['flashcardId'] as String;
    if (skipIfDirty && (await byFlashcard(cardId))?.isDirty == true) return;
    if ((await select('SELECT COUNT(*) AS c FROM flashcards WHERE id = ?', [cardId]).getSingle()).i('c') == 0) return;
    await upsert(_t, {
      'id': jStr(n['noteId'], newId()),
      'flashcard_id': cardId,
      'content': jStr(n['content']),
      'version': jInt(n['version']),
      'client_updated_at': toEpoch(n['clientUpdatedAt'] as String?) ?? nowMs,
      'deleted_at': toEpoch(n['deletedAt'] as String?),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['flashcard_id']);
  }

  Future<void> markClean(String cardId, int nowMs) => update(
        "UPDATE $_t SET is_dirty = 0, sync_status = 'synced', last_synced_at = ? WHERE flashcard_id = ?",
        [nowMs, cardId],
        const [_t],
      );
}
