class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String level; // vd: A2, B1

  // Xóa 'final' ở các biến có thể bị thay đổi trong quá trình sử dụng
  int currentXp;      // Sẽ bị trừ đi khi mua viền/avatar
  int streakDays;     // Tăng lên mỗi ngày học

  final int targetXp;
  final int totalWordsLearned;
  final int completedLessons;

  // --- 3 TRƯỜNG MỚI DÀNH CHO BẢNG XẾP HẠNG & HỒ SƠ ---
  int totalLifetimeXp; // Tổng XP trọn đời không bị trừ (Dành cho tab Point)
  int longestStreak;   // Chuỗi Streak dài nhất lịch sử (Dành cho tab Streak)
  String slogan;       // Câu châm ngôn ở Profile (Có thể sửa được)

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
    // Require thêm 3 trường mới
    required this.totalLifetimeXp,
    required this.longestStreak,
    required this.slogan,
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

      // Parse 3 trường mới
      totalLifetimeXp: json['totalLifetimeXp'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      slogan: json['slogan'] ?? 'Học, học nữa, học mãi!', // Slogan mặc định nếu null
    );
  }
}