import '_json.dart';

/// `AdminOverviewResponse` (`GET /v1/admin/overview`). [students] chỉ đếm role USER, quản trị viên đếm riêng ở [admins].
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

  factory AdminOverview.fromJson(Map<String, dynamic> j) => AdminOverview(
        students: jInt(j['students']),
        activeStudents: jInt(j['activeStudents']),
        newStudentsLast7Days: jInt(j['newStudentsLast7Days']),
        admins: jInt(j['admins']),
        topics: jInt(j['topics']),
        flashcards: jInt(j['flashcards']),
        grammarLessons: jInt(j['grammarLessons']),
        quizzes: jInt(j['quizzes']),
        rewardItems: jInt(j['rewardItems']),
        questDefinitions: jInt(j['questDefinitions']),
        recentStudents: (j['recentStudents'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(RecentStudent.fromJson)
            .toList(),
      );
}

class RecentStudent {
  final String id;
  final String fullName;
  final String email;
  final DateTime? createdAt;

  const RecentStudent({required this.id, required this.fullName, required this.email, this.createdAt});

  factory RecentStudent.fromJson(Map<String, dynamic> j) => RecentStudent(
        id: jStr(j['id']),
        fullName: jStr(j['fullName']),
        email: jStr(j['email']),
        createdAt: jDate(j['createdAt']),
      );
}
