import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flash/data/remote/api_client.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dữ liệu mẫu và server giả dùng chung cho `models_test.dart` và `screens_layout_test.dart`.

// ---------------------------------------------------------------- server giả (dio)

/// Bọc dữ liệu vào envelope `{success, code, message, data}` như server thật.
Map<String, dynamic> envelope(Object? data) => {'success': true, 'code': 'OK', 'message': 'Thành công', 'data': data};

typedef RouteHandler = Object? Function(RequestOptions request);

/// Adapter trả dữ liệu theo đường dẫn. Đường dẫn chưa giả lập ném lỗi kết nối, ApiClient đổi thành
/// `NetworkException` nên app xử lý như đang offline (không bao giờ gọi server thật).
class RoutedAdapter implements HttpClientAdapter {
  RoutedAdapter(this.routes);

  final Map<String, RouteHandler> routes;
  final List<RequestOptions> requests = [];

  List<String> get paths => requests.map((r) => r.path).toList();

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final handler = routes[options.path];
    if (handler == null) {
      throw DioException(requestOptions: options, type: DioExceptionType.connectionError, message: 'offline (test)');
    }
    return ResponseBody.fromString(
      jsonEncode(envelope(handler(options))),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Phiên đăng nhập hợp lệ (token còn hạn tới năm 2100) để AuthInterceptor không đi refresh.
Map<String, String> signedInSecureValues({String userId = 'u1', String role = 'USER'}) => {
      SecureStore.kAccessToken: 'test-access',
      SecureStore.kRefreshToken: 'test-refresh',
      SecureStore.kAccessExpiresAt: DateTime.utc(2100).millisecondsSinceEpoch.toString(),
      SecureStore.kUserId: userId,
      SecureStore.kUserRole: role,
      SecureStore.kDeviceId: 'test-device',
    };

/// SharedPreferences + SecureStore giả lập trong bộ nhớ.
Future<({AppPrefs prefs, SecureStore store})> fakeStorage({
  Map<String, Object> prefs = const {},
  Map<String, String>? secure,
}) async {
  SharedPreferences.setMockInitialValues(Map.of(prefs));
  FlutterSecureStorage.setMockInitialValues(Map.of(secure ?? signedInSecureValues()));
  return (prefs: AppPrefs.fromInstance(await SharedPreferences.getInstance()), store: SecureStore());
}

ApiClient fakeApiClient(AppPrefs prefs, SecureStore store, RoutedAdapter adapter) => ApiClient(
      prefs: prefs,
      store: store,
      baseUrl: 'http://test.invalid',
      httpAdapter: adapter,
      onForceLogout: () async {},
    );

// ---------------------------------------------------------------- JSON của server

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
      'createdAt': '2026-09-01T08:30:00Z',
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

Map<String, dynamic> flashcardJson(String id, String word, {String topicId = 't1'}) => {
      'id': id,
      'topicId': topicId,
      'word': word,
      'partOfSpeech': 'n.',
      'pronunciation': '/wɜːd/',
      'meaning': 'từ ngữ',
      'example': 'This is a $word.',
      'exampleTranslation': 'Đây là một $word.',
    };

/// `LeaderboardResponse`: người hạng 3 chưa đặt slogan và không trang bị viền.
Map<String, dynamic> leaderboardJson() => {
      'items': [
        {
          'rank': 1,
          'userId': 'u9',
          'fullName': 'Trần Thị Bích Ngọc Rất Dài Tên',
          'avatarUrl': null,
          'slogan': 'Chúa tể ngữ pháp 👑',
          'equippedBorderColors': [4294921551, 4294933061, 4294945088],
          'score': 3200,
        },
        {
          'rank': 2,
          'userId': 'u1',
          'fullName': 'Nguyễn Văn Tên Rất Dài Để Thử Tràn Dòng',
          'slogan': 'Học là phải vui',
          'equippedBorderColors': [],
          'score': 560,
        },
        {'rank': 3, 'userId': 'u3', 'fullName': 'An', 'score': 100},
      ],
      'me': {'rank': 2, 'score': 560},
    };
