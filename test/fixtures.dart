import 'dart:convert';
import 'package:flash/data/api/api_client.dart';
import 'package:flash/data/api/session_store.dart';
import 'package:flash/data/app_state.dart';
import 'package:flash/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Bọc dữ liệu vào envelope `{success, code, message, data}` như server thật.
String envelope(Object? data, {bool success = true, String code = 'OK', String message = 'Thành công', List<Map<String, String>>? errors}) =>
    jsonEncode({'success': success, 'code': code, 'message': message, 'data': data, if (errors != null) 'errors': errors});

http.Response okJson(Object? data) => http.Response.bytes(utf8.encode(envelope(data)), 200, headers: {'content-type': 'application/json; charset=utf-8'});

Map<String, dynamic> page(List<Map<String, dynamic>> items) =>
    {'items': items, 'page': 0, 'size': 50, 'totalElements': items.length, 'totalPages': 1};

Map<String, dynamic> userJson({String role = 'USER', int xp = 120, int streak = 3}) => {
      'id': 'u1',
      'fullName': 'Nguyễn Văn Tên Rất Dài Để Thử Tràn Dòng',
      'email': 'student@example.com',
      'level': 'A2',
      'slogan': 'Học là phải vui',
      'currentXp': xp,
      'targetXp': 100,
      'totalLifetimeXp': 560,
      'streakDays': streak,
      'longestStreak': 9,
      'totalWordsLearned': 42,
      'completedLessons': 7,
      'role': role,
      'status': 'ACTIVE',
      'emailVerified': true,
      'hasPassword': true,
      'version': 2,
    };

Map<String, dynamic> topicJson(String id, String title, {int words = 30, double progress = 0.2, String status = 'IN_PROGRESS'}) => {
      'id': id,
      'title': title,
      'description': 'Mô tả',
      'iconPath': '☀️',
      'level': 'A1',
      'estimatedMinutes': 10,
      'totalWords': words,
      'learnedWords': (words * progress).round(),
      'progress': progress,
      'status': status,
      'isPublished': true,
    };

Map<String, dynamic> grammarJson(String id, String title, {double progress = 0, String status = 'NOT_STARTED'}) => {
      'id': id,
      'title': title,
      'description': 'Mô tả ngữ pháp',
      'structure': 'S + V(s/es) + O',
      'iconName': 'account_tree',
      'level': 'A1',
      'estimatedMinutes': 12,
      'progress': progress,
      'status': status,
      'isPublished': true,
    };

Map<String, dynamic> flashcardJson(String id, String word, {bool learned = false}) => {
      'id': id,
      'topicId': 't1',
      'word': word,
      'partOfSpeech': 'n.',
      'pronunciation': '/wɜːd/',
      'meaning': 'từ ngữ',
      'example': 'This is a $word.',
      'exampleTranslation': 'Đây là một $word.',
      'isBookmarked': false,
      'isLearned': learned,
      'srsBox': learned ? 1 : 0,
    };

Map<String, dynamic> homeJson() => {
      'fullName': 'Nguyễn Văn Tên Rất Dài Để Thử Tràn Dòng',
      'streakDays': 3,
      'currentXp': 120,
      'targetXp': 100,
      'todayLessons': {'done': 3, 'goal': 5},
      'continueLesson': {'id': 't1', 'type': 'vocabulary', 'title': 'Business Vocabulary Advanced Topics', 'level': 'B1', 'progress': 0.6, 'itemCount': 20, 'estimatedMinutes': 8},
      'recommended': [
        {'id': 't2', 'type': 'vocabulary', 'title': 'Travel', 'level': 'A2', 'progress': 0.3, 'itemCount': 28, 'estimatedMinutes': 8, 'coverColor': 4290502395},
        {'id': 'g1', 'type': 'grammar', 'title': 'Present Perfect Continuous', 'level': 'B1', 'progress': 0.0, 'itemCount': 4, 'estimatedMinutes': 12},
      ],
      'todayChallenge': {'id': 'q1', 'questDefinitionId': 'd1', 'title': 'Học 20 Flashcard mới', 'iconName': 'style', 'current': 12, 'target': 20, 'xp': 50, 'isClaimed': false},
    };

Map<String, dynamic> statisticsJson({String range = 'WEEK', String from = '2026-09-29', String to = '2026-10-05', List<Map<String, dynamic>>? daily}) => {
      'range': range,
      'from': from,
      'to': to,
      'daily': daily ?? [],
      'accuracy': 0.85,
      'xpGained': 120,
      'wordsLearned': 15,
      'studySeconds': 600,
      'streakDays': 3,
      'longestStreak': 9,
      'totalWordsLearned': 42,
    };

/// Dựng một MockClient trả dữ liệu theo đường dẫn; đường dẫn lạ trả 404 để lộ ngay API nào chưa được giả lập.
MockClient routedClient(Map<String, Object? Function(http.Request request)> routes) {
  return MockClient((request) async {
    final handler = routes[request.url.path];
    if (handler == null) {
      return http.Response.bytes(utf8.encode(envelope(null, success: false, code: 'NOT_FOUND', message: 'Chưa giả lập ${request.url.path}')), 404,
          headers: {'content-type': 'application/json; charset=utf-8'});
    }
    return okJson(handler(request));
  });
}

/// Chuẩn bị app như đã đăng nhập (không đụng secure storage).
void signInForTest({String role = 'USER', int xp = 120}) {
  SessionStore.accessToken = 'test-access';
  SessionStore.refreshToken = 'test-refresh';
  AppState.I.setUser(UserModel.fromJson(userJson(role: role, xp: xp)));
  AppState.I.setInventory(const []);
}

void useRoutes(Map<String, Object? Function(http.Request request)> routes) => ApiClient.I.useClient(routedClient(routes));
