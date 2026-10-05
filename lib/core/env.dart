/// Cấu hình build-time. Đổi bằng `--dart-define=API_BASE_URL=https://api.example.com`.
///
/// - Emulator Android: `http://10.0.2.2:8080` (mặc định, trỏ về localhost của máy chạy backend).
/// - Máy thật: IP LAN của máy chạy backend, VD `http://192.168.1.10:8080`.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.101.28:8080',
  );

  /// OAuth client id loại **Web** (Google Cloud) để Android nhận được `idToken` cho `/v1/auth/google`.
  /// Phải nằm trong `GOOGLE_CLIENT_IDS` của backend. Rỗng = nút Google báo chưa cấu hình.
  /// Client ID không phải bí mật nên đặt sẵn giá trị mặc định; vẫn ghi đè được bằng --dart-define.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '887843851502-bqhkmojl022pbhob1hgeerk8ejaj5tcj.apps.googleusercontent.com',
  );
}
