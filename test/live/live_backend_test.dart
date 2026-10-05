// Kiểm thử đầu-cuối với backend thật (không chạy mặc định).
//
//   flutter test test/live/live_backend_test.dart \
//     --dart-define=LIVE_API=http://localhost:8081 \
//     --dart-define=BACKEND_LOG=<đường dẫn file log của backend> \
//     --dart-define=ADMIN_EMAIL=admin@flash.local --dart-define=ADMIN_PASSWORD=Admin@12345
//
// Backend phải bật REQUIRE_EMAIL_VERIFICATION=true và chưa cấu hình SMTP (OTP được đọc từ log).
import 'dart:io';
import 'package:flash/core/config.dart';
import 'package:flash/core/utils.dart';
import 'package:flash/data/admin_repository.dart';
import 'package:flash/data/api/api_client.dart';
import 'package:flash/data/api/api_exception.dart';
import 'package:flash/data/api/session_store.dart';
import 'package:flash/data/app_state.dart';
import 'package:flash/data/auth_repository.dart';
import 'package:flash/data/content_repository.dart';
import 'package:flash/data/game_repository.dart';
import 'package:flash/data/progress_repository.dart';
import 'package:flash/data/study_repository.dart';
import 'package:flash/data/user_repository.dart';
import 'package:flash/models/flashcard_model.dart';
import 'package:flash/models/quiz_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String liveApi = String.fromEnvironment('LIVE_API');
const String backendLog = String.fromEnvironment('BACKEND_LOG');
const String adminEmail = String.fromEnvironment('ADMIN_EMAIL');
const String adminPassword = String.fromEnvironment('ADMIN_PASSWORD');

