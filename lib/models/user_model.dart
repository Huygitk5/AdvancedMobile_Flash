class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String level; // vd: A2, B1
  final int currentXp;
  final int targetXp;
  final int streakDays;
  final int totalWordsLearned;
  final int completedLessons;

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
    );
  }
}