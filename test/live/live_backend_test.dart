// Kiểm thử đầu-cuối với backend thật (không chạy mặc định: thiếu LIVE_API thì mọi test bị skip).
//
//   flutter test test/live/live_backend_test.dart \
//     --dart-define=LIVE_API=http://localhost:8081 \
//     --dart-define=BACKEND_LOG=<đường dẫn file log của backend> \
//     --dart-define=ADMIN_EMAIL=admin@flash.local --dart-define=ADMIN_PASSWORD=Admin@12345
//
// Backend phải bật REQUIRE_EMAIL_VERIFICATION=true và chưa cấu hình SMTP: chế độ dev in OTP ra log
// ("OTP <PURPOSE> cho <email>: <otp>"), test đọc OTP từ file BACKEND_LOG.
//
// Gọi backend đúng như app: `ApiClient` (dio + AuthInterceptor tự refresh token) với các API có kiểu
// (AuthApi, UserApi, AdminApi, GamificationApi, SyncApi). Các thao tác ghi mà app gửi qua hàng đợi
// đồng bộ (ôn thẻ, hoàn thành bài, nộp bài kiểm tra, ghi chú, bookmark, nhận nhiệm vụ, trang bị,
// hồ sơ, cài đặt) được đẩy lên `POST /v1/sync/push` với đúng opType / payload như `SyncWorker` +
// các repository ghi (lib/data/repositories), rồi kiểm tra `results[i]` / snapshot `user` / các GET.
// Giới hạn 30 request/phút cho /v1/sync/**: các op được gộp thành ít lô nhất có thể.
import 'dart:convert';
import 'dart:io';

import 'package:flash/core/clock.dart';
import 'package:flash/core/ids.dart';
import 'package:flash/core/utils.dart';
import 'package:flash/data/remote/api_client.dart';
import 'package:flash/data/remote/api_exception.dart';
import 'package:flash/data/remote/apis/admin_api.dart';
import 'package:flash/data/remote/apis/auth_api.dart';
import 'package:flash/data/remote/apis/gamification_api.dart';
import 'package:flash/data/remote/apis/sync_api.dart';
import 'package:flash/data/remote/apis/user_api.dart';
import 'package:flash/data/remote/dto/auth_dto.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';
import 'package:flash/models/grammar_model.dart';
import 'package:flash/models/quiz_model.dart';
import 'package:flash/models/quiz_review_model.dart';
import 'package:flash/models/topic_model.dart';
import 'package:flash/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String liveApi = String.fromEnvironment('LIVE_API');
const String backendLog = String.fromEnvironment('BACKEND_LOG');
const String adminEmail = String.fromEnvironment('ADMIN_EMAIL');
const String adminPassword = String.fromEnvironment('ADMIN_PASSWORD');

typedef Json = Map<String, dynamic>;

