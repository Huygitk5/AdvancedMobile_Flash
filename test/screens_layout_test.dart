import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flash/core/clock.dart';
import 'package:flash/core/l10n.dart';
import 'package:flash/core/theme.dart';
import 'package:flash/data/local/app_database.dart' show AppDatabase;
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';
import 'package:flash/providers/providers.dart';
import 'package:flash/screens/auth/login_screen.dart';
import 'package:flash/screens/auth/register_screen.dart';
import 'package:flash/screens/challenge/challenge_screen.dart';
import 'package:flash/screens/flashcard/flashcard_screen.dart';
import 'package:flash/screens/grammar/grammar_detail_screen.dart';
import 'package:flash/screens/home/home_screen.dart';
import 'package:flash/screens/leaderboard/leaderboard_screen.dart';
import 'package:flash/screens/main/main_screen.dart';
import 'package:flash/screens/profile/profile_screen.dart';
import 'package:flash/screens/profile/saved_words_screen.dart';
import 'package:flash/screens/profile/shop_screen.dart';
import 'package:flash/screens/progress/progress_screen.dart';
import 'package:flash/screens/quiz/quiz_screen.dart';
import 'package:flash/screens/splash/welcome_screen.dart';
import 'package:flash/screens/vocabulary/topic_screen.dart';
import 'package:flash/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

/// "Hôm nay" của mọi test: 10 giờ sáng (trước giờ nhắc học 20:00 nên ReminderDialog không tự bật).
final today = DateTime(2026, 10, 5, 10);

int _ms(DateTime d) => d.toUtc().millisecondsSinceEpoch;
String _iso(DateTime d) => d.toUtc().toIso8601String();

