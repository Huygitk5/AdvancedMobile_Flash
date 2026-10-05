import 'package:flutter/material.dart';
import '../../core/navigation.dart';
import '../../data/auth_repository.dart';
import '../../widgets/common.dart';

/// Đăng nhập bằng Google (dùng ở màn Chào mừng và Đăng nhập). [setBusy] bật/tắt vòng xoay của nút gọi.
Future<void> signInWithGoogle(BuildContext context, void Function(bool busy) setBusy) async {
  setBusy(true);
  try {
    await AuthRepository.loginWithGoogle();
    goToHome();
    return;
  } on GoogleSignInCancelled {
    // người dùng đóng hộp thoại chọn tài khoản
  } on GoogleSignInUnavailable catch (e) {
    if (context.mounted) showAppSnack(context, e.message, error: true);
  } catch (e) {
    if (context.mounted) showAppSnack(context, errorMessage(e), error: true);
  }
  if (context.mounted) setBusy(false);
}
