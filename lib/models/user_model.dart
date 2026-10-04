class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String level;
  int currentXp;
  int streakDays;
  final int targetXp;
  final int totalWordsLearned;
  final int completedLessons;
  int totalLifetimeXp;
  int longestStreak;
  String slogan;
  final String role; // THÊM TRƯỜNG ROLE ('USER' hoặc 'ADMIN')

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.level,
    required this.currentXp,
    required this.targetXp,
    required this.streakDays,
    required this.totalWordsLearned,
    required this.completedLessons,
    required this.totalLifetimeXp,
    required this.longestStreak,
    required this.slogan,
    required this.role, // Bắt buộc truyền role
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      level: json['level'] ?? 'A1',
      currentXp: json['currentXp'] ?? 0,
      targetXp: json['targetXp'] ?? 100,
      streakDays: json['streakDays'] ?? 0,
      totalWordsLearned: json['totalWordsLearned'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      totalLifetimeXp: json['totalLifetimeXp'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      slogan: json['slogan'] ?? 'Học, học nữa, học mãi!',
      role: json['role'] ?? 'USER', // Mặc định là USER nếu API không trả về
    );
  }
}