import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../../models/_json.dart';
import '../local/app_database.dart';
import '../local/converters.dart';
import '../local/daos/sync_dao.dart';
import '../remote/api_exception.dart';
import 'srs.dart';
import 'xp_estimator.dart';

/// Kết quả xử lý một `results[i]` của `/v1/sync/push`.
enum OpOutcome {
  /// APPLIED / DUPLICATE / CONFLICT_SERVER_WINS: đã áp `data`, op bị xoá.
  done,

  /// REJECTED (hoặc DUPLICATE kèm errorCode): đã rollback, op -> `dead`.
  rejected,

  /// FAILED: server chưa ghi nhận, op giữ `pending` + backoff.
  retry,
}

/// Áp kết quả từng op vào SQLite theo bảng G7.3 (IMPLEMENTATION_PLAN.md).
/// Mỗi op chạy trong 1 transaction: cập nhật dữ liệu + xoá / đánh dấu op cùng commit.
class OpHandlers {
  OpHandlers(this.db, {this.onSettings});

  final AppDatabase db;

  /// `data.settings` của SETTINGS_UPDATE -> AppPrefs (+ theme). Do tầng trên cung cấp.
  final Future<void> Function(Map<String, dynamic> settings)? onSettings;

  SyncDao get _q => db.syncDao;

  /// Trả về outcome và câu thông báo cho UI (null = im lặng).
  Future<(OpOutcome, String?)> handle(SyncOp op, Map<String, dynamic> result) async {
    final status = result['status'] as String?;
    final errorCode = result['errorCode'] as String?;
    final data = result['data'];
    final nowMs = Clock.nowMs();

    switch (status) {
      case 'APPLIED' || 'DUPLICATE' when errorCode == null:
      case 'CONFLICT_SERVER_WINS':
        Map<String, dynamic>? settings;
        await db.transaction(() async {
          settings = await _applied(op, data is Map<String, dynamic> ? data : const {}, nowMs);
          await _q.markDone(op.id);
        });
        if (settings != null) await onSettings?.call(settings!);
        return (OpOutcome.done, status == 'CONFLICT_SERVER_WINS' ? tr('Đã cập nhật từ thiết bị khác') : null);

      case 'REJECTED' || 'DUPLICATE':
        final code = errorCode ?? 'REJECTED';
        String? message;
        await db.transaction(() async {
          message = await _rejected(op, code, result['message'] as String?, nowMs);
          await _q.markDead(op.id, code);
        });
        return (OpOutcome.rejected, message);

      default: // FAILED, hoặc trạng thái lạ
        await _q.scheduleRetry(op, error: errorCode ?? status);
        return (OpOutcome.retry, null);
    }
  }

  // ------------------------------------------------------------------ APPLIED

  Future<Map<String, dynamic>?> _applied(SyncOp op, Map<String, dynamic> data, int nowMs) async {
    final p = op.payload;
    switch (op.opType) {
      case 'FLASHCARD_REVIEW':
        await db.srsDao.markLogSynced(op.entityId, nowMs);
        final progress = data['progress'];
        final cardId = p['flashcardId'] as String;
        // Còn review khác của thẻ chưa gửi xong thì giữ bản lạc quan (đã gồm cả các log đó).
        if (progress is Map<String, dynamic> && !await _q.hasOtherPendingReview(cardId, op.id)) {
          await db.srsDao.applyServerProgress(progress, nowMs: nowMs);
        }
        await db.profileDao.applySnapshot(data['user'] as Map<String, dynamic>?);

      case 'LESSON_COMPLETE':
        await db.lessonDao.markSynced(op.entityId, nowMs);
        await db.profileDao.applySnapshot(data['user'] as Map<String, dynamic>?);

      case 'QUIZ_SUBMIT':
        if (data['id'] != null) await db.quizDao.applyServer(data, nowMs);

      case 'NOTE_UPSERT' || 'NOTE_DELETE':
        final note = data['note'];
        final cardId = p['flashcardId'] as String;
        if (await _q.hasPendingFor(op.entityTable, op.entityId, exceptQueueId: op.id)) break;
        if (note is Map<String, dynamic>) {
          await db.noteDao.applyServer(note, nowMs: nowMs);
        } else {
          await db.noteDao.markClean(cardId, nowMs); // xoá ghi chú server chưa từng có
        }

      case 'BOOKMARK_SET':
        if (data['flashcardId'] != null && !await _q.hasPendingFor(op.entityTable, op.entityId, exceptQueueId: op.id)) {
          await db.bookmarkDao.applyServer(data, nowMs: nowMs);
        }

      case 'QUEST_CLAIM':
        await db.questDao.markClean(op.entityId, nowMs);
        if (data['currentXp'] != null) {
          await db.profileDao.setXp(currentXp: jInt(data['currentXp']), totalLifetimeXp: jIntN(data['totalLifetimeXp']));
        }

      case 'PROFILE_UPDATE':
        final user = data['user'];
        if (await _q.hasPendingFor(op.entityTable, op.entityId, exceptQueueId: op.id)) break;
        await db.profileDao.markClean(nowMs);
        if (user is Map<String, dynamic>) await db.profileDao.upsertFromUser(user, nowMs);

      case 'ITEM_EQUIP':
        final inv = data['inventory'];
        if (inv is Map<String, dynamic>) await db.shopDao.applyInventory(inv, nowMs: nowMs);
        for (final u in (data['unequipped'] as List? ?? const [])) {
          await db.shopDao.applyInventory(u as Map<String, dynamic>, nowMs: nowMs);
        }

      case 'SHOP_PURCHASE':
        final inv = data['inventory'];
        if (inv is Map<String, dynamic>) await db.shopDao.applyInventory(inv, nowMs: nowMs);
        if (data['currentXp'] != null) await db.profileDao.setXp(currentXp: jInt(data['currentXp']));

      case 'SETTINGS_UPDATE':
        final s = data['settings'];
        if (s is Map<String, dynamic> && !await _q.hasPendingFor(op.entityTable, op.entityId, exceptQueueId: op.id)) {
          return s;
        }
    }
    return null;
  }