/// Nội dung như `/v1/sync/content` trả về.
Map<String, dynamic> contentPayload() => {
      'topics': [
        {'id': 't1', 'title': 'Daily Life', 'iconPath': '☀️', 'level': 'A1', 'totalWords': 29, 'estimatedMinutes': 8, 'sortOrder': 1},
        {
          'id': 't2',
          'title': 'Travel and Transportation Around The World',
          'iconPath': '✈️',
          'level': 'A2',
          'totalWords': 28,
          'coverColor': 4290502395,
          'sortOrder': 2,
        },
      ],
      'flashcards': [
        {
          'id': 'f1',
          'topicId': 't1',
          'word': 'apple',
          'partOfSpeech': 'n.',
          'pronunciation': '/ˈæp.əl/',
          'meaning': 'quả táo',
          'example': 'I eat an apple every single morning before going to work.',
          'exampleTranslation': 'Tôi ăn một quả táo mỗi sáng trước khi đi làm.',
          'sortOrder': 1,
        },
        {
          'id': 'f2',
          'topicId': 't1',
          'word': 'extraordinarily',
          'partOfSpeech': 'adv.',
          'pronunciation': '/ɪkˌstrɔː.dɪnˈer.əl.i/',
          'meaning': 'một cách phi thường, khác thường đến mức đáng kinh ngạc',
          'sortOrder': 2,
        },
        {'id': 'f3', 'topicId': 't2', 'word': 'ticket', 'partOfSpeech': 'n.', 'pronunciation': '/ˈtɪk.ɪt/', 'meaning': 'vé', 'sortOrder': 1},
      ],
      'grammarLessons': [
        {
          'id': 'g1',
          'title': 'Present Simple',
          'description': 'Thì hiện tại đơn',
          'structure': 'S + V(s/es) + O',
          'content': 'Thì hiện tại đơn dùng để nói về thói quen.\nVới chủ ngữ ngôi thứ ba số ít, động từ thêm -s/-es.',
          'usageNotes': 'Dấu hiệu: always, usually.\nSau does động từ ở dạng nguyên mẫu.',
          'iconName': 'account_tree',
          'level': 'A1',
          'estimatedMinutes': 12,
          'sortOrder': 1,
        },
        {'id': 'g2', 'title': 'Present Perfect Continuous', 'structure': 'S + have/has been + V-ing', 'iconName': 'history', 'level': 'B1', 'sortOrder': 2},
        {'id': 'g3', 'title': 'Inversion with Negative Adverbs', 'structure': 'Never + aux + S + V', 'iconName': 'swap_horiz', 'level': 'C1', 'sortOrder': 3},
      ],
      'grammarExamples': [
        {'id': 'e1', 'grammarLessonId': 'g1', 'sentence': 'She goes to school every day.', 'translation': 'Cô ấy đi học mỗi ngày.', 'highlight': 'goes', 'sortOrder': 1},
        {'id': 'e2', 'grammarLessonId': 'g1', 'sentence': 'No highlight here.', 'translation': 'Không tô đậm.', 'highlight': '', 'sortOrder': 2},
      ],
      'quizzes': [
        {'id': 'qz1', 'title': 'Present Simple - Kiểm tra', 'quizType': 'GRAMMAR', 'grammarLessonId': 'g1', 'passScorePercent': 70},
        {'id': 'qt1', 'title': 'Daily Life - Bài kiểm tra 1', 'quizType': 'TOPIC', 'topicId': 't1', 'passScorePercent': 70, 'timeLimitSeconds': 450},
      ],
      'quizQuestions': [
        {'id': 'a', 'quizId': 'qz1', 'questionText': 'She ______ to school every day.', 'options': ['goes', 'go', 'going', 'went'], 'correctOptionIndex': 0, 'explanation': 'ngôi thứ ba', 'sortOrder': 1},
        {'id': 'b', 'quizId': 'qz1', 'questionText': 'They ______ football on Sundays.', 'options': ['plays', 'play', 'playing', 'played'], 'correctOptionIndex': 1, 'explanation': 'số nhiều', 'sortOrder': 2},
        {'id': 'c', 'quizId': 'qt1', 'questionText': 'Nghĩa của "apple"?', 'options': ['quả táo', 'quả cam', 'quả chuối', 'quả nho'], 'correctOptionIndex': 0, 'flashcardId': 'f1', 'sortOrder': 1},
      ],
      'questDefinitions': [
        {'id': 'd1', 'code': 'LEARN_20', 'title': 'Học 20 Flashcard mới', 'questType': 'LEARN_WORDS', 'frequency': 'DAILY', 'targetValue': 20, 'xpReward': 50, 'iconName': 'style', 'sortOrder': 1},
        {'id': 'd2', 'code': 'STREAK', 'title': 'Duy trì Streak', 'questType': 'KEEP_STREAK', 'frequency': 'DAILY', 'targetValue': 1, 'xpReward': 20, 'iconName': 'local_fire_department', 'sortOrder': 2},
        {'id': 'd3', 'code': 'PERFECT', 'title': 'Đạt 100% 1 bài kiểm tra', 'questType': 'PERFECT_QUIZ', 'frequency': 'DAILY', 'targetValue': 1, 'xpReward': 100, 'iconName': 'fact_check', 'sortOrder': 3},
      ],
      'rewardItems': [
        {'id': 'i1', 'code': 'B1', 'name': 'Tân binh', 'itemType': 'BORDER', 'xpCost': 0, 'borderColors': [4293060848, 4291548641], 'sortOrder': 1},
        {
          'id': 'i2',
          'code': 'B2',
          'name': 'Vua Trò Chơi Huyền Thoại',
          'itemType': 'BORDER',
          'xpCost': 3000,
          'borderColors': [4294618388, 4294960527],
          'requiredRank': 3,
          'sortOrder': 2,
        },
      ],
    };

/// `GET /v1/shop/items` (online): trạng thái mua được / đủ hạng của từng vật phẩm.
List<Map<String, dynamic>> shopItemsJson() => [
      {
        ...contentPayload()['rewardItems'][0] as Map<String, dynamic>,
        'isUnlocked': true,
        'isEquipped': true,
        'inventoryId': 'inv1',
        'canAfford': true,
        'meetsRankRequirement': true,
      },
      {
        ...contentPayload()['rewardItems'][1] as Map<String, dynamic>,
        'isUnlocked': false,
        'isEquipped': false,
        'canAfford': false,
        'meetsRankRequirement': false,
      },
    ];

