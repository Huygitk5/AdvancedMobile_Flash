import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/ids.dart';
import '../app_database.dart';

/// Một dòng của `sync_queue`.
class SyncOp {
  const SyncOp({
    required this.id,
    required this.opId,
    required this.opType,
    required this.entityTable,
    required this.entityId,
    required this.payload,
    required this.status,
    required this.attemptCount,
    required this.nextRetryAt,
    required this.lastError,
    required this.createdAt,
  });

  final int id;
  final String opId;
  final String opType;
  final String entityTable;
  final String entityId;
  final Map<String, dynamic> payload;
  final String status; // pending | in_flight | failed | dead
  final int attemptCount;
  final int nextRetryAt;
  final String? lastError;
  final int createdAt;

  factory SyncOp.fromRow(QueryRow r) => SyncOp(
        id: r.read<int>('id'),
        opId: r.read<String>('op_id'),
        opType: r.read<String>('op_type'),
        entityTable: r.read<String>('entity_table'),
        entityId: r.read<String>('entity_id'),
        payload: jsonDecode(r.read<String>('payload')) as Map<String, dynamic>,
        status: r.read<String>('status'),
        attemptCount: r.read<int>('attempt_count'),
        nextRetryAt: r.read<int>('next_retry_at'),
        lastError: r.readNullable<String>('last_error'),
        createdAt: r.read<int>('created_at'),
      );
}

/// Hàng đợi offline (`sync_queue`) và con trỏ pull (`sync_meta`).
/// Viết bằng SQL thuần để không phụ thuộc tên lớp Drift sinh ra.
class SyncDao {
  SyncDao(this._db);

  final AppDatabase _db;

  /// Các op dạng "trạng thái": op `pending` cùng loại + cùng entity thì thay payload, giữ `op_id` cũ.
  /// Không gộp FLASHCARD_REVIEW, QUIZ_SUBMIT, LESSON_COMPLETE (mỗi lượt đều có ý nghĩa).
  static const coalescible = {
    'NOTE_UPSERT',
    'BOOKMARK_SET',
    'PROFILE_UPDATE',
    'ITEM_EQUIP',
    'SETTINGS_UPDATE',
  };

  static const maxBackoffMs = 30 * 60 * 1000;

  /// Gọi BÊN TRONG `db.transaction` của thao tác ghi lạc quan để hai việc cùng commit hoặc cùng rollback.
  /// Trả về `op_id` của op (op cũ nếu bị gộp).
  Future<String> enqueue({
    required String opType,
    required String entityTable,
    required String entityId,
    required Map<String, dynamic> payload,
    String? opId,
  }) async {
    final json = jsonEncode(payload);

    if (coalescible.contains(opType)) {
      final existing = await _db.customSelect(
        'SELECT id, op_id FROM sync_queue '
        "WHERE status = 'pending' AND op_type = ? AND entity_table = ? AND entity_id = ? "
        'ORDER BY id DESC LIMIT 1',
        variables: [
          Variable.withString(opType),
          Variable.withString(entityTable),
          Variable.withString(entityId),
        ],
      ).get();
      if (existing.isNotEmpty) {
        await _db.customUpdate(
          'UPDATE sync_queue SET payload = ? WHERE id = ?',
          variables: [Variable.withString(json), Variable.withInt(existing.first.read<int>('id'))],
        );
        return existing.first.read<String>('op_id');
      }
    }

    final id = opId ?? newId();
    await _db.customInsert(
      'INSERT INTO sync_queue (op_id, op_type, entity_table, entity_id, payload, status, created_at) '
      "VALUES (?, ?, ?, ?, ?, 'pending', ?)",
      variables: [
        Variable.withString(id),
        Variable.withString(opType),
        Variable.withString(entityTable),
        Variable.withString(entityId),
        Variable.withString(json),
        Variable.withInt(Clock.nowMs()),
      ],
    );
    return id;
  }

  /// Tối đa [limit] op `pending` đã tới hạn retry, theo thứ tự FIFO (`id`).
  Future<List<SyncOp>> nextBatch({int limit = 50, int? nowMs}) async {
    final rows = await _db.customSelect(
      "SELECT * FROM sync_queue WHERE status = 'pending' AND next_retry_at <= ? ORDER BY id LIMIT ?",
      variables: [Variable.withInt(nowMs ?? Clock.nowMs()), Variable.withInt(limit)],
    ).get();
    return rows.map(SyncOp.fromRow).toList();
  }

  Future<void> markInFlight(List<int> ids) => _setStatus(ids, 'in_flight');

  /// Lúc khởi động: op `in_flight` còn sót (app bị kill giữa chừng) quay về `pending`.
  /// Gửi lại vẫn an toàn nhờ `op_id`.
  Future<int> resetInFlight() => _db.customUpdate(
        "UPDATE sync_queue SET status = 'pending' WHERE status = 'in_flight'",
      );

  /// Server đã xử lý xong (APPLIED / DUPLICATE) thì xoá op.
  Future<void> markDone(int id) => _db.customUpdate(
        'DELETE FROM sync_queue WHERE id = ?',
        variables: [Variable.withInt(id)],
      );

  /// REJECTED: không bao giờ gửi lại.
  Future<void> markDead(int id, String errorCode) => _db.customUpdate(
        "UPDATE sync_queue SET status = 'dead', last_error = ? WHERE id = ?",
        variables: [Variable.withString(errorCode), Variable.withInt(id)],
      );

