import '_json.dart';

/// Người dùng đang đăng nhập (dựng từ bảng `user_profile`) hoặc một dòng trong danh sách admin (từ API).
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String level;
  final String slogan;
  final int currentXp;

  /// XP dự kiến của các thao tác chưa đồng bộ (chỉ local, để hiển thị).
  final int pendingXp;
  final int targetXp;
  final int totalLifetimeXp;
  final int streakDays;
  final int longestStreak;
  final int totalWordsLearned;
  final int completedLessons;
  final int version;

  /// 'USER' | 'ADMIN'. Bảng `user_profile` không có cột role: lấy từ SecureStore / API.
  final String role;

  /// 'PENDING_VERIFY' | 'ACTIVE' | 'LOCKED' (chỉ có ở danh sách admin).
  final String status;

  /// ARGB của viền đang trang bị; rỗng = viền mặc định.
  final List<int> equippedBorderColors;
  final String? equippedAvatarUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.level = 'A1',
    this.slogan = '',
    this.currentXp = 0,
    this.pendingXp = 0,
    this.targetXp = 100,
    this.totalLifetimeXp = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.totalWordsLearned = 0,
    this.completedLessons = 0,
    this.version = 0,
    this.role = 'USER',
    this.status = 'ACTIVE',
    this.equippedBorderColors = const [],
    this.equippedAvatarUrl,
  });

  /// XP hiển thị = số server đã xác nhận + phần đang chờ đồng bộ.
  int get displayXp => currentXp + pendingXp;
  bool get isAdmin => role == 'ADMIN';

  /// `UserResponse` của API (danh sách admin).
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as String,
        fullName: jStr(j['fullName']),
        email: jStr(j['email']),
        avatarUrl: j['avatarUrl'] as String?,
        level: jStr(j['level'], 'A1'),
        slogan: jStr(j['slogan']),
        currentXp: jInt(j['currentXp']),
        targetXp: jInt(j['targetXp'], 100),
        totalLifetimeXp: jInt(j['totalLifetimeXp']),
        streakDays: jInt(j['streakDays']),
        longestStreak: jInt(j['longestStreak']),
        totalWordsLearned: jInt(j['totalWordsLearned']),
        completedLessons: jInt(j['completedLessons']),
        version: jInt(j['version']),
        role: jStr(j['role'], 'USER'),
        status: jStr(j['status'], 'ACTIVE'),
      );
}
