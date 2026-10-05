/// Khớp `UserResponse` của backend. Giữ đúng tên field JSON (camelCase), enum giữ nguyên chuỗi server.
class UserDto {
  const UserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.level,
    required this.slogan,
    required this.currentXp,
    required this.targetXp,
    required this.totalLifetimeXp,
    required this.streakDays,
    required this.longestStreak,
    required this.totalWordsLearned,
    required this.completedLessons,
    required this.role,
    required this.status,
    required this.version,
    required this.clientUpdatedAt,
    this.emailVerified = false,
    this.hasPassword = true,
    this.raw = const {},
  });

  /// JSON gốc, để ghi thẳng vào `user_profile` (ProfileDao.upsertFromUser).
  final Map<String, dynamic> raw;

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String level; // 'A1'..'C2'
  final String slogan;
  final int currentXp;
  final int targetXp;
  final int totalLifetimeXp;
  final int streakDays;
  final int longestStreak;
  final int totalWordsLearned;
  final int completedLessons;
  final String role; // 'USER' | 'ADMIN'
  final String status; // 'PENDING_VERIFY' | 'ACTIVE' | 'LOCKED'
  final int version;
  final String? clientUpdatedAt; // ISO-8601
  final bool emailVerified;

  /// false với tài khoản chỉ đăng nhập Google (đổi mật khẩu không cần mật khẩu cũ).
  final bool hasPassword;

  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
        id: j['id'] as String, // không fallback '' cho id
        fullName: (j['fullName'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        avatarUrl: j['avatarUrl'] as String?,
        level: (j['level'] ?? 'A1') as String,
        slogan: (j['slogan'] ?? '') as String,
        currentXp: (j['currentXp'] ?? 0) as int,
        targetXp: (j['targetXp'] ?? 100) as int,
        totalLifetimeXp: (j['totalLifetimeXp'] ?? 0) as int,
        streakDays: (j['streakDays'] ?? 0) as int,
        longestStreak: (j['longestStreak'] ?? 0) as int,
        totalWordsLearned: (j['totalWordsLearned'] ?? 0) as int,
        completedLessons: (j['completedLessons'] ?? 0) as int,
        role: (j['role'] ?? 'USER') as String,
        status: (j['status'] ?? 'ACTIVE') as String,
        version: (j['version'] ?? 0) as int,
        clientUpdatedAt: j['clientUpdatedAt'] as String?,
        emailVerified: (j['emailVerified'] ?? false) as bool,
        hasPassword: (j['hasPassword'] ?? true) as bool,
        raw: j,
      );
}

/// Khớp `AuthResponse` của backend.
///
/// Đăng ký khi server bật xác thực email: `verificationRequired = true`, CHƯA có token; client mở màn nhập OTP
/// (`POST /v1/auth/verify-email`). Mọi luồng khác luôn có token.
class AuthDto {
  const AuthDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshTokenExpiresAt,
    this.verificationRequired = false,
  });

  final UserDto user;
  final String accessToken;
  final String refreshToken;

  /// Số giây access token còn hiệu lực.
  final int expiresIn;
  final String? refreshTokenExpiresAt;
  final bool verificationRequired;

  bool get hasSession => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  factory AuthDto.fromJson(Map<String, dynamic> j) => AuthDto(
        user: UserDto.fromJson(j['user'] as Map<String, dynamic>),
        accessToken: (j['accessToken'] ?? '') as String,
        refreshToken: (j['refreshToken'] ?? '') as String,
        expiresIn: (j['expiresIn'] as num?)?.toInt() ?? 0,
        refreshTokenExpiresAt: j['refreshTokenExpiresAt'] as String?,
        verificationRequired: (j['verificationRequired'] ?? false) as bool,
      );
}
