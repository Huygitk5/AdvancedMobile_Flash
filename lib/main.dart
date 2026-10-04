import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/splash/welcome_screen.dart';

void main() {
  runApp(const FlashApp());
}

class FlashApp extends StatelessWidget {
  const FlashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi của themeNotifier
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Flash English',
          theme: AppTheme.lightTheme,      // Cấu hình Sáng
          darkTheme: AppTheme.darkTheme,   // Cấu hình Tối
          themeMode: currentMode,          // Chế độ hiện tại
          debugShowCheckedModeBanner: false,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}