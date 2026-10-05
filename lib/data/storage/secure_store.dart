import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/ids.dart';

/// Bí mật dùng để xác thực: token, id user. Lưu bằng Keystore/Keychain (DATA_ARCHITECTURE.md §4.2).
/// Không bao giờ để token trong SharedPreferences hay SQLite.
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _s = storage ??
        const FlutterSecureStorage(
          aOptions: AndroidOptions(),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final FlutterSecureStorage _s;

  static const kAccessToken = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kAccessExpiresAt = 'access_token_expires_at'; // epoch ms (String)
  static const kUserId = 'user_id';
  static const kUserRole = 'user_role'; // 'USER' | 'ADMIN'
  static const kDeviceId = 'device_id';

  Future<String?> accessToken() => _s.read(key: kAccessToken);
  Future<String?> refreshToken() => _s.read(key: kRefreshToken);
  Future<String?> userId() => _s.read(key: kUserId);
  Future<String?> userRole() => _s.read(key: kUserRole);

  Future<DateTime?> accessTokenExpiresAt() async {
    final raw = await _s.read(key: kAccessExpiresAt);
    final ms = raw == null ? null : int.tryParse(raw);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  /// Sinh 1 lần rồi giữ nguyên, kể cả sau khi đăng xuất (id của thiết bị, không phải của user).
  Future<String> deviceId() async {
    final existing = await _s.read(key: kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = newId();
    await _s.write(key: kDeviceId, value: id);
    return id;
  }

  /// Ghi cặp token mới (đăng nhập, hoặc sau mỗi lần refresh vì refresh token bị rotate).
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiresAt,
  }) async {
    await _s.write(key: kAccessToken, value: accessToken);
    await _s.write(key: kRefreshToken, value: refreshToken);
    await _s.write(
      key: kAccessExpiresAt,
      value: accessExpiresAt.toUtc().millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiresAt,
    required String userId,
    required String role,
  }) async {
    await saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiresAt: accessExpiresAt,
    );
    await _s.write(key: kUserId, value: userId);
    await _s.write(key: kUserRole, value: role);
  }

  /// Đăng xuất: xoá mọi thứ trừ `device_id`.
  Future<void> clearSession() async {
    for (final k in [kAccessToken, kRefreshToken, kAccessExpiresAt, kUserId, kUserRole]) {
      await _s.delete(key: k);
    }
  }
}
