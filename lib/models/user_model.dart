import 'json_helpers.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String level;
  final String slogan;
  final int currentXp;
  final int targetXp;
  final int totalLifetimeXp;
  final int streakDays;
  final int longestStreak;
  final int totalWordsLearned;
  final int completedLessons;
  final String role; // 'USER' | 'ADMIN'
  final String status; // 'ACTIVE' | 'PENDING_VERIFY' | 'LOCKED'
  final bool emailVerified;
  final bool hasPassword;
  final int version;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.level = 'A1',
    this.slogan = '',
    this.currentXp = 0,
    this.targetXp = 100,
    this.totalLifetimeXp = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.totalWordsLearned = 0,
    this.completedLessons = 0,
    this.role = 'USER',
    this.status = 'ACTIVE',
    this.emailVerified = false,
    this.hasPassword = true,
    this.version = 0,
    this.createdAt,
  });

  bool get isAdmin => role == 'ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: jStr(json, 'id'),
      fullName: jStr(json, 'fullName'),
      email: jStr(json, 'email'),
      avatarUrl: jStrOrNull(json, 'avatarUrl'),
      level: jStr(json, 'level', 'A1'),
      slogan: jStr(json, 'slogan'),
      currentXp: jInt(json, 'currentXp'),
      targetXp: jInt(json, 'targetXp', 100),
      totalLifetimeXp: jInt(json, 'totalLifetimeXp'),
      streakDays: jInt(json, 'streakDays'),
      longestStreak: jInt(json, 'longestStreak'),
      totalWordsLearned: jInt(json, 'totalWordsLearned'),
      completedLessons: jInt(json, 'completedLessons'),
      role: jStr(json, 'role', 'USER'),
      status: jStr(json, 'status', 'ACTIVE'),
      emailVerified: jBool(json, 'emailVerified'),
      hasPassword: jBool(json, 'hasPassword', true),
      version: jInt(json, 'version'),
      createdAt: jDate(json, 'createdAt'),
    );
  }

  UserModel copyWith({
    String? fullName,
    String? slogan,
    String? avatarUrl,
    int? currentXp,
    int? totalLifetimeXp,
    int? streakDays,
    int? longestStreak,
    int? totalWordsLearned,
    int? completedLessons,
    int? version,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level,
      slogan: slogan ?? this.slogan,
      currentXp: currentXp ?? this.currentXp,
      targetXp: targetXp,
      totalLifetimeXp: totalLifetimeXp ?? this.totalLifetimeXp,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      completedLessons: completedLessons ?? this.completedLessons,
      role: role,
      status: status,
      emailVerified: emailVerified,
      hasPassword: hasPassword,
      version: version ?? this.version,
      createdAt: createdAt,
    );
  }

  /// Áp các con số server-authoritative (`UserSnapshot`) trả kèm sau mỗi thao tác ghi: XP, streak, từ đã học, bài hoàn thành.
  UserModel applySnapshot(Map<String, dynamic> s) {
    return copyWith(
      currentXp: jInt(s, 'currentXp', currentXp),
      totalLifetimeXp: jInt(s, 'totalLifetimeXp', totalLifetimeXp),
      streakDays: jInt(s, 'streakDays', streakDays),
      longestStreak: jInt(s, 'longestStreak', longestStreak),
      totalWordsLearned: jInt(s, 'totalWordsLearned', totalWordsLearned),
      completedLessons: jInt(s, 'completedLessons', completedLessons),
    );
  }
}
