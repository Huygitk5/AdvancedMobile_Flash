import '../api_client.dart';
import '../dto/auth_dto.dart';

/// Mỗi hàm một endpoint (DATA_ARCHITECTURE.md §6.2). Các endpoint `/v1/auth/**` đều public.
class AuthApi {
  AuthApi(this._c);

  final ApiClient _c;

  Future<AuthDto> login({required String email, required String password, required String deviceId}) async =>
      AuthDto.fromJson(await _c.post('/v1/auth/login',
          body: {'email': email, 'password': password, 'deviceId': deviceId}) as Map<String, dynamic>);

  Future<AuthDto> register({
    required String fullName,
    required String email,
    required String password,
    required String deviceId,
  }) async =>
      AuthDto.fromJson(await _c.post('/v1/auth/register', body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'deviceId': deviceId,
      }) as Map<String, dynamic>);

  Future<AuthDto> google({required String idToken, required String deviceId}) async =>
      AuthDto.fromJson(await _c.post('/v1/auth/google',
          body: {'idToken': idToken, 'deviceId': deviceId}) as Map<String, dynamic>);

  /// Luôn 200, kể cả email không tồn tại.
  Future<void> forgotPassword(String email) => _c.post('/v1/auth/forgot-password', body: {'email': email});

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) =>
      _c.post('/v1/auth/reset-password', body: {'email': email, 'otp': otp, 'newPassword': newPassword});

  Future<void> logout(String refreshToken) => _c.post('/v1/auth/logout', body: {'refreshToken': refreshToken});
}
