import '../core/l10n.dart';
import '../core/settings.dart';
import '../models/json_helpers.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/api_exception.dart';
import 'api/session_store.dart';
import 'app_state.dart';

class UserRepository {
  UserRepository._();

  static ApiClient get _api => ApiClient.I;

  /// Đổi slogan. 409 VERSION_CONFLICT (hồ sơ đã đổi ở nơi khác) thì lấy bản mới nhất rồi gửi lại một lần.
  static Future<UserModel> updateSlogan(String slogan) async {
    Future<UserModel> send(int version) async {
      final data = await _api.put('/v1/users/update', body: {
        'slogan': slogan.trim(),
        'baseVersion': version,
        'clientUpdatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      return UserModel.fromJson(asMap(data));
    }

    UserModel updated;
    try {
      updated = await send(AppState.I.me.version);
    } on ApiException catch (e) {
      if (e.code != 'VERSION_CONFLICT') rethrow;
      final latest = e.data is Map ? UserModel.fromJson(asMap(e.data)) : null;
      updated = await send(latest?.version ?? AppState.I.me.version);
    }
    AppState.I.setUser(updated);
    return updated;
  }

  /// Gửi OTP xác nhận đổi mật khẩu tới email của tài khoản.
  static Future<void> requestChangePasswordOtp() => _api.post('/v1/users/change-password/otp');

  /// Đổi mật khẩu. Server thu hồi mọi phiên cũ và trả cặp token mới cho thiết bị này.
  static Future<void> changePassword({String? currentPassword, required String newPassword, required String otp}) async {
    final data = asMap(await _api.put('/v1/users/change-password', body: {
      if (currentPassword != null && currentPassword.isNotEmpty) 'currentPassword': currentPassword,
      'newPassword': newPassword,
      'otp': otp.trim(),
      'deviceId': SessionStore.deviceId,
    }));
    final access = jStr(data, 'accessToken');
    final refresh = jStr(data, 'refreshToken');
    if (access.isNotEmpty && refresh.isNotEmpty) await SessionStore.save(access: access, refresh: refresh);
  }

  /// Đồng bộ cài đặt (ngôn ngữ, chế độ tối, âm thanh) lên server; thất bại thì bỏ qua vì bản gốc nằm trên máy.
  static Future<void> pushSettings({required bool darkMode}) async {
    try {
      await _api.put('/v1/users/me/settings', body: {
        'appLanguage': AppLocale.language.value,
        'isDarkMode': darkMode,
        'isSoundEnabled': AppSettings.soundEnabled,
        'clientUpdatedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }
}
