import 'json_helpers.dart';

class AdminOverview {
  final int students;
  final int activeStudents;
  final int newStudentsLast7Days;
  final int admins;
  final int topics;
  final int flashcards;
  final int grammarLessons;
  final int quizzes;
  final int rewardItems;
  final int questDefinitions;
  final List<RecentStudent> recentStudents;

  const AdminOverview({
    this.students = 0,
    this.activeStudents = 0,
    this.newStudentsLast7Days = 0,
    this.admins = 0,
    this.topics = 0,
    this.flashcards = 0,
    this.grammarLessons = 0,
    this.quizzes = 0,
    this.rewardItems = 0,
    this.questDefinitions = 0,
    this.recentStudents = const [],
  });

  factory AdminOverview.fromJson(Map<String, dynamic> json) => AdminOverview(
        students: jInt(json, 'students'),
        activeStudents: jInt(json, 'activeStudents'),
        newStudentsLast7Days: jInt(json, 'newStudentsLast7Days'),
        admins: jInt(json, 'admins'),
        topics: jInt(json, 'topics'),
        flashcards: jInt(json, 'flashcards'),
        grammarLessons: jInt(json, 'grammarLessons'),
        quizzes: jInt(json, 'quizzes'),
        rewardItems: jInt(json, 'rewardItems'),
        questDefinitions: jInt(json, 'questDefinitions'),
        recentStudents: jList(json, 'recentStudents').map(RecentStudent.fromJson).toList(),
      );
}

class RecentStudent {
  final String id;
  final String fullName;
  final String email;
  final DateTime? createdAt;

  const RecentStudent({required this.id, required this.fullName, required this.email, this.createdAt});

  factory RecentStudent.fromJson(Map<String, dynamic> json) => RecentStudent(
        id: jStr(json, 'id'),
        fullName: jStr(json, 'fullName'),
        email: jStr(json, 'email'),
        createdAt: jDate(json, 'createdAt'),
      );
}

/// Định nghĩa nhiệm vụ do admin quản lý.
class QuestDefinition {
  final String id;
  final String code;
  final String title;
  final String description;
  final String questType;
  final String frequency;
  final int targetValue;
  final int xpReward;
  final String iconName;
  final bool isActive;

  const QuestDefinition({
    required this.id,
    required this.code,
    required this.title,
    this.description = '',
    this.questType = 'LEARN_WORDS',
    this.frequency = 'DAILY',
    this.targetValue = 1,
    this.xpReward = 10,
    this.iconName = 'style',
    this.isActive = true,
  });

  factory QuestDefinition.fromJson(Map<String, dynamic> json) => QuestDefinition(
        id: jStr(json, 'id'),
        code: jStr(json, 'code'),
        title: jStr(json, 'title'),
        description: jStr(json, 'description'),
        questType: jStr(json, 'questType', 'LEARN_WORDS'),
        frequency: jStr(json, 'frequency', 'DAILY'),
        targetValue: jInt(json, 'targetValue', 1),
        xpReward: jInt(json, 'xpReward'),
        iconName: jStr(json, 'iconName', 'style'),
        isActive: jBool(json, 'isActive', true),
      );
}