  /// Lỗi mạng / 5xx / 429 / FAILED: về `pending`, tăng `attempt_count`,
  /// `next_retry_at = now + min(2^n × 5s, 30 phút)`.
  Future<void> scheduleRetry(SyncOp op, {int? nowMs, String? error}) {
    final delay = min(pow(2, op.attemptCount).toInt() * 5000, maxBackoffMs);
    return _db.customUpdate(
      "UPDATE sync_queue SET status = 'pending', attempt_count = attempt_count + 1, "
      'next_retry_at = ?, last_error = ? WHERE id = ?',
      variables: [
        Variable.withInt((nowMs ?? Clock.nowMs()) + delay),
        error == null ? const Variable<String>(null) : Variable.withString(error),
        Variable.withInt(op.id),
      ],
    );
  }

  Future<int> pendingCount() async {
    final r = await _db
        .customSelect("SELECT COUNT(*) AS c FROM sync_queue WHERE status IN ('pending','in_flight')")
        .getSingle();
    return r.read<int>('c');
  }

  /// Có op chưa gửi nào đang đụng tới entity này không (pull không được đè dữ liệu lạc quan của nó).
  Future<bool> hasPendingFor(String entityTable, String entityId, {int? exceptQueueId}) async {
    final r = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM sync_queue '
      "WHERE entity_table = ? AND entity_id = ? AND status IN ('pending','in_flight') AND id <> ?",
      variables: [Variable.withString(entityTable), Variable.withString(entityId), Variable.withInt(exceptQueueId ?? -1)],
    ).getSingle();
    return r.read<int>('c') > 0;
  }

  /// Còn op FLASHCARD_REVIEW nào khác (chưa xử lý xong) của thẻ này không: nếu có thì không ghi đè
  /// tiến độ bằng `data.progress` của op hiện tại (sẽ mất các log lạc quan đứng sau).
  Future<bool> hasOtherPendingReview(String flashcardId, int exceptQueueId) async {
    final r = await _db.customSelect(
      "SELECT COUNT(*) AS c FROM sync_queue WHERE op_type = 'FLASHCARD_REVIEW' "
      "AND status IN ('pending','in_flight') AND id <> ? AND json_extract(payload, '\$.flashcardId') = ?",
      variables: [Variable.withInt(exceptQueueId), Variable.withString(flashcardId)],
    ).getSingle();
    return r.read<int>('c') > 0;
  }

  /// Thời điểm sớm nhất một op `pending` tới hạn gửi lại (null = không còn op chờ).
  Future<int?> earliestRetryAt() async {
    final r = await _db
        .customSelect("SELECT MIN(next_retry_at) AS t FROM sync_queue WHERE status = 'pending'")
        .getSingle();
    return r.readNullable<int>('t');
  }

  Future<bool> hasPendingOfType(String opType) async {
    final r = await _db.customSelect(
      "SELECT COUNT(*) AS c FROM sync_queue WHERE op_type = ? AND status IN ('pending','in_flight')",
      variables: [Variable.withString(opType)],
    ).getSingle();
    return r.read<int>('c') > 0;
  }

  /// Hàng đợi đã rỗng (không còn pending / in_flight): mọi thay đổi lạc quan đã được server xác nhận
  /// hoặc từ chối, nên bỏ cờ dirty để lần pull sau ghi đè bằng số chuẩn của server.
  Future<void> clearAllDirty() => _db.transaction(() async {
        for (final t in const [
          'user_flashcard_progress',
          'user_flashcard_notes',
          'user_bookmarks',
          'user_topic_progress',
          'user_grammar_progress',
          'user_quests',
          'user_inventories',
          'daily_statistics',
          'user_profile',
        ]) {
          await _db.customUpdate(
            'UPDATE $t SET is_dirty = 0 WHERE is_dirty = 1',
            updates: {_db.allTables.firstWhere((x) => x.actualTableName == t)},
          );
        }
      });

  /// Op đã chết (REJECTED) để hiển thị / gửi log lỗi (G10).
  Future<List<SyncOp>> deadOps() async {
    final rows = await _db.customSelect("SELECT * FROM sync_queue WHERE status = 'dead' ORDER BY id").get();
    return rows.map(SyncOp.fromRow).toList();
  }

  /// Số op chưa gửi xong, để UI hiện "Đang chờ đồng bộ".
  Stream<int> watchPendingCount() => _db
      .customSelect(
        "SELECT COUNT(*) AS c FROM sync_queue WHERE status IN ('pending','in_flight')",
        readsFrom: {_db.syncQueue},
      )
      .watch()
      .map((rows) => rows.first.read<int>('c'));

  // ---- sync_meta: con trỏ delta-pull theo scope ('content', 'user_data', ...) ----

  Future<String?> getCursor(String scope) async {
    final rows = await _db.customSelect(
      'SELECT server_cursor FROM sync_meta WHERE scope = ?',
      variables: [Variable.withString(scope)],
    ).get();
    return rows.isEmpty ? null : rows.first.readNullable<String>('server_cursor');
  }

  /// Gọi trong cùng transaction với việc upsert dữ liệu pull về.
  Future<void> setCursor(String scope, String cursor, {int? pulledAt}) => _db.customStatement(
        'INSERT INTO sync_meta (scope, server_cursor, last_pulled_at) VALUES (?, ?, ?) '
        'ON CONFLICT(scope) DO UPDATE SET server_cursor = excluded.server_cursor, '
        'last_pulled_at = excluded.last_pulled_at',
        [scope, cursor, pulledAt ?? Clock.nowMs()],
      );

  Future<void> _setStatus(List<int> ids, String status) async {
    if (ids.isEmpty) return;
    final marks = List.filled(ids.length, '?').join(',');
    await _db.customUpdate(
      'UPDATE sync_queue SET status = ? WHERE id IN ($marks)',
      variables: [Variable.withString(status), ...ids.map(Variable.withInt)],
    );
  }
}
