import '../api_client.dart';
import '../dto/auth_dto.dart';

/// Mỗi hàm một endpoint (DATA_ARCHITECTURE.md §6.2). Các endpoint `/v1/auth/**` đều public.
class AuthApi {
  AuthApi(this._c);

  final ApiClient _c;

  Future<AuthDto> login({required String email, required String password, required String deviceId}) async =>
      AuthDto.fromJson(await _c.post('/v1/auth/login',
          body: {'email': email, 'password': password, 'deviceId': deviceId}) as Map<String, dynamic>);

  /// Khi server bật xác thực email: trả `verificationRequired = true` (chưa có token) và gửi OTP tới email.
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

  /// Đúng OTP thì kích hoạt tài khoản và cấp token luôn.
  Future<AuthDto> verifyEmail({required String email, required String otp, required String deviceId}) async =>
      AuthDto.fromJson(await _c.post('/v1/auth/verify-email',
          body: {'email': email, 'otp': otp, 'deviceId': deviceId}) as Map<String, dynamic>);

  /// Luôn 200 dù email có tồn tại hay không.
  Future<void> resendVerification(String email) => _c.post('/v1/auth/resend-verification', body: {'email': email});

  Future<AuthDto> google({required String idToken, required String deviceId}) async =>
      AuthDto.fromJson(await _c.post('/v1/auth/google',
          body: {'idToken': idToken, 'deviceId': deviceId}) as Map<String, dynamic>);

  /// Luôn 200, kể cả email không tồn tại.
  Future<void> forgotPassword(String email) => _c.post('/v1/auth/forgot-password', body: {'email': email});

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) =>
      _c.post('/v1/auth/reset-password', body: {'email': email, 'otp': otp, 'newPassword': newPassword});

  Future<void> logout(String refreshToken) => _c.post('/v1/auth/logout', body: {'refreshToken': refreshToken});
}
