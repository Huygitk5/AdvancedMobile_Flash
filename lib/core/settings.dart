import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

/// Cài đặt lưu trên máy: chế độ tối và âm thanh. Ngôn ngữ nằm ở [AppLocale].
class AppSettings {
  AppSettings._();

  static const String _darkKey = 'is_dark_mode';
  static const String _soundKey = 'is_sound_enabled';

  static bool soundEnabled = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    soundEnabled = prefs.getBool(_soundKey) ?? true;
    themeNotifier.value = (prefs.getBool(_darkKey) ?? false) ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDarkMode(bool value) async {
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  static Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    if (!value) await SpeechService.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }
}

/// Đọc to từ vựng bằng engine text-to-speech của thiết bị (tiếng Anh).
class SpeechService {
  SpeechService._();

  static FlutterTts? _tts;
  static bool _ready = false;

  static Future<void> _ensureReady() async {
    if (_ready) return;
    final tts = _tts ??= FlutterTts();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.45);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    _ready = true;
  }

  /// @return false nếu thiết bị không đọc được (không có engine TTS) hoặc người dùng đã tắt âm thanh.
  static Future<bool> speak(String text) async {
    if (!AppSettings.soundEnabled || text.trim().isEmpty) return false;
    try {
      await _ensureReady();
      await _tts!.stop();
      final result = await _tts!.speak(text);
      return result == 1 || result == null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
