import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flash/core/clock.dart';
import 'package:flash/core/l10n.dart';
import 'package:flash/data/remote/api_client.dart';
import 'package:flash/data/remote/api_exception.dart';
import 'package:flash/data/remote/apis/feedback_api.dart';
import 'package:flash/data/remote/dto/page_dto.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';
import 'package:flash/providers/feedback_providers.dart';
import 'package:flash/screens/profile/my_feedback_screen.dart';
import 'package:flash/widgets/feedback_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFeedbackApi extends Mock implements FeedbackApi {}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.data);

  final Object? data;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'success': true, 'code': 'OK', 'message': '', 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> feedbackJson({
  String id = 'f1',
  int feedbackFor = 1,
  bool isViewed = false,
  String content = 'Phát âm sai',
  String itemTitle = 'apple',
  String? parentTitle = 'Fruits',
}) =>
    {
      'id': id,
      'createdBy': {'id': 'u1', 'fullName': 'Nguyễn An', 'email': 'an@mail.com'},
      'createdAt': '2026-09-01T08:30:00Z',
      'content': content,
      'feedbackFor': feedbackFor,
      'itemId': 'item-$id',
      'isViewed': isViewed,
      'itemTitle': itemTitle,
      'parentTitle': ?parentTitle,
      'topicId': 't1',
    };

FeedbackItem item({
  String id = 'f1',
  FeedbackType type = FeedbackType.flashcard,
  bool isViewed = false,
  String content = 'Phát âm sai',
  String itemTitle = 'apple',
  String? parentTitle = 'Fruits',
}) =>
    FeedbackItem.fromJson(feedbackJson(
      id: id,
      feedbackFor: type.code,
      isViewed: isViewed,
      content: content,
      itemTitle: itemTitle,
      parentTitle: parentTitle,
    ));