/// Nội dung + dữ liệu của học viên đang đăng nhập, ghi bằng chính các DAO mà PullService dùng.
Future<void> seedStudent(AppDatabase db) async {
  final now = _ms(today);
  await db.transaction(() => db.contentDao.upsertContent(contentPayload()));
  await db.profileDao.upsertFromUser(userJson(), now);
  await db.shopDao.applyInventory({'id': 'inv1', 'rewardItemId': 'i1', 'isEquipped': true}, nowMs: now);

  await db.progressDao.applyServerTopic(
      {'topicId': 't1', 'learnedWords': 12, 'status': 'IN_PROGRESS', 'lastStudiedAt': _iso(today.subtract(const Duration(days: 1)))}, now);
  await db.progressDao.applyServerGrammar({'grammarLessonId': 'g1', 'progress': 1.0, 'status': 'COMPLETED', 'bestScorePercent': 100}, now);
  await db.progressDao.applyServerGrammar({'grammarLessonId': 'g2', 'progress': 0.5, 'status': 'IN_PROGRESS'}, now);

  await db.bookmarkDao.applyServer({'flashcardId': 'f1', 'isBookmarked': true, 'createdAt': _iso(today)}, nowMs: now);
  await db.bookmarkDao.applyServer({'flashcardId': 'f2', 'isBookmarked': true, 'createdAt': _iso(today)}, nowMs: now);
  await db.noteDao.applyServer(
      {'flashcardId': 'f1', 'noteId': 'n1', 'content': 'Ghi chú khá dài để thử xem thẻ có bị tràn khi hiện ghi chú hay không.', 'version': 1},
      nowMs: now);

  // Nhiệm vụ hôm nay đã có ở local nên Home / Thử thách không gọi /v1/quests/today.
  const period = '2026-10-05';
  await db.questDao.applyServer(
      {'id': 'uq1', 'questDefinitionId': 'd1', 'periodStart': period, 'currentValue': 20, 'targetValue': 20, 'xpReward': 50, 'isClaimed': false}, now);
  await db.questDao.applyServer(
      {'id': 'uq2', 'questDefinitionId': 'd2', 'periodStart': period, 'currentValue': 1, 'targetValue': 1, 'xpReward': 20, 'isClaimed': true}, now);
  await db.questDao.applyServer(
      {'id': 'uq3', 'questDefinitionId': 'd3', 'periodStart': period, 'currentValue': 0, 'targetValue': 1, 'xpReward': 100, 'isClaimed': false}, now);

  // Tuần này 42 từ, độ chính xác (9 + 8) / (10 + 10) = 85%; tuần trước 15 từ.
  // Tháng: 57 từ, Năm: 157 từ, Tất cả: 162 từ.
  await db.statsDao.applyServer({'date': '2025-01-10', 'wordsLearned': 5}, now);
  await db.statsDao.applyServer({'date': '2026-03-01', 'wordsLearned': 100}, now);
  await db.statsDao.applyServer({'date': '2026-09-25', 'wordsLearned': 15}, now);
  await db.statsDao.applyServer({'date': '2026-10-01', 'wordsLearned': 12, 'correctAnswers': 9, 'totalAnswers': 10, 'xpGained': 40}, now);
  await db.statsDao.applyServer(
      {'date': '2026-10-05', 'wordsLearned': 30, 'cardsReviewed': 12, 'lessonsCompleted': 3, 'correctAnswers': 8, 'totalAnswers': 10}, now);

  // Hôm nay đã xong 3 bài khác nhau (học lại t1 không tính thêm) -> "3/5 bài".
  for (final (id, type, topic, grammar, hour) in [
    ('lc1', 'TOPIC', 't1', null, 8),
    ('lc2', 'TOPIC', 't1', null, 8),
    ('lc3', 'TOPIC', 't2', null, 9),
    ('lc4', 'GRAMMAR', null, 'g1', 9),
  ]) {
    await db.lessonDao.insert(
        id: id, lessonType: type, topicId: topic, grammarLessonId: grammar, completedAtMs: _ms(DateTime(2026, 10, 5, hour)));
  }
}

/// Server giả: chỉ các API mà màn hình học viên gọi khi online; còn lại = mất mạng.
Map<String, RouteHandler> studentRoutes() => {
      '/v1/leaderboard/xp': (_) => leaderboardJson(),
      '/v1/leaderboard/streak': (_) => leaderboardJson(),
      '/v1/shop/items': (_) => shopItemsJson(),
    };

class ScreenEnv {
  late AppDatabase db;
  late AppPrefs prefs;
  late SecureStore store;
  late RoutedAdapter adapter;
}

