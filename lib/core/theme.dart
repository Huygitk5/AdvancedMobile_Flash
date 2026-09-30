import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3366FF);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color greyColor = Color(0xFF8F9BB3);
  static const Color correctColor = Color(0xFF00D68F); // Nút màu xanh (Know)
  static const Color wrongColor = Color(0xFFFF3D71);   // Nút màu đỏ (Again)

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto', // Hoặc font bạn tùy chọn
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
            color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}