PageDto<FeedbackItem> page(List<FeedbackItem> items, {int p = 0, int totalPages = 1}) =>
    PageDto(items: items, page: p, size: 20, totalElements: items.length, totalPages: totalPages);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => AppLocale.language.value = 'vi');
  setUpAll(() => registerFallbackValue(FeedbackType.flashcard));

  group('model', () {
    test('FeedbackType: code 1/2/3 và fromCode', () {
      expect(FeedbackType.values.map((t) => t.code), [1, 2, 3]);
      expect(FeedbackType.fromCode(2), FeedbackType.grammar);
      expect(FeedbackType.fromCode(3), FeedbackType.quiz);
      expect(() => FeedbackType.fromCode(9), throwsArgumentError);
    });

    test('FeedbackItem.fromJson đọc đủ trường, ngày về UTC', () {
      final f = FeedbackItem.fromJson(feedbackJson());
      expect(f.id, 'f1');
      expect(f.type, FeedbackType.flashcard);
      expect(f.itemId, 'item-f1');
      expect(f.content, 'Phát âm sai');
      expect(f.isViewed, isFalse);
      expect(f.createdAt, DateTime.utc(2026, 9, 1, 8, 30));
      expect(f.itemTitle, 'apple');
      expect(f.parentTitle, 'Fruits');
      expect(f.topicId, 't1');
      expect(f.grammarLessonId, isNull);
      expect(f.createdBy.fullName, 'Nguyễn An');
      expect(f.createdBy.email, 'an@mail.com');
    });

    test('field null bị backend bỏ: không lỗi', () {
      final f = FeedbackItem.fromJson({
        'id': 'g1',
        'content': 'x',
        'feedbackFor': 2,
        'itemId': 'gl1',
        'itemTitle': 'Present Simple',
        'isViewed': true,
      });
      expect(f.type, FeedbackType.grammar);
      expect(f.parentTitle, isNull);
      expect(f.isViewed, isTrue);
      expect(f.createdBy.id, '');
    });

    test('copyWith chỉ đổi content / isViewed', () {
      final f = FeedbackItem.fromJson(feedbackJson());
      final g = f.copyWith(content: 'mới', isViewed: true);
      expect(g.content, 'mới');
      expect(g.isViewed, isTrue);
      expect(g.id, f.id);
      expect(g.itemTitle, f.itemTitle);
      expect(f.copyWith().content, f.content);
    });

    test('FeedbackSummary', () {
      final s = FeedbackSummary.fromJson({'flashcard': 2, 'grammar': 1, 'quiz': 4});
      expect(s.total, 7);
      expect(s.countOf(FeedbackType.quiz), 4);
      expect(FeedbackSummary.fromJson(const {}).total, 0);
    });

    test('quy tắc sửa / xóa: chỉ khi admin chưa xem', () {
      expect(item(isViewed: false).canModify, isTrue);
      expect(item(isViewed: true).canModify, isFalse);
    });
  });

  group('FeedbackFilter', () {
    test('so sánh theo giá trị', () {
      final a = FeedbackFilter(type: FeedbackType.quiz, isViewed: false, from: DateTime(2026, 9, 1));
      final b = FeedbackFilter(type: FeedbackType.quiz, isViewed: false, from: DateTime(2026, 9, 1));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == a.copyWith(to: DateTime(2026, 9, 2)), isFalse);
      expect(const FeedbackFilter().isEmpty, isTrue);
    });

    test('copyWith: bỏ qua = giữ, null = xóa', () {
      final a = FeedbackFilter(type: FeedbackType.grammar, isViewed: true, from: DateTime(2026, 9, 1), to: DateTime(2026, 9, 5));
      expect(a.copyWith().type, FeedbackType.grammar);
      final cleared = a.copyWith(type: null, from: null, to: null);
      expect(cleared.type, isNull);
      expect(cleared.from, isNull);
      expect(cleared.to, isNull);
      expect(cleared.isViewed, isTrue);
    });
  });

  group('tham số query', () {
    test('ngày định dạng yyyy-MM-dd, có đệm số 0', () {
      expect(feedbackDateParam(DateTime(2026, 1, 5)), '2026-01-05');
      expect(feedbackDateParam(DateTime(2026, 12, 31, 23, 59)), '2026-12-31');
    });

    test('bỏ tham số null, giữ page/size', () {
      expect(feedbackListQuery(), {'page': 0, 'size': 20});
      expect(
        feedbackListQuery(
          type: FeedbackType.quiz,
          isViewed: false,
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 30),
          page: 2,
          size: 10,
        ),
        {'feedbackFor': 3, 'isViewed': false, 'from': '2026-09-01', 'to': '2026-09-30', 'page': 2, 'size': 10},
      );
    });
  });

  group('FeedbackApi (ApiClient thật + adapter giả)', () {
    late ApiClient client;
    late _FakeAdapter adapter;

    Future<FeedbackApi> make(Object? data) async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final store = SecureStore();
      await store.saveSession(
        accessToken: 'a',
        refreshToken: 'r',
        accessExpiresAt: Clock.now().toUtc().add(const Duration(minutes: 10)),
        userId: 'u1',
        role: 'USER',
      );
      adapter = _FakeAdapter(data);
      client = ApiClient(
        prefs: AppPrefs.fromInstance(await SharedPreferences.getInstance()),
        store: store,
        baseUrl: 'http://test',
        httpAdapter: adapter,
        onForceLogout: () async {},
      );
      return FeedbackApi(client);
    }

    test('myFeedbacks gửi đúng path + query và parse trang', () async {
      final api = await make({
        'items': [feedbackJson()],
        'page': 0,
        'size': 20,
        'totalElements': 1,
        'totalPages': 1,
      });
      final p = await api.myFeedbacks(type: FeedbackType.grammar, from: DateTime(2026, 9, 1), to: DateTime(2026, 9, 7));
      expect(p.items.single.id, 'f1');
      expect(p.isLast, isTrue);
      final r = adapter.requests.single;
      expect(r.method, 'GET');
      expect(r.path, '/v1/feedbacks/me');
      expect(r.queryParameters, {'feedbackFor': 2, 'from': '2026-09-01', 'to': '2026-09-07', 'page': 0, 'size': 20});
    });

    test('adminList thêm isViewed; create/update/delete/setViewed đúng endpoint', () async {
      var api = await make({'items': [], 'page': 0, 'size': 20, 'totalElements': 0, 'totalPages': 0});
      await api.adminList(isViewed: true);
      expect(adapter.requests.single.path, '/v1/feedbacks');
      expect(adapter.requests.single.queryParameters['isViewed'], true);

      api = await make(feedbackJson());
      await api.create(type: FeedbackType.quiz, itemId: 'q1', content: 'hay');
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.path, '/v1/feedbacks/create');
      expect(adapter.requests.last.data, {'feedbackFor': 3, 'itemId': 'q1', 'content': 'hay'});

      await api.update('f1', 'sửa');
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.path, '/v1/feedbacks/update/f1');
      expect(adapter.requests.last.data, {'content': 'sửa'});

      await api.setViewed('f1', true);
      expect(adapter.requests.last.path, '/v1/feedbacks/f1/viewed');
      expect(adapter.requests.last.data, {'isViewed': true});

      api = await make(null);
      await api.delete('f1');
      expect(adapter.requests.last.method, 'DELETE');
      expect(adapter.requests.last.path, '/v1/feedbacks/delete/f1');

      api = await make({'flashcard': 1, 'grammar': 2, 'quiz': 3});
      expect((await api.mySummary()).total, 6);
      expect(adapter.requests.last.path, '/v1/feedbacks/me/summary');
    });
  });

  group('feedbackErrorMessage', () {
    test('mất mạng / admin đã xem / lỗi khác', () {
      expect(feedbackErrorMessage(const NetworkException(), FeedbackAction.send), 'Cần kết nối mạng để gửi góp ý');
      const viewed = ApiException(status: 409, code: 'FEEDBACK_ALREADY_VIEWED', message: '');
      expect(feedbackErrorMessage(viewed, FeedbackAction.edit), 'Admin đã xem, không thể sửa');
      expect(feedbackErrorMessage(viewed, FeedbackAction.delete), 'Admin đã xem, không thể xóa');
      expect(isFeedbackAlreadyViewed(viewed), isTrue);
      expect(isFeedbackAlreadyViewed(const ApiException(status: 404, code: 'NOT_FOUND', message: '')), isFalse);
      expect(feedbackErrorMessage(const ApiException(status: 404, code: 'NOT_FOUND', message: ''), FeedbackAction.edit),
          'Không tìm thấy dữ liệu.');
    });
  });

  group('MyFeedbackScreen', () {
    late MockFeedbackApi api;

    setUp(() {
      api = MockFeedbackApi();
      when(() => api.mySummary()).thenAnswer((_) async => const FeedbackSummary(flashcard: 1));
    });

    Future<void> pumpScreen(WidgetTester tester, {FeedbackType? initialType}) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [feedbackApiProvider.overrideWithValue(api)],
        child: MaterialApp(home: MyFeedbackScreen(initialType: initialType)),
      ));
      await tester.pump();
      await tester.pump();
    }

    void stubList(List<FeedbackItem> items) {
      when(() => api.myFeedbacks(
            type: any(named: 'type'),
            from: any(named: 'from'),
            to: any(named: 'to'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => page(items));
    }

    IconButton button(WidgetTester tester, String key) => tester.widget<IconButton>(find.byKey(Key(key)));

    testWidgets('nút sửa / xóa chỉ bật khi chưa xem; đã xem hiện nhãn và mờ nút', (tester) async {
      stubList([
        item(id: 'open', content: 'Chưa ai xem'),
        item(id: 'seen', type: FeedbackType.grammar, isViewed: true, itemTitle: 'Present Simple', parentTitle: null, content: 'Đã xem rồi'),
      ]);
      await pumpScreen(tester);

      expect(button(tester, 'feedback-edit-open').onPressed, isNotNull);
      expect(button(tester, 'feedback-delete-open').onPressed, isNotNull);
      expect(button(tester, 'feedback-edit-seen').onPressed, isNull);
      expect(button(tester, 'feedback-delete-seen').onPressed, isNull);
      expect(find.byKey(const Key('feedback-viewed-seen')), findsOneWidget);
      expect(find.byKey(const Key('feedback-viewed-open')), findsNothing);

      // flashcard: topic + từ + nội dung; grammar: tên bài + nội dung
      expect(find.text('Fruits'), findsOneWidget);
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('Chưa ai xem'), findsOneWidget);
      expect(find.text('Present Simple'), findsOneWidget);
    });

    testWidgets('rỗng: báo chưa có góp ý', (tester) async {
      stubList([]);
      await pumpScreen(tester);
      expect(find.text('Bạn chưa gửi góp ý nào'), findsOneWidget);
    });

    testWidgets('lỗi tải: ErrorView có nút thử lại', (tester) async {
      when(() => api.myFeedbacks(
            type: any(named: 'type'),
            from: any(named: 'from'),
            to: any(named: 'to'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenThrow(const NetworkException());
      await pumpScreen(tester);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('initialType lọc sẵn; đổi chip gọi lại API với loại mới', (tester) async {
      stubList([item()]);
      await pumpScreen(tester, initialType: FeedbackType.flashcard);
      verify(() => api.myFeedbacks(type: FeedbackType.flashcard, from: null, to: null, page: 0, size: 20)).called(1);

      await tester.tap(find.byKey(const Key('feedback-chip-quiz')));
      await tester.pump();
      await tester.pump();
      verify(() => api.myFeedbacks(type: FeedbackType.quiz, from: null, to: null, page: 0, size: 20)).called(1);

      await tester.tap(find.byKey(const Key('feedback-chip-all')));
      await tester.pump();
      await tester.pump();
      verify(() => api.myFeedbacks(type: null, from: null, to: null, page: 0, size: 20)).called(1);
    });

    testWidgets('xóa: xác nhận rồi gọi API, bỏ khỏi danh sách và làm mới summary', (tester) async {
      stubList([item(id: 'a'), item(id: 'b', content: 'Cái thứ hai')]);
      when(() => api.delete(any())).thenAnswer((_) async {});
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('feedback-delete-a')));
      await tester.pumpAndSettle();
      expect(find.text('Bạn có chắc muốn xóa góp ý này?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
      await tester.pumpAndSettle();

      verify(() => api.delete('a')).called(1);
      expect(find.byKey(const Key('feedback-card-a')), findsNothing);
      expect(find.byKey(const Key('feedback-card-b')), findsOneWidget);
    });

    testWidgets('xóa khi admin vừa xem: báo lỗi và tải lại danh sách', (tester) async {
      stubList([item(id: 'a')]);
      when(() => api.delete(any())).thenThrow(const ApiException(status: 409, code: 'FEEDBACK_ALREADY_VIEWED', message: ''));
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('feedback-delete-a')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
      await tester.pumpAndSettle();

      expect(find.text('Admin đã xem, không thể xóa'), findsOneWidget);
      verify(() => api.myFeedbacks(
          type: any(named: 'type'), from: any(named: 'from'), to: any(named: 'to'), page: any(named: 'page'), size: any(named: 'size'))).called(2);
    });
  });

  group('showFeedbackDialog', () {
    late MockFeedbackApi api;

    setUp(() {
      api = MockFeedbackApi();
      when(() => api.mySummary()).thenAnswer((_) async => const FeedbackSummary());
    });

    Future<ValueNotifier<bool?>> pumpOpener(WidgetTester tester, {FeedbackItem? editing}) async {
      final result = ValueNotifier<bool?>(null);
      await tester.pumpWidget(ProviderScope(
        overrides: [feedbackApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () async => result.value = await showFeedbackDialog(
                  context,
                  ref,
                  type: FeedbackType.flashcard,
                  itemId: 'c1',
                  targetLabel: 'apple',
                  editing: editing,
                ),
                child: const Text('mở'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      return result;
    }

    ElevatedButton submit(WidgetTester tester) => tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    testWidgets('không gửi được khi rỗng; gửi nội dung đã trim, đóng và trả true', (tester) async {
      when(() => api.create(type: any(named: 'type'), itemId: any(named: 'itemId'), content: any(named: 'content')))
          .thenAnswer((_) async => item());
      final result = await pumpOpener(tester);

      expect(find.text('Gửi góp ý'), findsOneWidget);
      expect(find.text('Flashcard: apple'), findsOneWidget);
      expect(submit(tester).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(submit(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  Sai nghĩa  ');
      await tester.pump();
      expect(submit(tester).onPressed, isNotNull);
      expect(find.text('13/1000'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => api.create(type: FeedbackType.flashcard, itemId: 'c1', content: 'Sai nghĩa')).called(1);
      expect(result.value, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Đã gửi góp ý, cảm ơn bạn!'), findsOneWidget);
    });

    testWidgets('mất mạng: giữ hộp thoại, báo cần kết nối mạng', (tester) async {
      when(() => api.create(type: any(named: 'type'), itemId: any(named: 'itemId'), content: any(named: 'content')))
          .thenThrow(const NetworkException());
      final result = await pumpOpener(tester);
      await tester.enterText(find.byType(TextField), 'Góp ý');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Cần kết nối mạng để gửi góp ý'), findsWidgets);
      expect(result.value, isNull);
      expect(submit(tester).onPressed, isNotNull);
    });

    testWidgets('sửa: điền sẵn nội dung cũ, gọi update, báo admin đã xem khi 409', (tester) async {
      when(() => api.update(any(), any()))
          .thenThrow(const ApiException(status: 409, code: 'FEEDBACK_ALREADY_VIEWED', message: ''));
      final result = await pumpOpener(tester, editing: item(id: 'e1', content: 'Cũ'));

      expect(find.text('Sửa góp ý'), findsOneWidget);
      expect(find.text('Cũ'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Mới');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => api.update('e1', 'Mới')).called(1);
      expect(find.text('Admin đã xem, không thể sửa'), findsWidgets);
      expect(result.value, isNull);

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(result.value, isFalse);
    });
  });
}
