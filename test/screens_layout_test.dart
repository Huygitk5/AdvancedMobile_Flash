import 'dart:convert';
import 'package:flash/core/l10n.dart';
import 'package:flash/core/theme.dart';
import 'package:flash/data/api/api_client.dart';
import 'package:flash/data/app_state.dart';
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
import 'package:flash/screens/vocabulary/topic_screen.dart';
import 'package:flash/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'fixtures.dart';

/// Các route backend dùng chung cho các màn hình học viên.
Map<String, Object? Function(http.Request)> studentRoutes() => {
      '/v1/users/me': (_) => userJson(),
      '/v1/shop/inventory': (_) => [],
      '/v1/home/summary': (_) => homeJson(),
      '/v1/topics': (_) => page([
            topicJson('t1', 'Daily Life', words: 29, progress: 0.4),
            topicJson('t2', 'Travel and Transportation Around The World', words: 28, progress: 0, status: 'NOT_STARTED'),
          ]),
      '/v1/grammar': (_) => page([
            grammarJson('g1', 'Present Simple', progress: 1, status: 'COMPLETED'),
            grammarJson('g2', 'Present Perfect Continuous', progress: 0.5, status: 'IN_PROGRESS'),
            grammarJson('g3', 'Inversion with Negative Adverbs'),
          ]),
      '/v1/flashcards': (_) => [flashcardJson('f1', 'apple'), flashcardJson('f2', 'banana', learned: true)],
      '/v1/flashcards/search': (_) => page([flashcardJson('f1', 'apple')]),
      '/v1/flashcards/bookmarks': (_) => page([flashcardJson('f1', 'apple')]),
      '/v1/quests/today': (_) => {
            'totalXp': 120,
            'quests': [
              {'id': 'q1', 'questDefinitionId': 'd1', 'title': 'Học 20 Flashcard mới', 'iconName': 'style', 'current': 20, 'target': 20, 'xp': 50, 'isClaimed': false},
              {'id': 'q2', 'questDefinitionId': 'd2', 'title': 'Duy trì Streak', 'iconName': 'local_fire_department', 'current': 1, 'target': 1, 'xp': 20, 'isClaimed': true},
              {'id': 'q3', 'questDefinitionId': 'd3', 'title': 'Đạt 100% 1 bài kiểm tra', 'iconName': 'fact_check', 'current': 0, 'target': 1, 'xp': 100, 'isClaimed': false},
            ]
          },
      '/v1/leaderboard/xp': (_) => leaderboardJson(),
      '/v1/leaderboard/streak': (_) => leaderboardJson(),
      '/v1/users/me/statistics': (r) => statisticsJson(range: r.url.queryParameters['range'] ?? 'WEEK', daily: [
            {'date': '2026-10-01', 'wordsLearned': 12},
            {'date': '2026-10-05', 'wordsLearned': 30},
          ]),
      '/v1/shop/items': (_) => [
            {
              'id': 'i1', 'code': 'B1', 'name': 'Tân binh', 'itemType': 'BORDER', 'xpCost': 0, 'borderColors': [4293060848, 4291548641], 'requiredRank': 0,
              'isUnlocked': true, 'isEquipped': true, 'inventoryId': 'inv1', 'canAfford': true, 'meetsRankRequirement': true,
            },
            {
              'id': 'i2', 'code': 'B2', 'name': 'Vua Trò Chơi Huyền Thoại', 'itemType': 'BORDER', 'xpCost': 3000, 'borderColors': [4294618388, 4294960527], 'requiredRank': 3,
              'isUnlocked': false, 'isEquipped': false, 'canAfford': false, 'meetsRankRequirement': false,
            },
          ],
      '/v1/grammar/get/g1': (_) => {
            ...grammarJson('g1', 'Present Simple'),
            'content': 'Thì hiện tại đơn dùng để nói về thói quen.\nVới chủ ngữ ngôi thứ ba số ít, động từ thêm -s/-es.',
            'usageNotes': 'Dấu hiệu: always, usually.\nSau does động từ ở dạng nguyên mẫu.',
            'quizId': 'qz1',
            'examples': [
              {'id': 'e1', 'sentence': 'She goes to school every day.', 'translation': 'Cô ấy đi học mỗi ngày.', 'highlight': 'goes'},
              {'id': 'e2', 'sentence': 'No highlight here.', 'translation': 'Không tô đậm.', 'highlight': ''},
            ],
          },
      '/v1/quizzes/get/qz1': (_) => {
            'quiz': {'id': 'qz1', 'title': 'Present Simple - Kiểm tra', 'quizType': 'GRAMMAR', 'passScorePercent': 70, 'questionCount': 2},
            'questions': [
              {'id': 'a', 'questionText': 'She ______ to school every day.', 'options': ['goes', 'go', 'going', 'went'], 'correctAnswerIndex': 0, 'explanation': 'ngôi thứ ba'},
              {'id': 'b', 'questionText': 'They ______ football on Sundays.', 'options': ['plays', 'play', 'playing', 'played'], 'correctAnswerIndex': 1, 'explanation': 'số nhiều'},
            ],
          },
    };