  // ------------------------------------------------------------------ REJECTED

  Future<String?> _rejected(SyncOp op, String code, String? serverMessage, int nowMs) async {
    final p = op.payload;
    switch (op.opType) {
      case 'FLASHCARD_REVIEW':
        // Xoá log bị từ chối rồi phát lại các log còn lại.
        final cardId = p['flashcardId'] as String;
        await db.srsDao.deleteLog(op.entityId);
        final logs = await db.srsDao.logsOf(cardId);
        if (logs.isEmpty) {
          await db.srsDao.deleteProgress(cardId);
        } else {
          final state = Srs.replay(logs);
          await db.srsDao.updateLogBoxes(state.boxes);
          await db.srsDao.writeProgress(cardId, state, nowMs: nowMs);
        }
        final card = await db.contentDao.card(cardId);
        if (card != null) await db.progressDao.refreshTopic(card.topicId, nowMs);
        await db.profileDao.setTotalWordsLearned(await db.srsDao.learnedTotal());
        return null;

      case 'LESSON_COMPLETE':
        final row = await db.lessonDao.byId(op.entityId);
        await db.lessonDao.delete(op.entityId);
        if (row != null) {
          await db.statsDao.bump(localDateKey(fromEpoch(row.completedAt)!), lessonsCompleted: -1);
          // completedLessons chỉ tăng ở lần hoàn thành đầu tiên của bài: còn lần khác thì giữ nguyên
          final stillDone = await db.lessonDao.existsFor(topicId: row.topicId, grammarLessonId: row.grammarLessonId);
          if (!stillDone) await db.profileDao.bumpCounters(completedLessons: -1);
          await db.profileDao.addPendingXp(-XpEstimator.lessonXp);
        }
        return null;

      case 'QUIZ_SUBMIT':
        // Không có cột "lỗi" ở quiz_attempts: xoá bài làm, màn kết quả sẽ báo bị từ chối.
        await db.quizDao.delete(op.entityId);
        return code == 'BUSINESS_RULE_VIOLATION'
            ? tr('Đề đã được cập nhật, hãy làm lại bài kiểm tra.')
            : trf('Bài kiểm tra không được ghi nhận: {e}', {'e': _message(code, serverMessage)});

      case 'NOTE_UPSERT' || 'NOTE_DELETE':
        // Lấy lại từ server ở lần pull sau.
        await db.noteDao.markClean(p['flashcardId'] as String, nowMs);
        return null;

      case 'BOOKMARK_SET':
        final bookmarked = p['bookmarked'] == true;
        await db.bookmarkDao.applyServer({'flashcardId': p['flashcardId'], 'isBookmarked': !bookmarked}, nowMs: nowMs);
        return null;

      case 'QUEST_CLAIM':
        if (code == 'ALREADY_CLAIMED') {
          await db.questDao.markClean(op.entityId, nowMs);
          return null;
        }
        final quest = await db.questDao.byId(op.entityId);
        await db.questDao.setClaimed(op.entityId, false, null);
        if (quest != null) await db.profileDao.addPendingXp(-quest.xpReward);
        final msg = _message(code, serverMessage);
        return code == 'QUEST_NOT_COMPLETED' && quest != null
            ? '$msg ${trf('Tiến độ {c}/{t}.', {'c': quest.current, 't': quest.target})}'
            : msg;

      case 'PROFILE_UPDATE':
        await db.profileDao.markClean(nowMs);
        return _message(code, serverMessage);

      case 'ITEM_EQUIP':
        await db.shopDao.equipLocal(op.entityId, p['equipped'] != true, nowMs);
        return _message(code, serverMessage);

      case 'SHOP_PURCHASE':
        return trf('Mua vật phẩm thất bại: {e}', {'e': _message(code, serverMessage)});

      default: // SETTINGS_UPDATE: bỏ qua
        return null;
    }
  }

  static String _message(String code, String? serverMessage) =>
      ApiException(status: 0, code: code, message: serverMessage ?? '').userMessage;
}