/// Dựng màn hình trên "điện thoại" có kích thước và cỡ chữ cho trước.
Future<void> pumpScreen(
  WidgetTester tester,
  ScreenEnv env,
  Widget screen, {
  Size size = const Size(320, 640),
  double textScale = 1.15,
  bool dark = false,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    // Mỗi lần dựng là một container mới (giống mở app), không giữ state của màn trước.
    key: UniqueKey(),
    overrides: [
      appPrefsProvider.overrideWithValue(env.prefs),
      dbProvider.overrideWithValue(env.db),
      secureStoreProvider.overrideWithValue(env.store),
      apiClientProvider.overrideWithValue(fakeApiClient(env.prefs, env.store, env.adapter)),
    ],
    // Không tự thử lại provider lỗi (tránh Timer còn treo khi test kết thúc).
    retry: (_, _) => null,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: AppLocale.locale,
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
      home: screen,
    ),
  ));
  await settle(tester);
}

/// Cho các truy vấn SQLite / API giả hoàn tất và dựng lại giao diện (không dùng pumpAndSettle vì có
/// spinner chạy mãi khi đang tải).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Gỡ cây widget để huỷ stream của drift và các provider trước khi đóng DB.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final env = ScreenEnv();

  setUp(() async {
    Clock.override(() => today);
    final storage = await fakeStorage();
    env
      ..prefs = storage.prefs
      ..store = storage.store
      ..adapter = RoutedAdapter(studentRoutes())
      ..db = AppDatabase(NativeDatabase.memory());
    await seedStudent(env.db);
  });

  tearDown(() async {
    await env.db.close();
    Clock.override(null);
    AppLocale.language.value = 'vi';
  });

  const sizes = <String, Size>{'320x568 (máy nhỏ)': Size(320, 568), '360x640': Size(360, 640), '411x891': Size(411, 891)};

  for (final lang in ['vi', 'en']) {
    for (final entry in sizes.entries) {
      group('[$lang] không tràn layout trên ${entry.key}, chữ phóng 1.15x', () {
        setUp(() => AppLocale.language.value = lang);

        testWidgets('Trang chủ (tiến độ hôm nay, danh mục học tập, bài gợi ý, thử thách)', (tester) async {
          await pumpScreen(tester, env, const HomeScreen(), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text(tr('Danh mục học tập')), findsOneWidget);
          expect(find.text(tr('Từ vựng')), findsOneWidget);
          expect(find.text(tr('Ngữ pháp')), findsWidgets); // thẻ danh mục + nhãn của bài ngữ pháp gợi ý
          // Số liệu từ SQLite: 3 bài khác nhau / mục tiêu 5, 57 từ (29 + 28) trong 2 chủ đề, 3 chủ điểm
          expect(find.textContaining(trf('{done}/{goal} bài', {'done': 3, 'goal': 5})), findsOneWidget);
          expect(find.text(trf('{w} từ • {t} chủ đề', {'w': 57, 't': 2})), findsOneWidget);
          expect(find.text(trf('{n} chủ điểm', {'n': 3})), findsOneWidget);
          // Header gọn: không 👋, không chuông, không câu chào
          expect(find.textContaining('👋'), findsNothing);
          expect(find.byIcon(Icons.notifications_none), findsNothing);
          expect(find.textContaining('ngày tuyệt vời'), findsNothing);
          expect(find.text(tr('Tiếp tục học')), findsOneWidget);
          expect(find.text('Daily Life'), findsWidgets);
          await unmount(tester);
        });

        testWidgets('Học tập: từ vựng và ngữ pháp', (tester) async {
          await pumpScreen(tester, env, const TopicScreen(), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text('Daily Life'), findsOneWidget);
          expect(find.text('Travel and Transportation Around The World'), findsOneWidget);
          await tester.tap(find.text(tr('Ngữ pháp')));
          await settle(tester);
          expect(tester.takeException(), isNull);
          expect(find.text('Present Simple'), findsOneWidget);
          expect(find.text(trf('Đã học {p}%', {'p': 100})), findsOneWidget);
          expect(find.text(trf('Đang học {p}%', {'p': 50})), findsOneWidget);
          expect(find.text(trf('Chưa học {p}%', {'p': 0})), findsOneWidget);
          await unmount(tester);
        });

        testWidgets('Tiến độ: biểu đồ và các bộ lọc', (tester) async {
          await pumpScreen(tester, env, const ProgressScreen(), size: entry.value);
          expect(tester.takeException(), isNull);
          for (final label in ['Tuần', 'Tháng', 'Năm', 'Tất cả', 'Tùy chọn']) {
            expect(find.text(tr(label)), findsOneWidget, reason: 'thiếu bộ lọc $label');
          }
          expect(find.text(tr('Số từ đã học')), findsOneWidget);
          expect(find.text(tr('Bài học hoàn thành')), findsOneWidget);
          expect(find.text('42'), findsOneWidget); // 12 + 30 từ trong tuần
          expect(find.text(trf('+{n} từ so với kỳ trước', {'n': 27})), findsOneWidget);
          expect(find.text('85%'), findsOneWidget);

          // Đổi bộ lọc vẫn không tràn
          for (final (label, total) in [('Tháng', '57'), ('Năm', '157'), ('Tất cả', '162')]) {
            final chip = find.text(tr(label));
            await tester.ensureVisible(chip); // thanh bộ lọc cuộn ngang trên máy hẹp
            await tester.pump();
            await tester.tap(chip);
            await settle(tester);
            expect(tester.takeException(), isNull, reason: 'bộ lọc $label');
            expect(find.text(total), findsOneWidget, reason: 'tổng số từ của bộ lọc $label');
          }
          await unmount(tester);
        });

        testWidgets('Bảng xếp hạng: avatar có viền, hiện slogan', (tester) async {
          await pumpScreen(tester, env, const LeaderboardScreen(), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text('Chúa tể ngữ pháp 👑'), findsWidgets);
          expect(find.text('Học là phải vui'), findsWidgets);
          expect(find.text(tr('Chưa có câu châm ngôn')), findsWidgets); // người dùng chưa đặt slogan
          expect(find.text(tr('Hạng của bạn')), findsOneWidget);
          expect(find.byType(UserAvatar), findsWidgets);
          expect(env.adapter.paths, contains('/v1/leaderboard/xp'));
          await unmount(tester);
        });

        testWidgets('Thẻ từ vựng, thử thách, cửa hàng, từ đã lưu', (tester) async {
          final screens = <Widget, String>{
            const FlashcardScreen(topicId: 't1', topicTitle: 'Daily Life'): 'apple',
            const ChallengeScreen(): 'Học 20 Flashcard mới',
            const ShopScreen(): 'Vua Trò Chơi Huyền Thoại',
            const SavedWordsScreen(): 'extraordinarily',
          };
          for (final MapEntry(key: screen, value: text) in screens.entries) {
            await pumpScreen(tester, env, screen, size: entry.value);
            expect(tester.takeException(), isNull, reason: '${screen.runtimeType} bị tràn layout');
            expect(find.textContaining(text), findsWidgets, reason: '${screen.runtimeType} thiếu "$text"');
          }
          await unmount(tester);
        });

        testWidgets('Hồ sơ cá nhân (offline: chưa có hạng)', (tester) async {
          env.adapter.routes.clear();
          await pumpScreen(tester, env, const ProfileScreen(), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text('Học là phải vui'), findsOneWidget);
          expect(find.text(tr('Kho đồ')), findsOneWidget);
          await unmount(tester);
        });

        testWidgets('Hồ sơ cá nhân (online: có huy hiệu hạng)', (tester) async {
          await pumpScreen(tester, env, const ProfileScreen(), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text(trf('Top {n} Point', {'n': 2})), findsOneWidget);
          await unmount(tester);
        });

        testWidgets('Thẻ từ vựng: lật thẻ và thẻ có nghĩa dài', (tester) async {
          await pumpScreen(tester, env, const FlashcardScreen(topicId: 't1', topicTitle: 'Daily Life'), size: entry.value);
          await tester.tap(find.text('apple'));
          await settle(tester);
          expect(tester.takeException(), isNull, reason: 'mặt sau của thẻ');
          await unmount(tester);
        });

        testWidgets('Ngữ pháp chi tiết và làm bài kiểm tra', (tester) async {
          await pumpScreen(tester, env, const GrammarDetailScreen(grammarId: 'g1', title: 'Present Simple'), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text(tr('Cấu trúc')), findsOneWidget);
          expect(find.text(tr('Tiếp theo (Kiểm tra)')), findsOneWidget);
          await pumpScreen(tester, env, const QuizScreen(quizId: 'qz1'), size: entry.value);
          expect(tester.takeException(), isNull);
          expect(find.text('goes'), findsOneWidget);
          expect(find.text(tr('Chọn đáp án đúng nhất.')), findsOneWidget);
          await unmount(tester);
        });

        testWidgets('Chào mừng, đăng nhập, đăng ký', (tester) async {
          final screens = <Widget, String>{
            const WelcomeScreen(): tr('Đăng ký'),
            const LoginScreen(): tr('Quên mật khẩu?'),
            const RegisterScreen(): tr('Tạo tài khoản'),
          };
          for (final MapEntry(key: screen, value: text) in screens.entries) {
            await pumpScreen(tester, env, screen, size: entry.value);
            expect(tester.takeException(), isNull, reason: '${screen.runtimeType} bị tràn layout');
            expect(find.text(text), findsWidgets, reason: '${screen.runtimeType} thiếu "$text"');
          }
          await unmount(tester);
        });
      });
    }
  }

  testWidgets('Offline: bảng xếp hạng và cửa hàng không lỗi khi không có mạng', (tester) async {
    env.adapter.routes.clear();
    await pumpScreen(tester, env, const LeaderboardScreen());
    expect(tester.takeException(), isNull);
    expect(find.text(tr('Cần kết nối mạng để xem bảng xếp hạng.')), findsOneWidget);
    await pumpScreen(tester, env, const ShopScreen());
    expect(tester.takeException(), isNull);
    expect(find.text(tr('Đang offline: cần kết nối mạng để mua. Bạn vẫn có thể trang bị đồ đã sở hữu.')), findsOneWidget);
    expect(find.text('Tân binh'), findsOneWidget); // danh mục vẫn đọc từ SQLite
    await unmount(tester);
  });

  testWidgets('Trang chủ: đọc thống kê hôm nay cho ReminderDialog không ném lỗi', (tester) async {
    await pumpScreen(tester, env, const HomeScreen());
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('Chế độ tối không bị tràn layout', (tester) async {
    env.adapter.routes.clear(); // offline: ProfileScreen không có huy hiệu hạng
    for (final screen in <Widget>[const HomeScreen(), const ProgressScreen(), const ProfileScreen()]) {
      await pumpScreen(tester, env, screen, dark: true);
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType} (dark)');
    }
    await unmount(tester);
  });

  testWidgets('Thanh điều hướng: chỉ icon, tab đang chọn mới hiện tên, "Học" đổi thành "Học tập"', (tester) async {
    await pumpScreen(tester, env, const MainScreen(), size: const Size(360, 640), textScale: 1.0);
    expect(tester.takeException(), isNull);

    double opacityOf(String label) {
      final element = find.text(label).evaluate().last;
      var opacity = 1.0;
      element.visitAncestorElements((ancestor) {
        final widget = ancestor.widget;
        if (widget is Opacity) {
          opacity = widget.opacity;
          return false;
        }
        return true;
      });
      return opacity;
    }

    expect(find.text('Học'), findsNothing); // đã đổi tên
    expect(opacityOf('Trang chủ'), greaterThan(0.99)); // tab đang chọn hiện tên
    expect(opacityOf('Học tập'), lessThan(0.01)); // tab khác chỉ còn icon
    expect(opacityOf('Tiến độ'), lessThan(0.01));

    await tester.tap(find.byIcon(Icons.menu_book).last);
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(opacityOf('Học tập'), greaterThan(0.99));
    expect(opacityOf('Trang chủ'), lessThan(0.01));

    // Mở lần lượt mọi tab
    for (final icon in [Icons.bar_chart, Icons.emoji_events_outlined, Icons.person_outline]) {
      await tester.tap(find.byIcon(icon).last);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'tab $icon');
    }
    await unmount(tester);
  });

  testWidgets('Tiêu đề màn hình căn giữa', (tester) async {
    await pumpScreen(tester, env, const ProgressScreen(), size: const Size(360, 640), textScale: 1.0);
    expect(tester.getCenter(find.text('Tiến độ').first).dx, closeTo(180, 2));
    await pumpScreen(tester, env, const ChallengeScreen(), size: const Size(360, 640), textScale: 1.0);
    expect(tester.getCenter(find.text('Thử thách').first).dx, closeTo(180, 2));
    await unmount(tester);
  });
}
