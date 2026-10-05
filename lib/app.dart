import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'providers/auth_providers.dart';
import 'providers/providers.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/splash/welcome_screen.dart';
import 'widgets/sync_scope.dart';

class FlashApp extends StatefulWidget {
  const FlashApp({super.key});

  @override
  State<FlashApp> createState() => _FlashAppState();
}

class _FlashAppState extends State<FlashApp> {
  @override
  void initState() {
    super.initState();
    AppLocale.language.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppLocale.language.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// Chuỗi giao diện được tra bằng tr() nên không tự đăng ký phụ thuộc: sau khi đổi ngôn ngữ phải dựng lại toàn bộ cây widget.
  void _onLanguageChanged() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => rebuildAllWidgets());
  }

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
          locale: AppLocale.locale,
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Máy thật hay để cỡ chữ hệ thống lớn: giới hạn hệ số phóng chữ để giao diện không bị vỡ.
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final scale = media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15);
            return MediaQuery(data: media.copyWith(textScaler: scale), child: child ?? const SizedBox.shrink());
          },
          home: const StartGate(),
        );
      },
    );
  }
}

/// Logo trong lúc đọc phiên đăng nhập.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.flash_on, size: 60, color: Colors.amber),
            ),
            const SizedBox(height: 20),
            const Text('Flash',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
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
      AuthUnknown() => const _Splash(),
      SignedOut() => ref.read(appPrefsProvider).onboardingCompleted
          ? const LoginScreen()
          : const WelcomeScreen(),
      // Admin chỉ online, không đồng bộ SQLite. Người học: SyncScope kick sync khi mở / resumed / có mạng.
      SignedIn(:final isAdmin) => isAdmin ? const AdminMainScreen() : const SyncScope(child: MainScreen()),
    };
  }
}