/// OTP mới nhất của một email trong log backend (chế độ dev in OTP ra log khi chưa có SMTP).
Future<String> otpFromLog(String email, String purpose) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    final lines = File(backendLog).readAsLinesSync();
    for (final line in lines.reversed) {
      if (line.contains('OTP $purpose cho $email:')) {
        return line.split(':').last.trim();
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  throw StateError('Không thấy OTP $purpose cho $email trong log');
}

Future<QuizResult> takeQuiz(String quizId, {required bool allCorrect}) async {
  final quiz = await ContentRepository.quiz(quizId);
  final answers = <int?>[
    for (final q in quiz.questions) allCorrect ? q.correctAnswerIndex : (q.correctAnswerIndex + 1) % q.options.length,
  ];
  // Server yêu cầu thời gian làm bài >= số câu: lùi giờ bắt đầu cho đủ
  final startedAt = DateTime.now().subtract(Duration(seconds: quiz.questions.length + 5));
  return StudyRepository.submitQuiz(quizId: quiz.quiz.id, questions: quiz.questions, answers: answers, startedAt: startedAt);
}

void main() {
  final enabled = liveApi.isNotEmpty;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    SessionStore.deviceId = 'live-test-device';
    if (enabled) {
      await AppConfig.setApiBaseUrl(liveApi);
      ApiClient.I.useClient(http.Client());
    }
  });

  final email = 'live-${DateTime.now().millisecondsSinceEpoch}@test.local';
  const password = 'Password@123';

  test('1. Đăng ký bắt buộc xác thực email bằng OTP rồi mới đăng nhập được', () async {
    final registered = await AuthRepository.register('Học Viên Live', email, password);
    expect(registered.verificationRequired, isTrue);
    expect(SessionStore.hasSession, isFalse);

    // Chưa xác thực: đăng nhập bị từ chối với mã EMAIL_NOT_VERIFIED
    await expectLater(() => AuthRepository.login(email, password),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'EMAIL_NOT_VERIFIED')));

    final wrong = (await otpFromLog(email, 'EMAIL_VERIFY')) == '000000' ? '111111' : '000000';
    await expectLater(() => AuthRepository.verifyEmail(email, wrong), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_OTP')));

    final otp = await otpFromLog(email, 'EMAIL_VERIFY');
    final result = await AuthRepository.verifyEmail(email, otp);
    expect(result.user.email, email);
    expect(result.user.emailVerified, isTrue);
    expect(SessionStore.hasSession, isTrue);
    expect(AppState.I.isSignedIn, isTrue);
  }, skip: !enabled);

  late List<Flashcard> cards;
  late String topicId;

  test('2. Nội dung seed đầy đủ: 18 chủ đề, 40 chủ điểm ngữ pháp, mỗi chủ đề có thẻ và bài kiểm tra', () async {
    final topics = await ContentRepository.topics(size: 100);
    expect(topics.totalElements, greaterThanOrEqualTo(18));
    final daily = topics.items.firstWhere((t) => t.title == 'Daily Life');
    expect(daily.totalWords, greaterThanOrEqualTo(25));
    topicId = daily.id;
    cards = await ContentRepository.flashcards(topicId);
    expect(cards.length, daily.totalWords);

    final grammar = await ContentRepository.grammarLessons(size: 100);
    expect(grammar.totalElements, greaterThanOrEqualTo(40));
    for (final topic in topics.items) {
      final quizzes = await ContentRepository.quizzesOfTopic(topic.id);
      expect(quizzes, isNotEmpty, reason: '${topic.title} chưa có bài kiểm tra');
      expect(quizzes.fold<int>(0, (s, q) => s + q.questionCount), greaterThanOrEqualTo(topic.totalWords), reason: '${topic.title}: mỗi từ phải có câu hỏi');
    }
    final detail = await ContentRepository.grammarDetail(grammar.items.first.id);
    expect(detail.content, isNotEmpty);
    expect(detail.examples.length, greaterThanOrEqualTo(3));
    expect(detail.quizId, isNotNull);
  }, skip: !enabled);

  test('3. Học thẻ: Know cộng XP từ server, từ được tính là đã học, Again không cộng', () async {
    final before = AppState.I.me;
    expect(before.currentXp, 0);
    final first = await StudyRepository.review(cards[0], know: true);
    expect(first.xpAwarded, 7); // +2 know, +5 từ mới học
    expect(first.isLearned, isTrue);
    expect(AppState.I.me.currentXp, 7);
    expect(AppState.I.me.totalWordsLearned, 1);
    expect(AppState.I.me.streakDays, 1);

    final again = await StudyRepository.review(cards[1], know: false);
    expect(again.xpAwarded, 0);
    expect(AppState.I.me.currentXp, 7);
    for (var i = 2; i < 6; i++) {
      await StudyRepository.review(cards[i], know: true);
    }
    expect(AppState.I.me.totalWordsLearned, 5);
    expect(AppState.I.me.currentXp, 7 + 4 * 7);
  }, skip: !enabled);

  test('4. Học lại bài đã xong không cộng thêm "bài học hoàn thành" hay XP', () async {
    final first = await StudyRepository.completeLesson(topicId: topicId, cardsReviewed: 6, durationSeconds: 120);
    expect(first.xpAwarded, 10);
    expect(AppState.I.me.completedLessons, 1);
    expect(first.todayDone, 1);

    final again = await StudyRepository.completeLesson(topicId: topicId, cardsReviewed: 6, durationSeconds: 90);
    expect(again.xpAwarded, 0);
    expect(AppState.I.me.completedLessons, 1);
    expect(again.todayDone, 1);

    // Tiến độ chủ đề phản ánh số từ đã học
    final topic = await ContentRepository.topic(topicId);
    expect(topic.learnedWords, 5);
    expect(topic.progress, closeTo(5 / topic.totalWords, 0.001));
    expect(topic.status, 'IN_PROGRESS');
  }, skip: !enabled);

  test('5. Bài kiểm tra từ vựng: server chấm điểm, cộng XP một lần mỗi ngày', () async {
    final quizzes = await ContentRepository.quizzesOfTopic(topicId);
    final wrong = await takeQuiz(quizzes.first.id, allCorrect: false);
    expect(wrong.correctAnswers, 0);
    expect(wrong.passed, isFalse);
    final xpBefore = AppState.I.me.currentXp;

    final perfect = await takeQuiz(quizzes.first.id, allCorrect: true);
    expect(perfect.scorePercent, 100);
    expect(perfect.passed, isTrue);
    expect(perfect.wrongQuestionIds, isEmpty);
    expect(AppState.I.me.currentXp, xpBefore + perfect.xpAwarded);

    // Làm lại cùng bài trong ngày: không cộng thêm
    final again = await takeQuiz(quizzes.first.id, allCorrect: true);
    expect(again.xpAwarded, 0);
  }, skip: !enabled);

  test('6. Ngữ pháp: đọc xong ghi nhận bài, qua bài kiểm tra thì hoàn thành chủ điểm', () async {
    final lessons = await ContentRepository.grammarLessons(size: 100);
    final lesson = lessons.items.firstWhere((l) => l.title == 'Present Simple');
    final detail = await ContentRepository.grammarDetail(lesson.id);
    final outcome = await StudyRepository.completeLesson(grammarLessonId: lesson.id, durationSeconds: 60);
    expect(outcome.xpAwarded, 10);
    expect(AppState.I.me.completedLessons, 2);

    final result = await takeQuiz(detail.quizId!, allCorrect: true);
    expect(result.passed, isTrue);
    expect(result.totalQuestions, 6);
    final after = await ContentRepository.grammarDetail(lesson.id);
    expect(after.summary.status, 'COMPLETED');
    expect(after.summary.progress, 1.0);

    final review = await StudyRepository.attemptReview(result.id);
    expect(review, hasLength(6));
    expect(review.every((r) => r.isCorrect), isTrue);
    expect(review.first.explanation, isNotEmpty);
  }, skip: !enabled);

  test('7. Thống kê: tuần, tháng, năm, tất cả và khoảng ngày tùy chọn', () async {
    final today = dateOnly(DateTime.now());
    final week = await ProgressRepository.statistics(StatsRange.week);
    expect(week.daily, hasLength(7));
    expect(week.daily.last.wordsLearned, 5);
    expect(week.accuracy, greaterThan(0));

    final month = await ProgressRepository.statistics(StatsRange.month);
    expect(month.daily, hasLength(30));
    final year = await ProgressRepository.statistics(StatsRange.year);
    expect(year.daily, hasLength(1));
    expect(year.wordsLearned, 5);
    final all = await ProgressRepository.statistics(StatsRange.all);
    expect(all.wordsLearned, 5);
    expect(all.from, today);

    final custom = await ProgressRepository.statistics(StatsRange.custom, from: today.subtract(const Duration(days: 9)), to: today);
    expect(custom.daily, hasLength(10));
    expect(custom.daily.last.wordsLearned, 5);
    final previous = await ProgressRepository.previousPeriod(week);
    expect(previous, isNotNull);
    expect(previous!.wordsLearned, 0);
  }, skip: !enabled);

  test('8. Từ đã lưu và ghi chú', () async {
    final card = cards[0];
    await StudyRepository.setBookmark(card, true);
    var saved = await ContentRepository.bookmarks();
    expect(saved.totalElements, 1);
    expect(saved.items.single.word, card.word);

    await StudyRepository.saveNote(card, 'mẹo nhớ: ghi chú thử');
    final fresh = (await ContentRepository.flashcards(topicId)).firstWhere((c) => c.id == card.id);
    expect(fresh.note, 'mẹo nhớ: ghi chú thử');
    expect(fresh.isBookmarked, isTrue);

    await StudyRepository.setBookmark(card, false);
    saved = await ContentRepository.bookmarks();
    expect(saved.totalElements, 0);
  }, skip: !enabled);

  test('9. Nhiệm vụ, cửa hàng, trang bị viền và bảng xếp hạng có slogan + viền', () async {
    final quests = await GameRepository.todayQuests();
    expect(quests.quests, isNotEmpty);
    final claimable = quests.quests.where((q) => q.isCompleted && !q.isClaimed).toList();
    if (claimable.isNotEmpty) {
      final xpBefore = AppState.I.me.currentXp;
      final xp = await GameRepository.claimQuest(claimable.first);
      expect(AppState.I.me.currentXp, xpBefore + xp);
    }

    final shop = await GameRepository.shopItems();
    final free = shop.firstWhere((s) => s.item.xpCost == 0 && s.item.isBorder);
    await GameRepository.purchase(free.item);
    final owned = AppState.I.inventory.firstWhere((i) => i.rewardItemId == free.item.id);
    await GameRepository.equip(owned.id);
    expect(AppState.I.equippedBorderColors, free.item.colors);

    await UserRepository.updateSlogan('Slogan từ test live');
    expect(AppState.I.me.slogan, 'Slogan từ test live');

    // limit riêng để không dính cache 60 giây của bảng xếp hạng ở server
    final board = await GameRepository.leaderboard('xp', limit: 10 + DateTime.now().second % 40 + 1);
    final me = board.items.firstWhere((e) => e.userId == AppState.I.me.id);
    expect(me.slogan, 'Slogan từ test live');
    expect(me.colors, free.item.colors);
    expect(board.myRank, isNotNull);
  }, skip: !enabled);

  test('10. Đổi mật khẩu cần OTP gửi qua email; quên mật khẩu bằng OTP', () async {
    await expectLater(
        () => UserRepository.changePassword(currentPassword: password, newPassword: 'NewPass@123', otp: '123456'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_OTP')));

    await UserRepository.requestChangePasswordOtp();
    final otp = await otpFromLog(email, 'CHANGE_PASSWORD');
    await UserRepository.changePassword(currentPassword: password, newPassword: 'NewPass@123', otp: otp);
    await AppState.I.signOut();
    expect(SessionStore.hasSession, isFalse);
    await AuthRepository.login(email, 'NewPass@123');

    await AuthRepository.forgotPassword(email);
    final resetOtp = await otpFromLog(email, 'PASSWORD_RESET');
    await AuthRepository.resetPassword(email, resetOtp, 'Reset@12345');
    await expectLater(() => AuthRepository.login(email, 'NewPass@123'), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS')));
    final back = await AuthRepository.login(email, 'Reset@12345');
    expect(back.user.email, email);
  }, skip: !enabled);

  test('11. Admin: tổng quan không đếm admin vào học viên, danh sách học viên không có admin, CRUD nội dung', () async {
    expect(adminEmail, isNotEmpty);
    await AppState.I.signOut();
    final login = await AuthRepository.login(adminEmail, adminPassword);
    expect(login.user.isAdmin, isTrue);

    final overview = await AdminRepository.overview();
    expect(overview.admins, greaterThanOrEqualTo(1));
    final students = await AdminRepository.users(role: 'USER', size: 100);
    expect(students.items.every((u) => u.role == 'USER'), isTrue);
    expect(overview.students, students.totalElements);
    expect(overview.topics, greaterThanOrEqualTo(18));
    expect(overview.grammarLessons, greaterThanOrEqualTo(40));
    expect(overview.recentStudents.any((s) => s.email == email), isTrue);

    final admins = await AdminRepository.users(role: 'ADMIN');
    expect(admins.items.every((u) => u.isAdmin), isTrue);

    // Bảng xếp hạng không có admin; admin không có hạng
    final board = await GameRepository.leaderboard('xp');
    expect(board.items.any((e) => e.userId == login.user.id), isFalse);
    expect(board.myRank, isNull);

    // CRUD chủ đề + từ vựng
    await AdminRepository.saveTopic(null, {'title': 'Live Test Topic', 'iconPath': '🧪', 'level': 'A1', 'estimatedMinutes': 5, 'isPublished': true});
    var topics = await AdminRepository.topics();
    final created = topics.firstWhere((t) => t.title == 'Live Test Topic');
    await AdminRepository.saveFlashcard(null, {
      'topicId': created.id,
      'word': 'laboratory',
      'partOfSpeech': 'n.',
      'pronunciation': '/ləˈbɒrətri/',
      'meaning': 'phòng thí nghiệm',
      'example': 'She works in a laboratory.',
      'exampleTranslation': 'Cô ấy làm việc trong phòng thí nghiệm.',
    });
    expect(await AdminRepository.flashcards(created.id), hasLength(1));
    await AdminRepository.deleteTopic(created.id);
    topics = await AdminRepository.topics();
    expect(topics.any((t) => t.id == created.id), isFalse);

    // Học viên không gọi được API admin
    await AppState.I.signOut();
    await AuthRepository.login(email, 'Reset@12345');
    await expectLater(() => AdminRepository.overview(), throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)));
  }, skip: !enabled);

  test('12. Mật khẩu sai báo đúng lỗi, token hết hạn tự làm mới', () async {
    await AppState.I.signOut();
    await expectLater(() => AuthRepository.login(email, 'sai-mat-khau'), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS')));
    await AuthRepository.login(email, 'Reset@12345');
    // Làm hỏng access token: lần gọi kế tiếp phải tự refresh rồi thành công
    SessionStore.accessToken = 'token-het-han';
    final me = await UserRepository_me();
    expect(me.email, email);
    expect(SessionStore.accessToken, isNot('token-het-han'));
  }, skip: !enabled);
}

Future<dynamic> UserRepository_me() async {
  await AppState.I.refreshUser();
  return AppState.I.me;
}
