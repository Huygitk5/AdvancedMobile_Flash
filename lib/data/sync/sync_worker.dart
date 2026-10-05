import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../local/app_database.dart';
import '../local/daos/sync_dao.dart';
import '../remote/api_exception.dart';
import '../remote/apis/sync_api.dart';
import '../storage/secure_store.dart';
import 'op_handlers.dart';
import 'pull_service.dart';

/// Đẩy `sync_queue` lên `/v1/sync/push` theo lô (FIFO), rồi pull. Một mutex để chỉ một flush chạy.
class SyncWorker {
  SyncWorker({
    required this.db,
    required this.api,
    required this.store,
    required this.handlers,
    required this.pull,
  });

  final AppDatabase db;
  final SyncApi api;
  final SecureStore store;
  final OpHandlers handlers;
  final PullService pull;

  static const batchSize = 50;

  /// Tối đa số lô mỗi lần flush (để không chạm 30 request/phút; còn op thì lần kick sau gửi tiếp).
  static const maxBatchesPerFlush = 5;
  static const debounce = Duration(seconds: 2);

  final _messages = StreamController<String>.broadcast();
  Timer? _timer;
  Future<void>? _flushing;
  Future<void>? _syncing;
  bool _recovered = false;

  /// Thông báo cho UI (snackbar): xung đột, op bị từ chối...
  Stream<String> get messages => _messages.stream;

  SyncDao get _q => db.syncDao;

  /// Mọi trigger (mở app, resumed, có mạng, sau khi ghi, định kỳ) đều đi qua đây: debounce rồi sync.
  void kick({Duration delay = debounce}) {
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(syncNow()));
  }

  /// flush() rồi pull. Lỗi mạng bị nuốt: offline-first, lần sau thử lại.
  Future<void> syncNow() => _syncing ??= _syncOnce().whenComplete(() => _syncing = null);

  Future<void> _syncOnce() async {
    if (await store.refreshToken() == null) return; // chưa đăng nhập
    try {
      await flush();
      await pull.pullAll();
    } on NetworkException {
      // offline
    } on ApiException catch (e) {
      debugPrint('sync: $e');
    }
    // Còn op đang backoff: hẹn lần gửi lại (không cần chờ trigger khác).
    final next = await _q.earliestRetryAt();
    if (next != null && (_timer == null || !_timer!.isActive)) {
      final wait = next - Clock.nowMs();
      kick(delay: Duration(milliseconds: wait < debounce.inMilliseconds ? debounce.inMilliseconds : wait));
    }
  }

  Future<void> flush() => _flushing ??= _flushOnce().whenComplete(() => _flushing = null);

  Future<void> _flushOnce() async {
    if (!_recovered) {
      // App bị kill khi đang gửi: op in_flight quay về pending (gửi lại an toàn nhờ op_id).
      await _q.resetInFlight();
      _recovered = true;
    }

    for (var i = 0; i < maxBatchesPerFlush; i++) {
      final batch = await _q.nextBatch(limit: batchSize);
      if (batch.isEmpty) break;
      final keepGoing = await _pushBatch(batch);
      if (!keepGoing) break;
    }

    if (await _q.pendingCount() == 0) {
      // Không còn thao tác chờ: số lạc quan đã được thay bằng số server.
      await db.profileDao.resetPendingXp();
      await _q.clearAllDirty();
    }
  }

  /// true nếu nên gửi lô tiếp theo.
  Future<bool> _pushBatch(List<SyncOp> batch) async {
    await _q.markInFlight(batch.map((o) => o.id).toList());
    Map<String, dynamic> res;
    try {
      res = await api.push(
        deviceId: await store.deviceId(),
        // Lấy NGAY trước khi gửi: server tính lệch đồng hồ từ giá trị này.
        clientSentAt: Clock.now(),
        operations: [
          for (final op in batch)
            {
              'opId': op.opId,
              'opType': op.opType,
              'createdAt': DateTime.fromMillisecondsSinceEpoch(op.createdAt, isUtc: true).toIso8601String(),
              'payload': op.payload,
            },
        ],
      );
    } catch (e) {
      // Mạng / 5xx / 429 / lỗi khác: giữ op, backoff.
      for (final op in batch) {
        await _q.scheduleRetry(op, error: e is ApiException ? e.code : 'NETWORK');
      }
      if (e is NetworkException || e is ApiException) return false;
      rethrow;
    }

    final results = (res['results'] as List? ?? const []).cast<Map<String, dynamic>>();
    final byOpId = {for (final r in results) r['opId'] as String: r};
    var anyRetry = false;
    for (final op in batch) {
      final r = byOpId[op.opId];
      if (r == null) {
        await _q.scheduleRetry(op, error: 'NO_RESULT');
        anyRetry = true;
        continue;
      }
      final (outcome, message) = await handlers.handle(op, r);
      if (outcome == OpOutcome.retry) anyRetry = true;
      if (message != null) _messages.add(message);
    }
    await db.profileDao.applySnapshot(res['user'] as Map<String, dynamic>?);
    return !anyRetry;
  }

  void dispose() {
    _timer?.cancel();
    _messages.close();
  }
}
