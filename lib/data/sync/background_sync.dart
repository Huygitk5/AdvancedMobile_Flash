import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../local/app_database.dart';
import '../remote/api_client.dart';
import '../remote/apis/sync_api.dart';
import '../storage/app_prefs.dart';
import '../storage/secure_store.dart';
import '../widget/home_widget_service.dart';
import 'op_handlers.dart';
import 'pull_service.dart';
import 'sync_worker.dart';

/// Đồng bộ định kỳ 15 phút bằng workmanager (Android, chỉ khi có mạng).
/// iOS cần cấu hình BGTaskScheduler riêng nên chưa bật.
class BackgroundSync {
  const BackgroundSync._();

  static const _uniqueName = 'flash-periodic-sync';
  static const _taskName = 'flash.sync';

  static bool get _supported => !kIsWeb && Platform.isAndroid;

  /// Gọi một lần trong `main()`.
  static Future<void> initialize() async {
    if (!_supported) return;
    await Workmanager().initialize(backgroundSyncDispatcher);
  }

  static Future<void> register() async {
    if (!_supported) return;
    try {
      await Workmanager().registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (e) {
      debugPrint('BackgroundSync.register: $e');
    }
  }

  static Future<void> cancel() async {
    if (!_supported) return;
    try {
      await Workmanager().cancelByUniqueName(_uniqueName);
    } catch (e) {
      debugPrint('BackgroundSync.cancel: $e');
    }
  }
}

/// Chạy trong isolate nền: tự dựng DB / API riêng, flush + pull một lần rồi đóng.
@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, input) async {
    final db = AppDatabase();
    try {
      final prefs = await AppPrefs.load();
      AppLocale.apply(prefs.appLanguage); // nhãn chữ gửi sang widget theo ngôn ngữ app
      await AppConfig.load();
      final store = SecureStore();
      if (await store.refreshToken() == null || await store.userRole() == 'ADMIN') return true;
      // Refresh token bị từ chối ở nền: không xoá dữ liệu ở đây, lần mở app tiếp theo sẽ xử lý.
      final client = ApiClient(prefs: prefs, store: store, onForceLogout: () async {});
      final api = SyncApi(client);
      final worker = SyncWorker(
        db: db,
        api: api,
        store: store,
        handlers: OpHandlers(db),
        pull: PullService(db: db, api: api, onPulled: prefs.setLastSyncedTimestamp),
      );
      await worker.syncNow();
      await HomeWidgetService.refresh(db);
      worker.dispose();
      return true;
    } catch (e) {
      debugPrint('backgroundSync: $e');
      return false;
    } finally {
      await db.close();
    }
  });
}
