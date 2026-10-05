import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/splash/welcome_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Vào màn hình chính theo quyền của tài khoản (ADMIN -> quản trị, USER -> học viên) và xoá lịch sử điều hướng.
void goToHome() {
  final user = AppState.I.user;
  if (user == null) {
    goToWelcome();
    return;
  }
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => user.isAdmin ? const AdminMainScreen() : const MainScreen()),
    (route) => false,
  );
}

void goToWelcome() {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (route) => false,
  );
}

/// Đăng xuất rồi về màn Chào mừng.
Future<void> signOutAndGoToWelcome({bool callServer = true}) async {
  await AppState.I.signOut(callServer: callServer);
  goToWelcome();
}
