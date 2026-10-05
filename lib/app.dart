import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'providers/auth_providers.dart';
import 'providers/providers.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/splash/welcome_screen.dart';
import 'widgets/sync_scope.dart';

class FlashApp extends StatelessWidget {
  const FlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi của themeNotifier
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'Flash English',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: const StartGate(),
        );
      },
    );
  }
}

/// Chọn màn đầu tiên theo phiên đăng nhập lưu trong SecureStore. Không cần mạng.
class StartGate extends ConsumerStatefulWidget {
  const StartGate({super.key});

  @override
  ConsumerState<StartGate> createState() => _StartGateState();
}

class _StartGateState extends ConsumerState<StartGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authStateProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    // Đăng xuất (hoặc bị buộc đăng xuất) khi đang đứng ở màn con: đóng hết route đã push,
    // nếu không Settings/Shop... vẫn nằm trên StartGate.
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (prev is SignedIn && next is SignedOut) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final auth = ref.watch(authStateProvider);
    return switch (auth) {
      AuthUnknown() => const Scaffold(body: Center(child: CircularProgressIndicator())),
      SignedOut() => ref.read(appPrefsProvider).onboardingCompleted
          ? const LoginScreen()
          : const WelcomeScreen(),
      // Admin chỉ online, không đồng bộ SQLite. Người học: SyncScope kick sync khi mở / resumed / có mạng.
      SignedIn(:final isAdmin) => isAdmin ? const AdminMainScreen() : const SyncScope(child: MainScreen()),
    };
  }
}
