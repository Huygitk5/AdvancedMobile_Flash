import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../data/remote/api_client.dart';
import '../data/remote/apis/admin_api.dart';
import '../data/remote/apis/auth_api.dart';
import '../data/remote/apis/gamification_api.dart';
import '../data/remote/apis/sync_api.dart';
import '../data/remote/apis/user_api.dart';
import '../data/repositories/study_repositories.dart';
import '../data/repositories/user_repositories.dart';
import '../data/storage/app_prefs.dart';
import '../data/storage/secure_store.dart';
import '../data/sync/op_handlers.dart';
import '../data/sync/pull_service.dart';
import '../data/sync/sync_worker.dart';
import 'auth_providers.dart';

/// Hai provider này được override trong `main()` bằng giá trị đã khởi tạo.
final appPrefsProvider = Provider<AppPrefs>((ref) => throw UnimplementedError('override trong main()'));
final dbProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override trong main()'));

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    prefs: ref.watch(appPrefsProvider),
    store: ref.watch(secureStoreProvider),
    // ref.read trong closure (không phải lúc build) nên không tạo vòng phụ thuộc.
    onForceLogout: () => ref.read(authStateProvider.notifier).forceLogout(),
  );
});

// ---------------------------------------------------------------- API

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));
final userApiProvider = Provider<UserApi>((ref) => UserApi(ref.watch(apiClientProvider)));
final syncApiProvider = Provider<SyncApi>((ref) => SyncApi(ref.watch(apiClientProvider)));
final gamificationApiProvider = Provider<GamificationApi>((ref) => GamificationApi(ref.watch(apiClientProvider)));

/// Admin chỉ online: gọi thẳng API, không qua SQLite.
final adminApiProvider = Provider<AdminApi>((ref) => AdminApi(ref.watch(apiClientProvider)));

// ---------------------------------------------------------------- Sync (G7)

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository(
      ref.watch(dbProvider),
      _kick(ref),
      ref.watch(appPrefsProvider),
      ref.watch(userApiProvider),
      ref.watch(secureStoreProvider),
    ));

final pullServiceProvider = Provider<PullService>((ref) {
  final prefs = ref.watch(appPrefsProvider);
  return PullService(
    db: ref.watch(dbProvider),
    api: ref.watch(syncApiProvider),
    onSettings: (s) => ref.read(settingsRepositoryProvider).applyServer(s),
    onPulled: prefs.setLastSyncedTimestamp,
  );
});

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final db = ref.watch(dbProvider);
  final worker = SyncWorker(
    db: db,
    api: ref.watch(syncApiProvider),
    store: ref.watch(secureStoreProvider),
    handlers: OpHandlers(db, onSettings: (s) => ref.read(settingsRepositoryProvider).applyServer(s)),
    pull: ref.watch(pullServiceProvider),
  );
  ref.onDispose(worker.dispose);
  return worker;
});

/// Thông báo của sync cho UI (xung đột, op bị từ chối).
final syncMessagesProvider = StreamProvider<String>((ref) => ref.watch(syncWorkerProvider).messages);

/// Số thao tác chưa đồng bộ.
final pendingOpsProvider = StreamProvider<int>((ref) => ref.watch(dbProvider).syncDao.watchPendingCount());

void Function() _kick(Ref ref) => () => ref.read(syncWorkerProvider).kick();

// ---------------------------------------------------------------- Repositories (G8)

final srsRepositoryProvider = Provider((ref) => SrsRepository(ref.watch(dbProvider), _kick(ref)));
final noteRepositoryProvider = Provider((ref) => NoteRepository(ref.watch(dbProvider), _kick(ref)));
final bookmarkRepositoryProvider = Provider((ref) => BookmarkRepository(ref.watch(dbProvider), _kick(ref)));
final lessonRepositoryProvider = Provider((ref) => LessonRepository(ref.watch(dbProvider), _kick(ref)));
final quizRepositoryProvider = Provider((ref) => QuizRepository(ref.watch(dbProvider), _kick(ref)));
final questRepositoryProvider = Provider((ref) => QuestRepository(
      ref.watch(dbProvider),
      _kick(ref),
      ref.watch(gamificationApiProvider),
      ref.watch(pullServiceProvider),
    ));
final shopRepositoryProvider =
    Provider((ref) => ShopRepository(ref.watch(dbProvider), _kick(ref), ref.watch(gamificationApiProvider)));
final profileRepositoryProvider = Provider((ref) => ProfileRepository(ref.watch(dbProvider), _kick(ref)));
final leaderboardRepositoryProvider =
    Provider((ref) => LeaderboardRepository(ref.watch(dbProvider), ref.watch(gamificationApiProvider)));
