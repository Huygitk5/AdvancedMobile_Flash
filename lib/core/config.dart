import 'package:shared_preferences/shared_preferences.dart';

import 'env.dart';

/// Địa chỉ backend lúc chạy. Ưu tiên theo thứ tự:
/// 1. Giá trị người dùng nhập (giữ lâu vào logo ở màn Chào mừng, hoặc Cài đặt) - lưu trong SharedPreferences
/// 2. `--dart-define=API_BASE_URL=...` / mặc định build-time ở [Env.apiBaseUrl]
///
/// Phải `await AppConfig.load()` trước khi dựng `ApiClient` (cả trong isolate đồng bộ nền).
class AppConfig {
  AppConfig._();

  static const String _prefKey = 'api_base_url';
  static String? _override;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _override = prefs.getString(_prefKey);
  }

  static String get defaultBaseUrl => Env.apiBaseUrl;

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
