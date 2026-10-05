import '../api_client.dart';
import '../dto/auth_dto.dart';

/// §6.3: hồ sơ và cài đặt của chính mình.
class UserApi {
  UserApi(this._c);

  final ApiClient _c;

  /// `UserResponse`.
  Future<Map<String, dynamic>> me() async => await _c.get('/v1/users/me') as Map<String, dynamic>;

  /// Trả cặp token mới (mọi refresh token cũ bị thu hồi).
  Future<AuthDto> changePassword({String? currentPassword, required String newPassword, required String deviceId}) async =>
      AuthDto.fromJson(await _c.put('/v1/users/change-password', body: {
        'currentPassword': ?currentPassword,
        'newPassword': newPassword,
        'deviceId': deviceId,
      }) as Map<String, dynamic>);

  /// `UserSettingsResponse`.
  Future<Map<String, dynamic>> settings() async => await _c.get('/v1/users/me/settings') as Map<String, dynamic>;
}
