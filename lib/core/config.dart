import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình chạy app. Địa chỉ backend ưu tiên theo thứ tự:
/// 1. Giá trị người dùng nhập ở màn Chào mừng (giữ lâu vào logo) - lưu trong SharedPreferences
/// 2. `--dart-define=API_BASE_URL=http://192.168.1.5:8080`
/// 3. Mặc định theo nền tảng: Android emulator 10.0.2.2, còn lại localhost.
class AppConfig {
  AppConfig._();

  static const String _envApiBase = String.fromEnvironment('API_BASE_URL');

  /// OAuth client id loại "Web" trong Google Cloud Console (cũng là GOOGLE_CLIENT_IDS của backend).
  /// Truyền bằng `--dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com`.
  /// Client ID không phải bí mật nên đặt sẵn giá trị mặc định; vẫn ghi đè được bằng --dart-define.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '887843851502-bqhkmojl022pbhob1hgeerk8ejaj5tcj.apps.googleusercontent.com',
  );

  static const String _prefKey = 'api_base_url';
  static String? _override;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _override = prefs.getString(_prefKey);
  }

  static String get defaultBaseUrl {
    if (_envApiBase.isNotEmpty) return _envApiBase;
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static String get apiBaseUrl => (_override != null && _override!.isNotEmpty) ? _override! : defaultBaseUrl;

  /// Lưu địa chỉ backend do người dùng nhập; chuỗi rỗng = quay lại mặc định.
  static Future<void> setApiBaseUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    var value = (url ?? '').trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.isNotEmpty && !value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://$value';
    }
    if (value.isEmpty) {
      _override = null;
      await prefs.remove(_prefKey);
    } else {
      _override = value;
      await prefs.setString(_prefKey, value);
    }
  }
}
