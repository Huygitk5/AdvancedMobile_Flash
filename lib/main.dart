import 'package:flash/screens/splash/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/main/main_screen.dart';
import 'screens/splash/welcome_screen.dart';

void main() {
  runApp(const FlashApp());
}

class FlashApp extends StatelessWidget {
  const FlashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash English',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(), // Bỏ qua Welcome để test nhanh UI chính
    );
  }
}