import '../../core/clock.dart';
import '../local/app_database.dart';
import '../remote/apis/sync_api.dart';

/// Delta-pull (§6.11): `GET /v1/sync/content` rồi `GET /v1/sync/pull`. Mỗi trang ghi trong 1 transaction
/// cùng con trỏ `sync_meta`, lặp khi `hasMore`.
class PullService {
  PullService({required this.db, required this.api, this.onSettings, this.onPulled});

  final AppDatabase db;
  final SyncApi api;

  /// `changes.settings` (chỉ có khi đổi) -> AppPrefs. Không ghi đè khi còn SETTINGS_UPDATE chưa gửi.
  final Future<void> Function(Map<String, dynamic> settings)? onSettings;

  /// Sau mỗi lần pull xong (để cập nhật "Đồng bộ lần cuối").
  final Future<void> Function(int atMs)? onPulled;

  static const contentScope = 'content';
  static const userScope = 'user_data';
  static const pageSize = 500;

  /// Giới hạn số trang mỗi lần để không vượt 30 request/phút của `/v1/sync/**`.
  static const maxPages = 10;

  Future<void> pullAll() async {
    await pullContent();
    await pullUserData();
    await onPulled?.call(Clock.nowMs());
  }

  Future<void> pullContent() => _loop(contentScope, (since) => api.content(since: since, limit: pageSize), (changes) async {
        await db.contentDao.upsertContent(changes);
        await db.contentDao.deleteContent(changes['deleted'] as Map<String, dynamic>?);
      });

  Future<void> pullUserData() async {
    Map<String, dynamic>? settings;
    await _loop(userScope, (since) => api.pull(since: since, limit: pageSize), (changes) async {
      await _applyUserChanges(changes);
      if (changes['settings'] is Map<String, dynamic>) settings = changes['settings'] as Map<String, dynamic>;
    });
    if (settings != null && !await db.syncDao.hasPendingOfType('SETTINGS_UPDATE')) {
      await onSettings?.call(settings!);
    }
  }

  Future<void> _loop(
    String scope,
    Future<Map<String, dynamic>> Function(String? since) fetch,
    Future<void> Function(Map<String, dynamic> changes) apply,
  ) async {
    for (var page = 0; page < maxPages; page++) {
      final since = await db.syncDao.getCursor(scope);
      final res = await fetch(since);
      final changes = (res['changes'] as Map<String, dynamic>?) ?? const {};
      await db.transaction(() async {
        await apply(changes);
        final cursor = res['cursor'] as String?;
        if (cursor != null) await db.syncDao.setCursor(scope, cursor);
      });
      if (res['hasMore'] != true) break;
    }
  }

  /// Bỏ qua dòng local `is_dirty = 1` (bản lạc quan chưa được server xác nhận).
  Future<void> _applyUserChanges(Map<String, dynamic> c) async {
    final nowMs = Clock.nowMs();
    List<Map<String, dynamic>> list(String k) => (c[k] as List? ?? const []).cast<Map<String, dynamic>>();

    // user trước: các dòng khác cần user_profile đã có.
    if (c['user'] is Map<String, dynamic>) {
      await db.profileDao.upsertFromUser(c['user'] as Map<String, dynamic>, nowMs);
    }
    for (final p in list('userFlashcardProgress')) {
      await db.srsDao.applyServerProgress(p, nowMs: nowMs, skipIfDirty: true);
    }
    for (final n in list('userFlashcardNotes')) {
      await db.noteDao.applyServer(n, nowMs: nowMs, skipIfDirty: true);
    }
    for (final b in list('userBookmarks')) {
      await db.bookmarkDao.applyServer(b, nowMs: nowMs, skipIfDirty: true);
    }
    for (final t in list('userTopicProgress')) {
      await db.progressDao.applyServerTopic(t, nowMs);
    }
    for (final g in list('userGrammarProgress')) {
      await db.progressDao.applyServerGrammar(g, nowMs);
    }
    for (final q in list('userQuests')) {
      await db.questDao.applyServer(q, nowMs);
    }
    for (final i in list('userInventories')) {
      await db.shopDao.applyInventory(i, nowMs: nowMs, skipIfDirty: true);
    }
    for (final d in list('dailyStatistics')) {
      await db.statsDao.applyServer(d, nowMs);
    }
  }
}
