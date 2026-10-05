import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../data/remote/dto/auth_dto.dart';
import '../data/sync/background_sync.dart';
import 'providers.dart';

sealed class AuthState {
  const AuthState();
}

/// Đang đọc SecureStore lúc mở app.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class SignedOut extends AuthState {
  const SignedOut();
}

class SignedIn extends AuthState {
  const SignedIn(this.userId, this.role);

  final String userId;

  /// 'USER' | 'ADMIN'
  final String role;

  bool get isAdmin => role == 'ADMIN';
}

/// Mọi nút "Đăng xuất" và `forceLogout()` đều đi qua đây để dữ liệu được xoá đúng một chỗ.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthUnknown();

  /// Gọi một lần khi mở app (StartGate). Không cần mạng: chỉ đọc SecureStore.
  Future<void> restore() async {
    final store = ref.read(secureStoreProvider);
    final refresh = await store.refreshToken();
    final userId = await store.userId();
    if (refresh == null || userId == null) {
      state = const SignedOut();
      return;
    }
    state = SignedIn(userId, await store.userRole() ?? 'USER');
  }

  /// Sau login / register / Google thành công.
  Future<void> onAuthenticated(AuthDto auth) async {
    final store = ref.read(secureStoreProvider);
    final prefs = ref.read(appPrefsProvider);
    final db = ref.read(dbProvider);

    // SQLite đang chứa dữ liệu của tài khoản khác thì xoá trước khi dùng.
    final owner = prefs.localDbOwnerUserId;
    if (owner != null && owner != auth.user.id) {
      await db.clearUserData();
    }

    await store.saveSession(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      accessExpiresAt: Clock.now().toUtc().add(Duration(seconds: auth.expiresIn)),
      userId: auth.user.id,
      role: auth.user.role,
    );
    await prefs.setLocalDbOwnerUserId(auth.user.id);
    await prefs.setLastLoginEmail(auth.user.email);
    await db.profileDao.upsertFromUser(auth.user.raw, Clock.nowMs());

    state = SignedIn(auth.user.id, auth.user.role);
    if (auth.user.role != 'ADMIN') {
      // Pull lần đầu (nội dung + dữ liệu user) chạy nền; app đọc SQLite nên vẫn vào ngay.
      ref.read(syncWorkerProvider).kick(delay: Duration.zero);
      await BackgroundSync.register();
    }
  }

  /// Người dùng chủ động đăng xuất.
  Future<void> logout() async {
    final refresh = await ref.read(secureStoreProvider).refreshToken();
    if (refresh != null) {
      try {
        await ref.read(authApiProvider).logout(refresh);
      } catch (_) {
        // Bỏ qua lỗi mạng: token sẽ tự hết hạn ở server.
      }
    }
    await _wipe();
  }

  /// Server từ chối refresh token: xoá phiên local, không gọi lại server.
  Future<void> forceLogout() => _wipe();

  Future<void> _wipe() async {
    await BackgroundSync.cancel();
    await ref.read(secureStoreProvider).clearSession();
    await ref.read(dbProvider).clearUserData();
    await ref.read(appPrefsProvider).resetUserScoped();
    state = const SignedOut();
  }
}

final authStateProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