/// OTP mới nhất của một email trong log backend (chế độ dev in OTP ra log khi chưa có SMTP).
Future<String> otpFromLog(String email, String purpose) async {
  expect(backendLog, isNotEmpty, reason: 'Cần --dart-define=BACKEND_LOG=<file log của backend> để đọc OTP');
  for (var attempt = 0; attempt < 20; attempt++) {
    final text = utf8.decode(File(backendLog).readAsBytesSync(), allowMalformed: true);
    for (final line in const LineSplitter().convert(text).reversed) {
      if (line.contains('OTP $purpose cho $email:')) {
        return line.split(':').last.trim();
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  throw StateError('Không thấy OTP $purpose cho $email trong log');
}

Matcher apiError(String code) => throwsA(isA<ApiException>().having((e) => e.code, 'code', code));

String iso([DateTime? at]) => (at ?? Clock.now()).toUtc().toIso8601String();

/// Kết quả một lần `POST /v1/sync/push`.
class PushResult {
  PushResult(this.raw);

  final Json raw;

  List<Json> get results => (raw['results'] as List).cast<Json>();

  /// UserSnapshot sau khi server xử lý cả lô.
  Json get user => raw['user'] as Json;

  Json operator [](int i) => results[i];
}

void main() {
  final enabled = liveApi.isNotEmpty;

  late SecureStore store;
  late ApiClient client;
  late AuthApi authApi;
  late UserApi userApi;
  late AdminApi adminApi;
  late GamificationApi gameApi;
  late SyncApi syncApi;
  var forceLogouts = 0;

  setUpAll(() async {
    // flutter_secure_storage không chạy được trong `flutter test`: dùng bản giả trong bộ nhớ của plugin.
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    store = SecureStore();
    client = ApiClient(
      prefs: AppPrefs.fromInstance(await SharedPreferences.getInstance()),
      store: store,
      onForceLogout: () async => forceLogouts++,
      baseUrl: liveApi,
    );
    authApi = AuthApi(client);
    userApi = UserApi(client);
    adminApi = AdminApi(client);
    gameApi = GamificationApi(client);
    syncApi = SyncApi(client);
  });

  /// Giống `AuthNotifier.onAuthenticated`: lưu phiên vào SecureStore.
  Future<AuthDto> startSession(AuthDto auth) async {
    expect(auth.hasSession, isTrue);
    await store.saveSession(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      accessExpiresAt: Clock.now().toUtc().add(Duration(seconds: auth.expiresIn)),
      userId: auth.user.id,
      role: auth.user.role,
    );
    return auth;
  }

  Future<AuthDto> login(String email, String password) async =>
      startSession(await authApi.login(email: email, password: password, deviceId: await store.deviceId()));

  /// Giống `AuthNotifier.logout`: thu hồi refresh token ở server rồi xoá phiên local.
  Future<void> signOut() async {
    final refresh = await store.refreshToken();
    if (refresh != null) await authApi.logout(refresh);
    await store.clearSession();
    expect(await store.refreshToken(), isNull);
  }

  /// Đẩy một lô op lên như `SyncWorker._pushBatch`. [ops] = (opType, payload[, opId]).
  Future<PushResult> push(List<(String, Json, String?)> ops) async {
    final res = await syncApi.push(
      deviceId: await store.deviceId(),
      clientSentAt: Clock.now(),
      operations: [
        for (final (type, payload, opId) in ops)
          {'opId': opId ?? newId(), 'opType': type, 'createdAt': iso(), 'payload': payload},
      ],
    );
    final result = PushResult(res);
    expect(result.results, hasLength(ops.length));
    return result;
  }

  (String, Json, String?) op(String type, Json payload, {String? opId}) => (type, payload, opId);

  void expectApplied(Json r) {
    expect(r['status'], 'APPLIED', reason: 'op ${r['opId']}: ${r['errorCode']} ${r['message']}');
  }

  Json reviewPayload(Json card, String rating) => {
        'logId': newId(),
        'flashcardId': card['id'],
        'rating': rating,
        'responseTimeMs': 1500,
        'reviewedAt': iso(),
      };

  Json lessonPayload({String? topicId, String? grammarLessonId, int cardsReviewed = 0, required int durationSeconds}) => {
        'id': newId(),
        'lessonType': topicId != null ? 'TOPIC' : 'GRAMMAR',
        'topicId': ?topicId,
        'grammarLessonId': ?grammarLessonId,
        'cardsReviewed': cardsReviewed,
        'durationSeconds': durationSeconds,
        'completedAt': iso(),
      };

  Future<({Quiz quiz, List<QuizQuestion> questions})> quizDetail(String quizId) async {
    final j = await client.get('/v1/quizzes/get/$quizId') as Json;
    return (
      quiz: Quiz.fromJson(j['quiz'] as Json),
      questions: (j['questions'] as List).cast<Json>().map(QuizQuestion.fromJson).toList(),
    );
  }

  /// Payload QUIZ_SUBMIT như `QuizRepository.submit`. Server yêu cầu thời gian làm bài >= số câu:
  /// lùi giờ bắt đầu cho đủ.
  Future<Json> quizPayload(String quizId, {required bool allCorrect}) async {
    final d = await quizDetail(quizId);
    final n = d.questions.length;
    final startedAt = Clock.now().subtract(Duration(seconds: n + 5));
    final submittedAt = Clock.now();
    return {
      'attemptId': newId(),
      'quizId': d.quiz.id,
      'startedAt': iso(startedAt),
      'submittedAt': iso(submittedAt),
      'timeTakenSeconds': submittedAt.difference(startedAt).inSeconds.clamp(n, 86400),
      'answers': [
        for (final q in d.questions)
          {
            'questionId': q.id,
            'selectedOptionIndex': allCorrect ? q.correctAnswerIndex : (q.correctAnswerIndex + 1) % q.options.length,
          },
      ],
    };
  }

  Future<List<Json>> flashcards(String topicId) async =>
      (await client.get('/v1/flashcards', query: {'topicId': topicId}) as List).cast<Json>();

  Future<List<Quiz>> quizzesOfTopic(String topicId) async =>
      (await client.get('/v1/quizzes', query: {'topicId': topicId}) as List).cast<Json>().map(Quiz.fromJson).toList();

  Future<GrammarDetail> grammarDetail(String id) async =>
      GrammarDetail.fromJson(await client.get('/v1/grammar/get/$id') as Json);

  Future<Json> statistics(String range, {DateTime? from, DateTime? to}) async =>
      await client.get('/v1/users/me/statistics', query: {
        'range': range,
        if (from != null) 'from': apiDate(from),
        if (to != null) 'to': apiDate(to),
      }) as Json;

  List<Json> daily(Json stats) => (stats['daily'] as List).cast<Json>();

  final email = 'live-${DateTime.now().millisecondsSinceEpoch}@test.local';
  const password = 'Password@123';

  test('1. Đăng ký bắt buộc xác thực email bằng OTP rồi mới đăng nhập được', () async {
    final registered = await authApi.register(
        fullName: 'Học Viên Live', email: email, password: password, deviceId: await store.deviceId());
    expect(registered.verificationRequired, isTrue);
    expect(registered.hasSession, isFalse);
    expect(registered.user.emailVerified, isFalse);
    expect(await store.refreshToken(), isNull);

    // Chưa xác thực: đăng nhập bị từ chối với mã EMAIL_NOT_VERIFIED
    await expectLater(() => login(email, password), apiError('EMAIL_NOT_VERIFIED'));

    // Gửi lại mã luôn trả 200 (trong 60 giây thì server giữ nguyên mã cũ)
    await authApi.resendVerification(email);

    final deviceId = await store.deviceId();
    final wrong = (await otpFromLog(email, 'EMAIL_VERIFY')) == '000000' ? '111111' : '000000';
    await expectLater(() => authApi.verifyEmail(email: email, otp: wrong, deviceId: deviceId), apiError('INVALID_OTP'));

    final otp = await otpFromLog(email, 'EMAIL_VERIFY');
    final result = await startSession(await authApi.verifyEmail(email: email, otp: otp, deviceId: deviceId));
    expect(result.user.email, email);
    expect(result.user.emailVerified, isTrue);
    expect(result.user.status, 'ACTIVE');
    expect(await store.refreshToken(), isNotNull);

    // Token vừa cấp gọi được API cần đăng nhập
    final me = await userApi.me();
    expect(me['email'], email);
    expect(me['currentXp'], 0);
  }, skip: !enabled);

  late List<Json> cards;
  late String topicId;

  test('2. Nội dung seed đầy đủ: 18 chủ đề, 40 chủ điểm ngữ pháp, mỗi chủ đề có thẻ và bài kiểm tra', () async {
    final topics = await client.getPage('/v1/topics', Topic.fromJson, query: {'status': 'ALL', 'page': 0, 'size': 100});
    expect(topics.totalElements, greaterThanOrEqualTo(18));
    final dailyLife = topics.items.firstWhere((t) => t.title == 'Daily Life');
    expect(dailyLife.totalWords, greaterThanOrEqualTo(25));
    topicId = dailyLife.id;
    cards = await flashcards(topicId);
    expect(cards.length, dailyLife.totalWords);

    final grammar = await client.getPage('/v1/grammar', Grammar.fromJson, query: {'status': 'ALL', 'page': 0, 'size': 100});
    expect(grammar.totalElements, greaterThanOrEqualTo(40));
    for (final topic in topics.items) {
      final quizzes = await quizzesOfTopic(topic.id);
      expect(quizzes, isNotEmpty, reason: '${topic.title} chưa có bài kiểm tra');
      expect(quizzes.fold<int>(0, (s, q) => s + q.questionCount), greaterThanOrEqualTo(topic.totalWords),
          reason: '${topic.title}: mỗi từ phải có câu hỏi');
    }
    final detail = await grammarDetail(grammar.items.first.id);
    expect(detail.content, isNotEmpty);
    expect(detail.examples.length, greaterThanOrEqualTo(3));
    expect(detail.quizId, isNotNull);

    // App đọc nội dung qua delta-pull /v1/sync/content (PullService.pullContent)
    final content = await syncApi.content(limit: 500);
    expect(content['cursor'], isNotNull);
    final changes = content['changes'] as Json;
    expect((changes['topics'] as List?) ?? const [], isNotEmpty);
  }, skip: !enabled);

  test('3. Học thẻ (FLASHCARD_REVIEW): Know cộng XP từ server, từ được tính là đã học, Again không cộng', () async {
    final firstPayload = reviewPayload(cards[0], 'KNOW');
    final first = await push([op('FLASHCARD_REVIEW', firstPayload)]);
    expectApplied(first[0]);
    final firstData = first[0]['data'] as Json;
    expect(firstData['xpAwarded'], 7); // +2 know, +5 từ mới học
    expect((firstData['progress'] as Json)['isLearned'], isTrue);
    expect(first.user['currentXp'], 7);
    expect(first.user['totalWordsLearned'], 1);
    expect(first.user['streakDays'], 1);

    // Gửi lại đúng op (cùng opId, như sau khi app bị kill giữa chừng): DUPLICATE, không cộng lại
    final replay = await push([
      op('FLASHCARD_REVIEW', firstPayload, opId: first[0]['opId'] as String),
      op('FLASHCARD_REVIEW', reviewPayload(cards[1], 'AGAIN')),
    ]);
    expect(replay[0]['status'], 'DUPLICATE');
    expect((replay[0]['data'] as Json)['xpAwarded'], 7); // kết quả cũ
    expectApplied(replay[1]);
    expect((replay[1]['data'] as Json)['xpAwarded'], 0);
    expect(replay.user['currentXp'], 7);

    final rest = await push([for (var i = 2; i < 6; i++) op('FLASHCARD_REVIEW', reviewPayload(cards[i], 'KNOW'))]);
    rest.results.forEach(expectApplied);
    expect(rest.user['totalWordsLearned'], 5);
    expect(rest.user['currentXp'], 7 + 4 * 7);
  }, skip: !enabled);

  test('4. LESSON_COMPLETE: học lại bài đã xong không cộng thêm "bài học hoàn thành" hay XP', () async {
    final res = await push([
      op('LESSON_COMPLETE', lessonPayload(topicId: topicId, cardsReviewed: 6, durationSeconds: 120)),
      op('LESSON_COMPLETE', lessonPayload(topicId: topicId, cardsReviewed: 6, durationSeconds: 90)),
    ]);
    res.results.forEach(expectApplied);
    final first = res[0]['data'] as Json;
    expect(first['xpAwarded'], 10);
    expect((first['user'] as Json)['completedLessons'], 1);
    expect((first['todayLessons'] as Json)['done'], 1);

    final again = res[1]['data'] as Json;
    expect(again['xpAwarded'], 0);
    expect((again['todayLessons'] as Json)['done'], 1);
    expect(res.user['completedLessons'], 1);

    // Tiến độ chủ đề phản ánh số từ đã học
    final topic = await client.get('/v1/topics/get/$topicId') as Json;
    expect(topic['learnedWords'], 5);
    expect((topic['progress'] as num).toDouble(), closeTo(5 / (topic['totalWords'] as int), 0.001));
    expect(topic['status'], 'IN_PROGRESS');
  }, skip: !enabled);

  test('5. QUIZ_SUBMIT bài kiểm tra từ vựng: server chấm điểm, cộng XP một lần mỗi ngày', () async {
    final quizzes = await quizzesOfTopic(topicId);
    final quizId = quizzes.first.id;
    final xpBefore = (await userApi.me())['currentXp'] as int;

    final res = await push([
      op('QUIZ_SUBMIT', await quizPayload(quizId, allCorrect: false)),
      op('QUIZ_SUBMIT', await quizPayload(quizId, allCorrect: true)),
      // Làm lại cùng bài trong ngày: không cộng thêm
      op('QUIZ_SUBMIT', await quizPayload(quizId, allCorrect: true)),
    ]);
    res.results.forEach(expectApplied);
    final wrong = res[0]['data'] as Json;
    expect(wrong['correctAnswers'], 0);
    expect(wrong['passed'], isFalse);

    final perfect = res[1]['data'] as Json;
    expect(perfect['scorePercent'], 100);
    expect(perfect['passed'], isTrue);
    expect((perfect['wrongQuestionIds'] as List?) ?? const [], isEmpty);

    final again = res[2]['data'] as Json;
    expect(again['xpAwarded'], 0);

    final gained = [wrong, perfect, again].fold<int>(0, (s, r) => s + ((r['xpAwarded'] as int?) ?? 0));
    expect(res.user['currentXp'], xpBefore + gained);
  }, skip: !enabled);

  test('6. Ngữ pháp: đọc xong ghi nhận bài, qua bài kiểm tra thì hoàn thành chủ điểm', () async {
    final lessons = await client.getPage('/v1/grammar', Grammar.fromJson, query: {'page': 0, 'size': 100});
    final lesson = lessons.items.firstWhere((l) => l.title == 'Present Simple');
    final detail = await grammarDetail(lesson.id);

    final res = await push([
      op('LESSON_COMPLETE', lessonPayload(grammarLessonId: lesson.id, durationSeconds: 60)),
      op('QUIZ_SUBMIT', await quizPayload(detail.quizId!, allCorrect: true)),
    ]);
    res.results.forEach(expectApplied);
    expect((res[0]['data'] as Json)['xpAwarded'], 10);
    expect(res.user['completedLessons'], 2);

    final result = res[1]['data'] as Json;
    expect(result['passed'], isTrue);
    expect(result['totalQuestions'], 6);
    final after = await grammarDetail(lesson.id);
    expect(after.grammar.status, 'COMPLETED');
    expect(after.grammar.progress, 1.0);

    final review = (await client.get('/v1/quizzes/attempts/get/${result['id']}/review') as List)
        .cast<Json>()
        .map(QuizReviewItem.fromJson)
        .toList();
    expect(review, hasLength(6));
    expect(review.every((r) => r.isCorrect), isTrue);
    expect(review.first.explanation, isNotEmpty);
  }, skip: !enabled);

  test('7. Thống kê: tuần, tháng, năm, tất cả và khoảng ngày tùy chọn', () async {
    final today = dateOnly(DateTime.now());
    final week = await statistics('WEEK');
    expect(daily(week), hasLength(7));
    expect(daily(week).last['wordsLearned'], 5);
    expect((week['accuracy'] as num).toDouble(), greaterThan(0));

    final month = await statistics('MONTH');
    expect(daily(month), hasLength(30));
    // YEAR chỉ trả các ngày có hoạt động
    final year = await statistics('YEAR');
    expect(daily(year), hasLength(1));
    expect(year['wordsLearned'], 5);
    final all = await statistics('ALL');
    expect(all['wordsLearned'], 5);
    expect(all['from'], apiDate(today));

    final custom = await statistics('CUSTOM', from: DateTime(today.year, today.month, today.day - 9), to: today);
    expect(daily(custom), hasLength(10));
    expect(daily(custom).last['wordsLearned'], 5);

    // CUSTOM thiếu from/to: lỗi kiểm tra dữ liệu
    await expectLater(() => statistics('CUSTOM'), apiError('VALIDATION_ERROR'));

    // Kỳ liền trước cùng độ dài (so sánh "+N từ so với kỳ trước")
    final from = DateTime.parse(week['from'] as String);
    final to = DateTime.parse(week['to'] as String);
    final days = DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays + 1;
    final previous = await statistics('CUSTOM',
        from: DateTime(from.year, from.month, from.day - days), to: DateTime(from.year, from.month, from.day - 1));
    expect(daily(previous), hasLength(days));
    expect(previous['wordsLearned'], 0);
  }, skip: !enabled);

  test('8. Từ đã lưu (BOOKMARK_SET) và ghi chú (NOTE_UPSERT / NOTE_DELETE)', () async {
    final card = cards[0];
    final cardId = card['id'] as String;
    const text = 'mẹo nhớ: ghi chú thử';

    final saved = await push([
      op('BOOKMARK_SET', {'flashcardId': cardId, 'bookmarked': true, 'clientUpdatedAt': iso()}),
      op('NOTE_UPSERT', {
        'noteId': newId(),
        'flashcardId': cardId,
        'content': text,
        'baseVersion': null,
        'clientUpdatedAt': iso(),
      }),
    ]);
    saved.results.forEach(expectApplied);
    expect((saved[0]['data'] as Json)['isBookmarked'], isTrue);
    final note = (saved[1]['data'] as Json)['note'] as Json;
    expect(note['content'], text);

    var bookmarks = await client.get('/v1/flashcards/bookmarks', query: {'page': 0, 'size': 50}) as Json;
    expect(bookmarks['totalElements'], 1);
    expect(((bookmarks['items'] as List).single as Json)['word'], card['word']);

    final fresh = (await flashcards(topicId)).firstWhere((c) => c['id'] == cardId);
    expect(fresh['note'], text);
    expect(fresh['isBookmarked'], isTrue);

    final removed = await push([
      op('BOOKMARK_SET', {'flashcardId': cardId, 'bookmarked': false, 'clientUpdatedAt': iso()}),
      op('NOTE_DELETE', {
        'noteId': note['noteId'],
        'flashcardId': cardId,
        'baseVersion': note['version'],
        'clientUpdatedAt': iso(),
      }),
    ]);
    removed.results.forEach(expectApplied);
    bookmarks = await client.get('/v1/flashcards/bookmarks', query: {'page': 0, 'size': 50}) as Json;
    expect(bookmarks['totalElements'], 0);
    final cleared = (await flashcards(topicId)).firstWhere((c) => c['id'] == cardId);
    expect(cleared['note'], isNull);
    expect(cleared['isBookmarked'], isNot(true));

    // Thiết bị khác nhận tombstone qua /v1/sync/pull (PullService.pullUserData)
    final pulled = await syncApi.pull(limit: 500);
    final changes = pulled['changes'] as Json;
    final noteRows = ((changes['userFlashcardNotes'] as List?) ?? const []).cast<Json>();
    expect(noteRows.firstWhere((n) => n['flashcardId'] == cardId)['deletedAt'], isNotNull);
    final bookmarkRows = ((changes['userBookmarks'] as List?) ?? const []).cast<Json>();
    expect(bookmarkRows.firstWhere((b) => b['flashcardId'] == cardId)['deletedAt'], isNotNull);
  }, skip: !enabled);

  test('9. Nhiệm vụ, cửa hàng, trang bị viền, slogan, cài đặt và bảng xếp hạng có slogan + viền', () async {
    final today = await gameApi.todayQuests();
    final quests = (today['quests'] as List).cast<Json>();
    expect(quests, isNotEmpty);
    final claimable = quests.where((q) => (q['current'] as int) >= (q['target'] as int) && q['isClaimed'] != true).toList();
    if (claimable.isNotEmpty) {
      final xpBefore = (await userApi.me())['currentXp'] as int;
      final questId = claimable.first['id'] as String;
      final claim = await push([
        op('QUEST_CLAIM', {'userQuestId': questId, 'claimedAt': iso()}),
        // Nhận lại (op khác): bị từ chối, app rollback
        op('QUEST_CLAIM', {'userQuestId': questId, 'claimedAt': iso()}),
      ]);
      expectApplied(claim[0]);
      final xp = (claim[0]['data'] as Json)['xpAwarded'] as int;
      expect(claim[1]['status'], 'REJECTED');
      expect(claim[1]['errorCode'], 'ALREADY_CLAIMED');
      expect(claim.user['currentXp'], xpBefore + xp);
    }

    // Mua chỉ online (ShopRepository.purchase) với Idempotency-Key
    final shop = await gameApi.shopItems();
    final free = shop.firstWhere((s) => s.xpCost == 0 && s.isBorder && !s.isUnlocked);
    final key = newId();
    final bought = await gameApi.purchase(free.id, key);
    final inventory = bought['inventory'] as Json;
    expect(inventory['rewardItemId'], free.id);
    // Gửi lại cùng key: nhận lại đúng kết quả cũ, không mua hai lần
    final again = await gameApi.purchase(free.id, key);
    expect((again['inventory'] as Json)['id'], inventory['id']);

    final me = await userApi.me();
    final settings = await userApi.settings();
    const slogan = 'Slogan từ test live';
    final res = await push([
      op('ITEM_EQUIP', {'inventoryId': inventory['id'], 'equipped': true, 'clientUpdatedAt': iso()}),
      op('PROFILE_UPDATE', {'slogan': slogan, 'baseVersion': me['version'] ?? 0, 'clientUpdatedAt': iso()}),
      op('SETTINGS_UPDATE', {
        'isNotificationEnabled': settings['isNotificationEnabled'] ?? true,
        'isSoundEnabled': settings['isSoundEnabled'] ?? true,
        'isVibrationEnabled': settings['isVibrationEnabled'] ?? true,
        'isDarkMode': !(settings['isDarkMode'] == true),
        'appLanguage': 'en',
        'dailyReminderTime': '21:30',
        'dailyGoalLessons': 7,
        'clientUpdatedAt': iso(),
      }),
    ]);
    res.results.forEach(expectApplied);
    expect(((res[0]['data'] as Json)['inventory'] as Json)['isEquipped'], isTrue);
    expect(((res[1]['data'] as Json)['user'] as Json)['slogan'], slogan);
    final newSettings = (res[2]['data'] as Json)['settings'] as Json;
    expect(newSettings['appLanguage'], 'en');
    expect(newSettings['dailyGoalLessons'], 7);
    expect(newSettings['isDarkMode'], !(settings['isDarkMode'] == true));

    final equipped = (await gameApi.shopItems()).firstWhere((s) => s.id == free.id);
    expect(equipped.isEquipped, isTrue);
    expect((await userApi.me())['slogan'], slogan);
    final stored = await userApi.settings();
    expect(stored['dailyReminderTime'], '21:30');
    expect(stored['appLanguage'], 'en');

    // limit riêng để không dính cache 60 giây của bảng xếp hạng ở server
    final board = await gameApi.leaderboard('xp', limit: 10 + DateTime.now().second % 40 + 1);
    final mine = board.items.firstWhere((e) => e.userId == me['id']);
    expect(mine.slogan, slogan);
    expect(mine.equippedBorderColors, free.borderColors);
    expect(board.me?.rank, isNotNull);
  }, skip: !enabled);

  test('10. Đổi mật khẩu cần OTP gửi qua email; quên mật khẩu bằng OTP', () async {
    final deviceId = await store.deviceId();
    await expectLater(
        () => userApi.changePassword(
            currentPassword: password, newPassword: 'NewPass@123', otp: '123456', deviceId: deviceId),
        apiError('INVALID_OTP'));

    await userApi.requestChangePasswordOtp();
    final otp = await otpFromLog(email, 'CHANGE_PASSWORD');
    // Như SettingsRepository.changePassword: server thu hồi refresh token cũ, lưu ngay cặp token mới
    final changed = await userApi.changePassword(
        currentPassword: password, newPassword: 'NewPass@123', otp: otp, deviceId: deviceId);
    expect(changed.hasSession, isTrue);
    await store.saveTokens(
      accessToken: changed.accessToken,
      refreshToken: changed.refreshToken,
      accessExpiresAt: Clock.now().toUtc().add(Duration(seconds: changed.expiresIn)),
    );
    expect((await userApi.me())['email'], email);

    await signOut();
    await login(email, 'NewPass@123');

    await authApi.forgotPassword(email);
    final resetOtp = await otpFromLog(email, 'PASSWORD_RESET');
    await authApi.resetPassword(email: email, otp: resetOtp, newPassword: 'Reset@12345');
    await store.clearSession();
    await expectLater(() => login(email, 'NewPass@123'), apiError('INVALID_CREDENTIALS'));
    final back = await login(email, 'Reset@12345');
    expect(back.user.email, email);
  }, skip: !enabled);

  test('11. Admin: tổng quan không đếm admin vào học viên, danh sách học viên không có admin, CRUD nội dung', () async {
    expect(adminEmail, isNotEmpty, reason: 'Cần --dart-define=ADMIN_EMAIL / ADMIN_PASSWORD');
    await signOut();
    final adminLogin = await login(adminEmail, adminPassword);
    expect(adminLogin.user.role, 'ADMIN');

    final overview = await adminApi.overview();
    expect(overview.admins, greaterThanOrEqualTo(1));
    final students = await adminApi.users(role: 'USER', size: 100);
    expect(students.items.every((u) => u.role == 'USER'), isTrue);
    expect(overview.students, students.totalElements);
    expect(overview.topics, greaterThanOrEqualTo(18));
    expect(overview.grammarLessons, greaterThanOrEqualTo(40));
    expect(overview.recentStudents.any((s) => s.email == email), isTrue);

    final admins = await adminApi.users(role: 'ADMIN');
    expect(admins.items, isNotEmpty);
    expect(admins.items.every((UserModel u) => u.isAdmin), isTrue);

    // Bảng xếp hạng không có admin; admin không có hạng
    final board = await gameApi.leaderboard('xp');
    expect(board.items.any((e) => e.userId == adminLogin.user.id), isFalse);
    expect(board.me?.rank, isNull);

    // CRUD chủ đề + từ vựng
    final title = 'Live Test Topic ${DateTime.now().millisecondsSinceEpoch}';
    await adminApi.createTopic({'title': title, 'iconPath': '🧪', 'level': 'A1', 'estimatedMinutes': 5, 'isPublished': true});
    var topics = await adminApi.topics(keyword: title);
    final created = topics.items.firstWhere((t) => t.title == title);
    await adminApi.createFlashcard({
      'topicId': created.id,
      'word': 'laboratory',
      'partOfSpeech': 'n.',
      'pronunciation': '/ləˈbɒrətri/',
      'meaning': 'phòng thí nghiệm',
      'example': 'She works in a laboratory.',
      'exampleTranslation': 'Cô ấy làm việc trong phòng thí nghiệm.',
    });
    expect(await adminApi.flashcards(created.id), hasLength(1));
    await adminApi.deleteTopic(created.id);
    topics = await adminApi.topics(keyword: title);
    expect(topics.items.any((t) => t.id == created.id), isFalse);

    // Học viên không gọi được API admin
    await signOut();
    await login(email, 'Reset@12345');
    await expectLater(adminApi.overview, throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)));
  }, skip: !enabled);

  test('12. Mật khẩu sai báo đúng lỗi, token hết hạn tự làm mới', () async {
    await signOut();
    await expectLater(() => login(email, 'sai-mat-khau'), apiError('INVALID_CREDENTIALS'));
    await login(email, 'Reset@12345');

    // Làm hỏng access token (vẫn "còn hạn" ở client): lần gọi kế tiếp gặp 401, AuthInterceptor tự refresh rồi gọi lại
    final logoutsBefore = forceLogouts;
    await store.saveTokens(
      accessToken: 'token-het-han',
      refreshToken: (await store.refreshToken())!,
      accessExpiresAt: Clock.now().toUtc().add(const Duration(minutes: 10)),
    );
    final me = await userApi.me();
    expect(me['email'], email);
    expect(await store.accessToken(), isNot('token-het-han'));
    expect(forceLogouts, logoutsBefore);

    // Refresh token bị thu hồi (đăng xuất ở server): lần refresh sau bị từ chối -> onForceLogout
    final refresh = (await store.refreshToken())!;
    await authApi.logout(refresh);
    await store.saveTokens(
      accessToken: 'token-het-han',
      refreshToken: refresh,
      accessExpiresAt: Clock.now().toUtc().add(const Duration(minutes: 10)),
    );
    await expectLater(userApi.me, throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)));
    expect(forceLogouts, logoutsBefore + 1);
    await store.clearSession();
  }, skip: !enabled);
}
