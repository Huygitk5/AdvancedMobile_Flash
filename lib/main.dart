import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config.dart';
import 'core/l10n.dart';
import 'core/navigation.dart';
import 'core/settings.dart';
import 'core/theme.dart';
import 'data/api/api_client.dart';
import 'data/api/session_store.dart';
import 'data/app_state.dart';
import 'screens/splash/start_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await AppLocale.load();
  await AppSettings.load();
  await SessionStore.load();

  // Refresh token cũng hết hạn: xoá phiên và đưa người dùng về màn Chào mừng.
  ApiClient.I.onSessionExpired = () async {
    if (!AppState.I.isSignedIn) return;
    await AppState.I.signOut(callServer: false);
    goToWelcome();
  };

  runApp(const FlashApp());
}

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'Flash English',
          navigatorKey: navigatorKey,
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