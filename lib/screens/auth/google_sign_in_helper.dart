import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../data/remote/dto/auth_dto.dart';
import '../../providers/auth_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Không đăng nhập Google được vì thiếu cấu hình hoặc nền tảng không hỗ trợ (không phải lỗi của người dùng).
class GoogleSignInUnavailable implements Exception {
  final String message;
  const GoogleSignInUnavailable(this.message);

  @override
  String toString() => 'Exception: $message';
}

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

/// `GoogleSignIn.initialize` chỉ được gọi một lần trong vòng đời app.
Future<void>? _googleInit;

/// Lấy idToken từ Google để server xác minh (`/v1/auth/google`).
Future<String> googleIdToken() async {
  if (Env.googleServerClientId.isEmpty) {
    throw GoogleSignInUnavailable(tr(
        'Chưa cấu hình Google Sign-In. Hãy chạy app với --dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id> (xem README).'));
  }
  try {
    final google = GoogleSignIn.instance;
    await (_googleInit ??= google.initialize(serverClientId: Env.googleServerClientId));
    if (!google.supportsAuthenticate()) {
      throw GoogleSignInUnavailable(tr('Thiết bị này chưa hỗ trợ đăng nhập bằng Google.'));
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw GoogleSignInUnavailable(tr('Không lấy được thông tin xác thực từ Google.'));
    }
    return idToken;
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) throw const GoogleSignInCancelled();
    throw GoogleSignInUnavailable(tr('Đăng nhập Google thất bại. Hãy kiểm tra cấu hình OAuth (SHA-1, client id).'));
  } on UnsupportedError {
    throw GoogleSignInUnavailable(tr('Thiết bị này chưa hỗ trợ đăng nhập bằng Google.'));
  }
}

/// Hoàn tất một lần đăng nhập thành công. [expectAdmin] khác null thì `role` server trả phải khớp tab đã chọn,
/// nếu không thì huỷ phiên vừa cấp và báo lỗi. Màn đích (MainScreen / AdminMainScreen) do StartGate chọn.
Future<void> completeSignIn(BuildContext context, WidgetRef ref, AuthDto auth, {bool? expectAdmin}) async {
  final isAdmin = auth.user.role == 'ADMIN';
  if (expectAdmin != null && isAdmin != expectAdmin) {
    try {
      await ref.read(authApiProvider).logout(auth.refreshToken);
    } catch (_) {
      // Bỏ qua lỗi mạng: token sẽ tự hết hạn ở server.
    }
    throw Exception(isAdmin
        ? tr('Đây là tài khoản quản trị, hãy chọn tab Quản trị viên')
        : tr('Tài khoản này không có quyền quản trị'));
  }
  await ref.read(authStateProvider.notifier).onAuthenticated(auth);
  if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
}

/// Đăng nhập bằng Google (dùng ở màn Chào mừng và Đăng nhập). [setBusy] bật/tắt vòng xoay của nút gọi.
Future<void> signInWithGoogle(BuildContext context, WidgetRef ref, void Function(bool busy) setBusy,
    {bool? expectAdmin}) async {
  setBusy(true);
  try {
    final idToken = await googleIdToken();
    final deviceId = await ref.read(secureStoreProvider).deviceId();
    final auth = await ref.read(authApiProvider).google(idToken: idToken, deviceId: deviceId);
    if (!context.mounted) return;
    await completeSignIn(context, ref, auth, expectAdmin: expectAdmin);
  } on GoogleSignInCancelled {
    // người dùng đóng hộp thoại chọn tài khoản
  } on GoogleSignInUnavailable catch (e) {
    if (context.mounted) showAppSnack(context, e.message, error: true);
  } catch (e) {
    if (context.mounted) showAppSnack(context, errorMessage(e), error: true);
  }
  if (context.mounted) setBusy(false);
}