Map<String, dynamic> leaderboardJson() => {
      'items': [
        {'rank': 1, 'userId': 'u9', 'fullName': 'Trần Thị Bích Ngọc Rất Dài Tên', 'avatarUrl': null, 'slogan': 'Chúa tể ngữ pháp 👑', 'equippedBorderColors': [4294921551, 4294933061, 4294945088], 'score': 3200},
        {'rank': 2, 'userId': 'u1', 'fullName': 'Nguyễn Văn Tên Rất Dài Để Thử Tràn Dòng', 'slogan': 'Học là phải vui', 'equippedBorderColors': [], 'score': 560},
        {'rank': 3, 'userId': 'u3', 'fullName': 'An', 'slogan': '', 'score': 100},
      ],
      'me': {'rank': 2, 'score': 560},
    };

/// Dựng màn hình trên "điện thoại" có kích thước và cỡ chữ cho trước, trả về lỗi layout (nếu có).
Future<void> pumpScreen(WidgetTester tester, Widget screen, {Size size = const Size(320, 640), double textScale = 1.15, bool dark = false}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
    home: screen,
  ));
  await settle(tester);
}

/// Cho các Future của API (MockClient) hoàn tất và dựng lại giao diện.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    AppLocale.language.value = 'vi';
    signInForTest();
    useRoutes(studentRoutes());
  });

  const sizes = <String, Size>{'320x568 (máy nhỏ)': Size(320, 568), '360x640': Size(360, 640), '411x891': Size(411, 891)};

  for (final entry in sizes.entries) {
    group('không tràn layout trên ${entry.key}, chữ phóng 1.15x', () {
      testWidgets('Trang chủ (danh mục học tập, bài gợi ý, thử thách)', (tester) async {
        await pumpScreen(tester, const HomeScreen(), size: entry.value);
        expect(tester.takeException(), isNull);
        expect(find.text('Danh mục học tập'), findsOneWidget);
        expect(find.text('Từ vựng'), findsOneWidget);
        expect(find.text('Ngữ pháp'), findsOneWidget);
        // Đã bỏ: icon vẫy tay, nhắc nhở, câu chào chung chung
        expect(find.textContaining('👋'), findsNothing);
        expect(find.textContaining('Hôm nay là một ngày tuyệt vời'), findsNothing);
        expect(find.byIcon(Icons.notifications_none), findsNothing);
        // Số liệu thật từ API: 3/5 bài, 57 từ (29 + 28) và 2 chủ đề
        expect(find.text('3/5 bài'), findsOneWidget);
        expect(find.text('57 từ • 2 chủ đề'), findsOneWidget);
      });

      testWidgets('Học tập: từ vựng và ngữ pháp', (tester) async {
        await pumpScreen(tester, const TopicScreen(), size: entry.value);
        expect(tester.takeException(), isNull);
        expect(find.text('Daily Life'), findsOneWidget);
        await tester.tap(find.text('Ngữ pháp'));
        await settle(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('Present Simple'), findsOneWidget);
        expect(find.text('Đã học 100%'), findsOneWidget);
        expect(find.text('Đang học 50%'), findsOneWidget);
      });

      testWidgets('Tiến độ: biểu đồ có trục tung và các bộ lọc', (tester) async {
        await pumpScreen(tester, const ProgressScreen(), size: entry.value);
        expect(tester.takeException(), isNull);
        for (final label in ['Tuần', 'Tháng', 'Năm', 'Tất cả', 'Tùy chọn']) {
          expect(find.text(label), findsOneWidget, reason: 'thiếu bộ lọc $label');
        }
        expect(find.text('Số từ đã học'), findsOneWidget);
        expect(find.text('Bài học hoàn thành'), findsOneWidget);
        expect(find.text('85%'), findsOneWidget);
      });

      testWidgets('Bảng xếp hạng: avatar có viền, hiện slogan', (tester) async {
        await pumpScreen(tester, const LeaderboardScreen(), size: entry.value);
        expect(tester.takeException(), isNull);
        expect(find.text('Chúa tể ngữ pháp 👑'), findsWidgets);
        expect(find.text('Học là phải vui'), findsWidgets);
        expect(find.text('Chưa có câu châm ngôn'), findsWidgets); // người dùng chưa đặt slogan
        expect(find.byType(UserAvatar), findsWidgets);
      });

      testWidgets('Thẻ từ vựng, thử thách, hồ sơ, cửa hàng, từ đã lưu', (tester) async {
        for (final screen in <Widget>[
          const FlashcardScreen(topicId: 't1', topicTitle: 'Daily Life'),
          const ChallengeScreen(),
          const ProfileScreen(),
          const ShopScreen(),
          const SavedWordsScreen(),
        ]) {
          await pumpScreen(tester, screen, size: entry.value);
          expect(tester.takeException(), isNull, reason: '${screen.runtimeType} bị tràn layout');
        }
      });

      testWidgets('Ngữ pháp chi tiết và làm bài kiểm tra', (tester) async {
        await pumpScreen(tester, const GrammarDetailScreen(grammarId: 'g1', title: 'Present Simple'), size: entry.value);
        expect(tester.takeException(), isNull);
        expect(find.text('Cấu trúc'), findsOneWidget);
        expect(find.text('Tiếp theo (Kiểm tra)'), findsOneWidget);
        await pumpScreen(tester, const QuizScreen(quizId: 'qz1'), size: entry.value);
        expect(tester.takeException(), isNull);
        expect(find.text('goes'), findsOneWidget);
      });
    });
  }

  testWidgets('Chế độ tối không bị tràn layout', (tester) async {
    for (final screen in <Widget>[const HomeScreen(), const ProgressScreen(), const ProfileScreen()]) {
      await pumpScreen(tester, screen, dark: true);
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType} (dark)');
    }
  });

  testWidgets('Thanh điều hướng: chỉ icon, tab đang chọn mới hiện tên, "Học" đổi thành "Học tập"', (tester) async {
    await pumpScreen(tester, const MainScreen(), size: const Size(360, 640), textScale: 1.0);
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
    expect(opacityOf('Học tập'), greaterThan(0.99));
    expect(opacityOf('Trang chủ'), lessThan(0.01));
  });

  testWidgets('Tiêu đề màn hình căn giữa', (tester) async {
    await pumpScreen(tester, const ProgressScreen(), size: const Size(360, 640), textScale: 1.0);
    final title = tester.getCenter(find.text('Tiến độ').first);
    expect(title.dx, closeTo(180, 2));
    await pumpScreen(tester, const ChallengeScreen(), size: const Size(360, 640), textScale: 1.0);
    expect(tester.getCenter(find.text('Thử thách').first).dx, closeTo(180, 2));
  });

  test('payload mẫu hợp lệ JSON', () {
    expect(() => jsonEncode(studentRoutes().map((k, v) => MapEntry(k, 1))), returnsNormally);
    expect(ApiClient.I, isNotNull);
    expect(AppState.I.isSignedIn, isTrue);
  });
}
