import 'package:flutter_tts/flutter_tts.dart';

/// Đọc to từ vựng bằng engine text-to-speech của thiết bị (tiếng Anh).
class SpeechService {
  SpeechService._();

  /// Đồng bộ với `AppPrefs.isSoundEnabled` (gán trong `main()` và `SettingsRepository`).
  static bool soundEnabled = true;

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
    if (!soundEnabled || text.trim().isEmpty) return false;
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
