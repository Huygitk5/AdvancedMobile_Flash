import 'package:drift/native.dart';
import 'package:flash/core/l10n.dart';
import 'package:flash/data/local/app_database.dart' show AppDatabase;
import 'package:flash/data/remote/apis/gamification_api.dart';
import 'package:flash/models/admin_models.dart';
import 'package:flash/models/daily_statistic_model.dart';
import 'package:flash/models/flashcard_model.dart';
import 'package:flash/models/grammar_model.dart';
import 'package:flash/models/leaderboard_model.dart';
import 'package:flash/models/quest_definition_model.dart';
import 'package:flash/models/quest_model.dart';
import 'package:flash/models/quiz_model.dart';
import 'package:flash/models/quiz_result_model.dart';
import 'package:flash/models/quiz_review_model.dart';
import 'package:flash/models/reward_item_model.dart';
import 'package:flash/models/topic_model.dart';
import 'package:flash/models/user_model.dart';
import 'package:flash/screens/profile/profile_screen.dart' show borderColorsOf;
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => AppLocale.language.value = 'vi');

  group('UserModel', () {
    test('đọc đủ trường của UserResponse', () {
      final user = UserModel.fromJson(userJson());
      expect(user.fullName, startsWith('Nguyễn'));
      expect(user.isAdmin, isFalse);
      expect(user.currentXp, 120);
      expect(user.displayXp, 120); // dựng từ API thì không có XP chờ đồng bộ
      expect(user.level, 'A2');
      expect(user.slogan, 'Học là phải vui');
      expect(user.totalWordsLearned, 42);
      expect(user.version, 2);
      expect(UserModel.fromJson(userJson(role: 'ADMIN')).isAdmin, isTrue);
    });

    test('hasPassword / emailVerified / createdAt', () {
      final user = UserModel.fromJson(userJson());
      expect(user.emailVerified, isTrue);
      expect(user.hasPassword, isTrue);
      expect(user.createdAt, DateTime.utc(2026, 9, 1, 8, 30));
      expect(user.createdAt!.isUtc, isTrue);

      // Tài khoản chỉ đăng nhập Google, chưa xác thực email, mốc giờ có múi giờ -> quy về UTC
      final google = UserModel.fromJson({
        ...userJson(),
        'hasPassword': false,
        'emailVerified': false,
        'createdAt': '2026-09-01T15:30:00+07:00',
      });
      expect(google.hasPassword, isFalse);
      expect(google.emailVerified, isFalse);
      expect(google.createdAt, DateTime.utc(2026, 9, 1, 8, 30));

      // createdAt sai định dạng không làm app lỗi
      expect(UserModel.fromJson({...userJson(), 'createdAt': 'không phải ngày'}).createdAt, isNull);
    });

    test('thiếu trường không làm app lỗi', () {
      final user = UserModel.fromJson({'id': 'x', 'fullName': 'A', 'email': 'a@b.c'});
      expect(user.level, 'A1');
      expect(user.role, 'USER');
      expect(user.currentXp, 0);
      expect(user.targetXp, 100);
      expect(user.status, 'ACTIVE');
      expect(user.slogan, '');
      expect(user.equippedBorderColors, isEmpty);
      // Mặc định: chưa xác thực email, có mật khẩu (để màn đổi mật khẩu hỏi mật khẩu hiện tại), chưa biết ngày tạo
      expect(user.emailVerified, isFalse);
      expect(user.hasPassword, isTrue);
      expect(user.createdAt, isNull);
    });

    test('kiểu dữ liệu lạ (số dạng chuỗi, null) dùng giá trị mặc định', () {
      final user = UserModel.fromJson({'id': 'x', 'currentXp': '12', 'streakDays': null, 'hasPassword': 'yes', 'level': 5});
      expect(user.currentXp, 0);
      expect(user.streakDays, 0);
      expect(user.hasPassword, isTrue);
      expect(user.level, 'A1');
      expect(user.fullName, '');
    });

    test('UserSnapshot của server cập nhật số liệu, giữ nguyên hồ sơ (ProfileDao)', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.profileDao.upsertFromUser(userJson(), 0);
      final before = (await db.profileDao.current())!;
      expect(before.currentXp, 120);

      await db.profileDao.applySnapshot({
        'currentXp': 127,
        'totalLifetimeXp': 567,
        'streakDays': 4,
        'longestStreak': 9,
        'totalWordsLearned': 43,
        'completedLessons': 7,
      });
      final updated = (await db.profileDao.current())!;
      expect(updated.currentXp, 127);
      expect(updated.totalWordsLearned, 43);
      expect(updated.streakDays, 4);
      expect(updated.slogan, before.slogan); // trường không có trong snapshot giữ nguyên
      expect(updated.fullName, before.fullName);

      await db.profileDao.applySnapshot(null); // response không kèm snapshot: không đổi gì
      expect((await db.profileDao.current())!.currentXp, 127);
    });
  });

  group('Nội dung', () {
    test('Topic, Grammar, Flashcard', () {
      final topic = Topic.fromJson(topicJson('t1', 'Daily Life', words: 28, progress: 0.5));
      expect(topic.totalWords, 28);
      expect(topic.progress, 0.5);
      expect(topic.status, 'IN_PROGRESS');
      expect(Topic.fromJson({'id': 't0'}).progress, 0); // 0 từ không chia cho 0

      final grammar = Grammar.fromJson(grammarJson('g1', 'Present Simple', progress: 1, status: 'COMPLETED'));
      expect(grammar.status, 'COMPLETED');
      expect(grammar.structure, 'S + V(s/es) + O');
      expect(grammar.estimatedMinutes, 12);

      final card = Flashcard.fromJson(flashcardJson('f1', 'apple'));
      expect(card.word, 'apple');
      expect(card.topicId, 't1');
      expect(card.example, 'This is a apple.');
      // JSON admin không mang trạng thái của user (ghi chú / bookmark đọc từ SQLite)
      expect(card.note, isNull);
      expect(card.hasNote, isFalse);
      expect(card.noteVersion, 0);
      expect(card.isBookmarked, isFalse);
    });

    test('Topic / Grammar thiếu trường dùng mặc định', () {
      final topic = Topic.fromJson({'id': 't1'});
      expect(topic.level, 'A1');
      expect(topic.status, 'NOT_STARTED');
      expect(topic.estimatedMinutes, 10);
      expect(topic.isPublished, isTrue);

      final grammar = Grammar.fromJson({'id': 'g1'});
      expect(grammar.iconName, 'menu_book');
      expect(grammar.status, 'NOT_STARTED');
      expect(grammar.bestScorePercent, isNull);
    });

    test('Grammar.statusLabel theo trạng thái và ngôn ngữ', () {
      expect(Grammar.fromJson(grammarJson('g', 'x', progress: 1, status: 'COMPLETED')).statusLabel, 'Đã học 100%');
      expect(Grammar.fromJson(grammarJson('g', 'x', progress: 0.5, status: 'IN_PROGRESS')).statusLabel, 'Đang học 50%');
      expect(Grammar.fromJson(grammarJson('g', 'x')).statusLabel, 'Chưa học 0%');
      AppLocale.language.value = 'en';
      expect(Grammar.fromJson(grammarJson('g', 'x', progress: 0.5, status: 'IN_PROGRESS')).statusLabel,
          trf('Đang học {p}%', {'p': 50}));
    });

    test('GrammarDetail', () {
      // Dạng phẳng như server trả: trường của chủ điểm cùng cấp với content / examples / quizId
      final detail = GrammarDetail.fromJson({
        ...grammarJson('g1', 'Present Simple'),
        'content': 'Dòng 1\nDòng 2',
        'usageNotes': 'Lưu ý',
        'quizId': 'q1',
        'examples': [
          {'id': 'e1', 'sentence': 'She goes to school.', 'translation': 'Cô ấy đi học.', 'highlight': 'goes'},
        ],
      });
      expect(detail.grammar.title, 'Present Simple');
      expect(detail.examples.single.highlight, 'goes');
      expect(detail.usageNotes, 'Lưu ý');
      expect(detail.quizId, 'q1');

      final bare = GrammarDetail.fromJson({'id': 'g2'});
      expect(bare.examples, isEmpty);
      expect(bare.quizId, isNull);
      expect(bare.content, isNull);
    });
  });

  group('Quiz', () {
    test('đề và câu hỏi', () {
      final quiz = Quiz.fromJson({
        'id': 'q1',
        'title': 'Daily Life - Bài kiểm tra 1',
        'quizType': 'TOPIC',
        'topicId': 't1',
        'passScorePercent': 70,
        'questionCount': 1,
        'timeLimitSeconds': 450,
      });
      expect(quiz.timeLimitSeconds, 450);
      expect(quiz.topicId, 't1');
      expect(quiz.questionCount, 1);

      final question = QuizQuestion.fromJson({
        'id': 'a',
        'quizId': 'q1',
        'questionText': 'Nghĩa của "dog"?',
        'options': ['mèo', 'chó', 'gà', 'vịt'],
        'correctAnswerIndex': 1,
        'explanation': 'dog = chó',
        'flashcardId': 'f1',
      });
      expect(question.options, hasLength(4));
      expect(question.correctAnswerIndex, 1);
      expect(question.flashcardId, 'f1');

      final defaults = Quiz.fromJson({'id': 'q2'});
      expect(defaults.passScorePercent, 70);
      expect(defaults.quizType, 'TOPIC');
      expect(defaults.timeLimitSeconds, isNull);
      final emptyQuestion = QuizQuestion.fromJson({'id': 'b'});
      expect(emptyQuestion.options, isEmpty);
      expect(emptyQuestion.explanation, '');
    });

    test('kết quả: đạt theo passScorePercent, XP null tới khi server chấm', () {
      QuizResult result(int score, {int pass = 70, int? xp}) => QuizResult(
            id: 'r',
            quizId: 'q1',
            totalQuestions: 10,
            correctAnswers: score ~/ 10,
            wrongAnswers: 10 - score ~/ 10,
            scorePercent: score,
            passScorePercent: pass,
            timeTakenSeconds: 95,
            xpAwarded: xp,
            submittedAt: DateTime.utc(2026, 10, 5),
          );
      expect(result(80, xp: 26).passed, isTrue);
      expect(result(80, xp: 26).xpAwarded, 26);
      expect(result(70).passed, isTrue); // đúng ngưỡng vẫn đạt
      expect(result(60).passed, isFalse);
      expect(result(80, pass: 90).passed, isFalse);
      expect(result(80).xpAwarded, isNull);
      expect(result(80).isSynced, isFalse);
    });

    test('xem lại: câu bỏ qua là sai', () {
      final review = QuizReviewItem.fromJson({'id': 'a', 'question': 'Q', 'options': ['1', '2', '3', '4'], 'correctIndex': 1, 'userIndex': -1});
      expect(review.isCorrect, isFalse);
      expect(review.userIndex, -1);
      expect(review.options, hasLength(4));

      final missing = QuizReviewItem.fromJson({'id': 'b'});
      expect(missing.userIndex, -1); // thiếu userIndex = bỏ qua
      expect(missing.isCorrect, isFalse);
      expect(missing.explanation, '');

      final right = QuizReviewItem.fromJson({'id': 'c', 'correctIndex': 2, 'userIndex': 2, 'isCorrect': true});
      expect(right.isCorrect, isTrue);
    });
  });

  group('Gamification', () {
    test('Quest: tiến độ và hoàn thành', () {
      Quest quest(int current, int target) => Quest(
            id: 'q',
            questDefinitionId: 'd',
            title: 'Học 20 từ',
            iconName: 'style',
            current: current,
            target: target,
            xp: 50,
            isClaimed: false,
            periodStart: '2026-10-05',
          );
      expect(quest(20, 20).isCompleted, isTrue);
      expect(quest(20, 20).progress, 1.0);
      expect(quest(25, 20).progress, 1.0); // không vượt 100%
      expect(quest(5, 20).progress, 0.25);
      expect(quest(5, 20).isCompleted, isFalse);
      expect(quest(0, 0).progress, 0); // không chia cho 0
    });

    test('RewardItem đọc ShopItemResponse (item unwrap cùng cấp)', () {
      final shop = RewardItem.fromJson({
        'id': 'i1',
        'code': 'BORDER_FIRE',
        'name': 'Hỏa thần',
        'itemType': 'BORDER',
        'xpCost': 500,
        'borderColors': [4294921551, 4294933061, 4294945088],
        'requiredRank': 0,
        'isUnlocked': true,
        'isEquipped': false,
        'inventoryId': 'inv1',
        'canAfford': true,
        'meetsRankRequirement': true,
      });
      expect(shop.isBorder, isTrue);
      expect(shop.isAvatar, isFalse);
      expect(shop.borderColors, hasLength(3));
      expect(borderColorsOf(shop.borderColors).first.toARGB32(), 4294921551);
      expect(shop.inventoryId, 'inv1');
      expect(shop.isUnlocked, isTrue);
      expect(shop.canAfford, isTrue);
      expect(shop.meetsRankRequirement, isTrue);

      // RewardItemResponse (không có trạng thái user): canAfford chưa biết = null
      final plain = RewardItem.fromJson({'id': 'i2', 'name': 'Avatar', 'itemType': 'AVATAR', 'xpCost': 100});
      expect(plain.isAvatar, isTrue);
      expect(plain.isUnlocked, isFalse);
      expect(plain.canAfford, isNull);
      expect(plain.meetsRankRequirement, isNull);
      expect(plain.borderColors, isEmpty);
      expect(borderColorsOf(plain.borderColors), isNotEmpty); // viền mặc định
      expect(plain.rankBoard, 'XP');
    });

    test('LeaderboardEntry: slogan và màu viền đang trang bị', () {
      final entry = LeaderboardEntry.fromJson({
        'rank': 1,
        'userId': 'u1',
        'fullName': 'An',
        'slogan': 'Học là vui',
        'equippedBorderColors': [4294921551, 4294933061],
        'score': 900,
      });
      expect(entry.slogan, 'Học là vui');
      expect(entry.equippedBorderColors, hasLength(2));
      expect(entry.score, 900);

      // Server bỏ field null: chưa đặt slogan / không trang bị viền
      final bare = LeaderboardEntry.fromJson({'rank': 3, 'userId': 'u3', 'fullName': 'Bình', 'score': 10});
      expect(bare.slogan, '');
      expect(bare.equippedBorderColors, isEmpty);
      expect(bare.avatarUrl, isNull);
      expect(LeaderboardEntry.fromJson({'rank': 4, 'userId': 'u4', 'slogan': null, 'score': 0}).slogan, '');

      expect(LeaderboardMe.fromJson({'rank': 4, 'score': 120}).rank, 4);
      expect(LeaderboardMe.fromJson({'score': 0}).rank, isNull); // admin không có hạng
    });

    test('GamificationApi.leaderboard đọc envelope của server', () async {
      final storage = await fakeStorage();
      final adapter = RoutedAdapter({
        '/v1/leaderboard/xp': (_) => leaderboardJson(),
        '/v1/leaderboard/streak': (_) => {'items': [], 'me': {'score': 0}},
      });
      final api = GamificationApi(fakeApiClient(storage.prefs, storage.store, adapter));

      final board = await api.leaderboard('xp');
      expect(board.items, hasLength(3));
      expect(board.items.first.slogan, 'Chúa tể ngữ pháp 👑');
      expect(board.items.first.equippedBorderColors, hasLength(3));
      expect(board.items.last.slogan, '');
      expect(board.me!.rank, 2);
      expect(board.fetchedAt, isNotNull);
      expect(adapter.requests.first.queryParameters['limit'], 10);

      final noRank = await api.leaderboard('streak');
      expect(noRank.items, isEmpty);
      expect(noRank.me!.rank, isNull);
    });

    test('QuestDefinition', () {
      final def = QuestDefinition.fromJson({
        'id': 'd1',
        'code': 'LEARN_20',
        'title': 'Học 20 từ',
        'questType': 'LEARN_WORDS',
        'frequency': 'WEEKLY',
        'targetValue': 20,
        'xpReward': 50,
        'iconName': 'style',
        'isActive': false,
        'sortOrder': 3,
      });
      expect(def.questType, 'LEARN_WORDS');
      expect(def.frequency, 'WEEKLY');
      expect(def.targetValue, 20);
      expect(def.isActive, isFalse);
      expect(QuestDefinition.questTypes, contains(def.questType));
      expect(QuestDefinition.frequencies, contains(def.frequency));

      final defaults = QuestDefinition.fromJson({'id': 'd2'});
      expect(defaults.questType, 'REVIEW_CARDS');
      expect(defaults.frequency, 'DAILY');
      expect(defaults.targetValue, 1);
      expect(defaults.iconName, 'stars');
      expect(defaults.isActive, isTrue);
      expect(defaults.description, isNull);
    });
  });

  group('AdminOverview', () {
    test('đọc AdminOverviewResponse', () {
      final o = AdminOverview.fromJson({
        'students': 120,
        'activeStudents': 80,
        'newStudentsLast7Days': 12,
        'admins': 2,
        'topics': 9,
        'flashcards': 270,
        'grammarLessons': 15,
        'quizzes': 24,
        'rewardItems': 8,
        'questDefinitions': 6,
        'recentStudents': [
          {'id': 'u1', 'fullName': 'Nguyễn Văn A', 'email': 'a@example.com', 'createdAt': '2026-10-04T03:00:00Z'},
          {'id': 'u2', 'fullName': 'Trần B', 'email': 'b@example.com'},
          'rác', // phần tử không phải object bị bỏ qua
        ],
      });
      expect(o.students, 120);
      expect(o.activeStudents, 80);
      expect(o.newStudentsLast7Days, 12);
      expect(o.admins, 2);
      expect(o.topics, 9);
      expect(o.flashcards, 270);
      expect(o.grammarLessons, 15);
      expect(o.quizzes, 24);
      expect(o.rewardItems, 8);
      expect(o.questDefinitions, 6);
      expect(o.recentStudents, hasLength(2));
      expect(o.recentStudents.first.createdAt, DateTime.utc(2026, 10, 4, 3));
      expect(o.recentStudents.last.createdAt, isNull);
      expect(o.recentStudents.last.email, 'b@example.com');
    });

    test('thiếu trường = 0, không có học viên mới', () {
      final o = AdminOverview.fromJson({});
      expect(o.students, 0);
      expect(o.questDefinitions, 0);
      expect(o.recentStudents, isEmpty);
    });
  });

  group('Statistics', () {
    final today = DateTime(2026, 10, 5, 15, 30);
    DailyStatistic day(int y, int m, int d, {int words = 1, int correct = 0, int total = 0}) =>
        DailyStatistic(date: DateTime(y, m, d), wordsLearned: words, correctAnswers: correct, totalAnswers: total);

    // Mọi ngày có dữ liệu, tăng dần (như StatsDao.watchAll)
    final all = [
      day(2025, 10, 1, words: 100), // quá 365 ngày
      day(2026, 8, 10, words: 50), // trong Năm, thuộc kỳ trước của Tháng
      day(2026, 9, 10, words: 20), // trong Tháng
      day(2026, 9, 28, words: 7, correct: 1, total: 2), // ngay trước Tuần
      day(2026, 9, 29, words: 3, correct: 3, total: 4), // ngày đầu của Tuần
      day(2026, 10, 5, words: 9, correct: 8, total: 10), // hôm nay
      day(2026, 10, 6, words: 1000), // tương lai (lệch giờ máy): không tính
    ];
    List<DateTime> dates(Statistics s) => s.daily.map((d) => d.date).toList();

    test('WEEK: 7 ngày gồm hôm nay', () {
      final s = Statistics.of(StatsRange.week, all, today: today);
      expect(s.range, 'WEEK');
      expect(s.from, DateTime(2026, 9, 29));
      expect(s.to, DateTime(2026, 10, 5)); // bỏ phần giờ
      expect(dates(s), [DateTime(2026, 9, 29), DateTime(2026, 10, 5)]);
      expect(s.wordsLearned, 12);
      expect(s.correctAnswers, 11);
      expect(s.totalAnswers, 14);
      expect(s.accuracy, closeTo(11 / 14, 1e-9));
    });

    test('MONTH: 30 ngày', () {
      final s = Statistics.of(StatsRange.month, all, today: today);
      expect(s.range, 'MONTH');
      expect(s.from, DateTime(2026, 9, 6));
      expect(dates(s), [DateTime(2026, 9, 10), DateTime(2026, 9, 28), DateTime(2026, 9, 29), DateTime(2026, 10, 5)]);
      expect(s.wordsLearned, 39);
    });

    test('YEAR: 365 ngày', () {
      final s = Statistics.of(StatsRange.year, all, today: today);
      expect(s.range, 'YEAR');
      expect(s.from, DateTime(2025, 10, 6));
      expect(s.daily.first.date, DateTime(2026, 8, 10));
      expect(s.daily, hasLength(5));
      expect(s.wordsLearned, 89);
    });

    test('ALL: từ ngày học đầu tiên; chưa học gì thì from = to = hôm nay', () {
      final s = Statistics.of(StatsRange.all, all, today: today);
      expect(s.range, 'ALL');
      expect(s.from, DateTime(2025, 10, 1));
      expect(s.to, DateTime(2026, 10, 5));
      expect(s.daily, hasLength(6)); // bỏ ngày tương lai
      expect(s.wordsLearned, 189);

      final empty = Statistics.of(StatsRange.all, const [], today: today);
      expect(empty.from, DateTime(2026, 10, 5));
      expect(empty.to, DateTime(2026, 10, 5));
      expect(empty.daily, isEmpty);
      expect(empty.wordsLearned, 0);
      expect(empty.accuracy, isNull); // chưa làm câu nào
    });

    test('CUSTOM: gồm cả hai đầu, bỏ phần giờ', () {
      final s = Statistics.of(StatsRange.custom, all,
          today: today, customFrom: DateTime(2026, 9, 28, 23, 59), customTo: DateTime(2026, 9, 29, 0, 1));
      expect(s.range, 'CUSTOM');
      expect(s.from, DateTime(2026, 9, 28));
      expect(s.to, DateTime(2026, 9, 29));
      expect(dates(s), [DateTime(2026, 9, 28), DateTime(2026, 9, 29)]);
      expect(s.accuracy, closeTo(4 / 6, 1e-9));

      final single = Statistics.of(StatsRange.custom, all, today: today, customFrom: DateTime(2026, 9, 10), customTo: DateTime(2026, 9, 10));
      expect(single.wordsLearned, 20);
      final none = Statistics.of(StatsRange.custom, all, today: today, customFrom: DateTime(2026, 9, 11), customTo: DateTime(2026, 9, 27));
      expect(none.daily, isEmpty);
    });

    test('previous: kỳ liền trước cùng độ dài', () {
      final week = Statistics.of(StatsRange.week, all, today: today).previous(all)!;
      expect(week.from, DateTime(2026, 9, 22));
      expect(week.to, DateTime(2026, 9, 28));
      expect(dates(week), [DateTime(2026, 9, 28)]);
      expect(week.wordsLearned, 7);

      final month = Statistics.of(StatsRange.month, all, today: today).previous(all)!;
      expect(month.from, DateTime(2026, 8, 7));
      expect(month.to, DateTime(2026, 9, 5));
      expect(month.to.difference(month.from).inDays + 1, 30);
      expect(month.wordsLearned, 50);

      final custom = Statistics.of(StatsRange.custom, all,
              today: today, customFrom: DateTime(2026, 9, 29), customTo: DateTime(2026, 10, 1))
          .previous(all)!;
      expect(custom.from, DateTime(2026, 9, 26));
      expect(custom.to, DateTime(2026, 9, 28));
      expect(custom.wordsLearned, 7);
    });

    test('previous: null với YEAR / ALL', () {
      expect(Statistics.of(StatsRange.year, all, today: today).previous(all), isNull);
      expect(Statistics.of(StatsRange.all, all, today: today).previous(all), isNull);
    });

    test('DailyStatisticResponse của server -> daily_statistics -> Statistics', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.statsDao.applyServer({
        'id': 'ds1',
        'date': '2026-10-05',
        'wordsLearned': 9,
        'cardsReviewed': 12,
        'xpGained': 70,
        'lessonsCompleted': 1,
        'quizzesCompleted': 1,
        'correctAnswers': 8,
        'totalAnswers': 10,
        'studySeconds': 300,
      }, 0);
      await db.statsDao.applyServer({'date': '2026-10-01'}, 0); // thiếu trường = 0

      final stats = Statistics.of(StatsRange.week, await db.statsDao.watchAll().first, today: today);
      expect(stats.from, DateTime(2026, 9, 29));
      expect(stats.daily, hasLength(2));
      final last = stats.daily.last;
      expect(last.date, DateTime(2026, 10, 5));
      expect(last.wordsLearned, 9);
      expect(last.cardsReviewed, 12);
      expect(last.studySeconds, 300);
      expect(stats.daily.first.wordsLearned, 0);
      expect(stats.accuracy, 0.8);
      expect(stats.xpGained, 70);
    });
  });
}
