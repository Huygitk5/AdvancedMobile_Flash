import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils.dart';

/// Token đăng nhập. Lưu bằng secure storage (Keychain / EncryptedSharedPreferences); nếu nền tảng
/// không hỗ trợ thì chỉ giữ trong bộ nhớ nên phiên mất khi tắt app, không làm app hỏng.
class SessionStore {
  SessionStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _deviceKey = 'device_id';

  static String? accessToken;
  static String? refreshToken;
  static String deviceId = '';

  static bool get hasSession => (refreshToken ?? '').isNotEmpty;

  static Future<void> load() async {
    try {
      accessToken = await _storage.read(key: _accessKey);
      refreshToken = await _storage.read(key: _refreshKey);
    } catch (_) {
      // giữ giá trị trong bộ nhớ
    }
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceKey);
    if (id == null || id.isEmpty) {
      id = uuidV4();
      await prefs.setString(_deviceKey, id);
    }
    deviceId = id;
  }

  static Future<void> save({required String access, required String refresh}) async {
    accessToken = access;
    refreshToken = refresh;
    try {
      await _storage.write(key: _accessKey, value: access);
      await _storage.write(key: _refreshKey, value: refresh);
    } catch (_) {}
  }

  static Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {}
  }
}
