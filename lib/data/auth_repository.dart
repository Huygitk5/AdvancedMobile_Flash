import 'package:google_sign_in/google_sign_in.dart';
import '../core/config.dart';
import '../core/l10n.dart';
import '../models/json_helpers.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/api_exception.dart';
import 'api/session_store.dart';
import 'app_state.dart';

class AuthResult {
  final UserModel user;

  /// true: tài khoản mới tạo, phải nhập OTP gửi qua email rồi mới đăng nhập được.
  final bool verificationRequired;

  const AuthResult(this.user, {this.verificationRequired = false});
}

/// Không đăng nhập Google được vì thiếu cấu hình hoặc nền tảng không hỗ trợ (không phải lỗi của người dùng).
class GoogleSignInUnavailable implements Exception {
  final String message;
  const GoogleSignInUnavailable(this.message);
}

class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

class AuthRepository {
  AuthRepository._();

  static ApiClient get _api => ApiClient.I;

  static Future<AuthResult> login(String email, String password) async {
    final data = await _api.post('/v1/auth/login',
        body: {'email': email.trim(), 'password': password, 'deviceId': SessionStore.deviceId}, auth: false);
    return _startSession(asMap(data));
  }

  /// Đăng ký. Khi server bật xác thực email, kết quả có [AuthResult.verificationRequired] = true và chưa có phiên.
  static Future<AuthResult> register(String fullName, String email, String password) async {
    final data = asMap(await _api.post('/v1/auth/register',
        body: {'fullName': fullName.trim(), 'email': email.trim(), 'password': password, 'deviceId': SessionStore.deviceId},
        auth: false));
    if (jBool(data, 'verificationRequired')) {
      return AuthResult(UserModel.fromJson(asMap(data['user'])), verificationRequired: true);
    }
    return _startSession(data);
  }

  static Future<AuthResult> verifyEmail(String email, String otp) async {
    final data = await _api.post('/v1/auth/verify-email',
        body: {'email': email.trim(), 'otp': otp.trim(), 'deviceId': SessionStore.deviceId}, auth: false);
    return _startSession(asMap(data));
  }

  static Future<void> resendVerification(String email) =>
      _api.post('/v1/auth/resend-verification', body: {'email': email.trim()}, auth: false);

  static Future<void> forgotPassword(String email) =>
      _api.post('/v1/auth/forgot-password', body: {'email': email.trim()}, auth: false);

  static Future<void> resetPassword(String email, String otp, String newPassword) => _api.post('/v1/auth/reset-password',
      body: {'email': email.trim(), 'otp': otp.trim(), 'newPassword': newPassword}, auth: false);

  /// Đăng nhập Google: lấy idToken từ Google rồi để server xác minh và tạo / liên kết tài khoản.
  static Future<AuthResult> loginWithGoogle() async {
    final idToken = await _googleIdToken();
    final data = await _api.post('/v1/auth/google',
        body: {'idToken': idToken, 'deviceId': SessionStore.deviceId}, auth: false);
    return _startSession(asMap(data));
  }

  static bool _googleReady = false;

  static Future<String> _googleIdToken() async {
    if (AppConfig.googleServerClientId.isEmpty) {
      throw GoogleSignInUnavailable(tr(
          'Chưa cấu hình Google Sign-In. Hãy chạy app với --dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id> (xem README).'));
    }
    try {
      if (!_googleReady) {
        await GoogleSignIn.instance.initialize(serverClientId: AppConfig.googleServerClientId);
        _googleReady = true;
      }
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw GoogleSignInUnavailable(tr('Thiết bị này chưa hỗ trợ đăng nhập bằng Google.'));
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw GoogleSignInUnavailable(tr('Không lấy được thông tin xác thực từ Google.'));
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const GoogleSignInCancelled();
      throw GoogleSignInUnavailable(tr('Đăng nhập Google thất bại. Hãy kiểm tra cấu hình OAuth (SHA-1, client id).'));
    } on UnsupportedError {
      throw GoogleSignInUnavailable(tr('Thiết bị này chưa hỗ trợ đăng nhập bằng Google.'));
    }
  }

  static Future<AuthResult> _startSession(Map<String, dynamic> data) async {
    final user = UserModel.fromJson(asMap(data['user']));
    final access = jStr(data, 'accessToken');
    final refresh = jStr(data, 'refreshToken');
    if (access.isEmpty || refresh.isEmpty) {
      throw const ApiException(500, 'BAD_RESPONSE', '');
    }
    await SessionStore.save(access: access, refresh: refresh);
    AppState.I.setUser(user);
    if (!user.isAdmin) {
      try {
        await AppState.I.refreshInventory();
      } on NetworkException {
        // sẽ tải lại sau
      }
    }
    return AuthResult(user);
  }
}
