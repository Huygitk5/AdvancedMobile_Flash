import 'package:flash/data/local/app_database.dart';
import 'package:flash/data/remote/api_exception.dart';
import 'package:flash/data/remote/apis/sync_api.dart';

/// SyncApi giả: mỗi lần push gọi [onPush] (ném lỗi để giả lập mất mạng / 429).
class FakeSyncApi implements SyncApi {
  Map<String, dynamic> Function(List<Map<String, dynamic>> ops)? onPush;
  final List<List<Map<String, dynamic>>> pushed = [];

  /// Các trang trả về lần lượt cho pull / content.
  final List<Map<String, dynamic>> pullPages = [];
  final List<Map<String, dynamic>> contentPages = [];
  final List<String?> pullSince = [];
  final List<String?> contentSince = [];

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required DateTime clientSentAt,
    required List<Map<String, dynamic>> operations,
  }) async {
    pushed.add(operations);
    return onPush!(operations);
  }

  @override
  Future<Map<String, dynamic>> pull({String? since, int limit = 500}) async {
    pullSince.add(since);
    return pullPages.isEmpty ? {'cursor': since, 'hasMore': false, 'changes': {}} : pullPages.removeAt(0);
  }

  @override
  Future<Map<String, dynamic>> content({String? since, int limit = 500}) async {
    contentSince.add(since);
    return contentPages.isEmpty ? {'cursor': since, 'hasMore': false, 'changes': {}} : contentPages.removeAt(0);
  }
}

const offline = NetworkException();

Map<String, dynamic> result(String opId, String status, {Object? data, String? errorCode}) =>
    {'opId': opId, 'status': status, 'data': ?data, 'errorCode': ?errorCode};

const userSnapshot = {
  'currentXp': 120,
  'totalLifetimeXp': 500,
  'streakDays': 3,
  'longestStreak': 9,
  'totalWordsLearned': 4,
  'completedLessons': 2,
};

/// Nội dung tối thiểu: 1 topic, 2 thẻ, 1 quiz 2 câu, 1 quest definition, 1 vật phẩm.
Map<String, dynamic> seedContent() => {
      'topics': [
        {'id': 't1', 'title': 'Daily Life', 'iconPath': '☀️', 'level': 'A1', 'totalWords': 2, 'sortOrder': 1, 'updatedAt': '2026-10-01T00:00:00Z'},
      ],
      'flashcards': [
        {'id': 'f1', 'topicId': 't1', 'word': 'apple', 'partOfSpeech': 'n.', 'pronunciation': '/ˈæp.əl/', 'meaning': 'quả táo', 'sortOrder': 1, 'updatedAt': '2026-10-01T00:00:00Z'},
        {'id': 'f2', 'topicId': 't1', 'word': 'run', 'partOfSpeech': 'v.', 'pronunciation': '/rʌn/', 'meaning': 'chạy', 'sortOrder': 2, 'updatedAt': '2026-10-01T00:00:00Z'},
      ],
      'grammarLessons': [],
      'grammarExamples': [],
      'quizzes': [
        {'id': 'qz1', 'title': 'Test Daily', 'quizType': 'TOPIC', 'topicId': 't1', 'passScorePercent': 50, 'updatedAt': '2026-10-01T00:00:00Z'},
      ],
      'quizQuestions': [
        {'id': 'qq1', 'quizId': 'qz1', 'questionText': 'apple = ?', 'options': ['táo', 'cam', 'chuối', 'nho'], 'correctOptionIndex': 0, 'sortOrder': 1},
        {'id': 'qq2', 'quizId': 'qz1', 'questionText': 'run = ?', 'options': ['đi', 'chạy', 'bơi', 'nhảy'], 'correctOptionIndex': 1, 'sortOrder': 2},
      ],
      'questDefinitions': [
        {'id': 'qd1', 'code': 'DAILY_REVIEW', 'title': 'Ôn 2 thẻ', 'questType': 'REVIEW_CARDS', 'frequency': 'DAILY', 'targetValue': 2, 'xpReward': 20, 'iconName': 'style', 'isActive': true},
      ],
      'rewardItems': [
        {'id': 'r1', 'code': 'B1', 'name': 'Lửa', 'itemType': 'BORDER', 'xpCost': 100, 'borderColors': [4294921551, 4294949445], 'isActive': true},
      ],
    };

const seedUser = {
  'id': 'u1',
  'email': 'a@b.c',
  'fullName': 'An',
  'level': 'A1',
  'slogan': 'Hi',
  'currentXp': 100,
  'totalLifetimeXp': 400,
  'streakDays': 2,
  'version': 1,
};

Future<void> seed(AppDatabase db) async {
  await db.transaction(() => db.contentDao.upsertContent(seedContent()));
  await db.profileDao.upsertFromUser(Map.of(seedUser), 0);
}

Future<int> count(AppDatabase db, String table, [String where = '1=1']) async =>
    (await db.customSelect('SELECT COUNT(*) AS c FROM $table WHERE $where').getSingle()).read<int>('c');
