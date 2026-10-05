import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flash/core/clock.dart';
import 'package:flash/data/remote/api_client.dart';
import 'package:flash/data/remote/api_exception.dart';
import 'package:flash/data/storage/app_prefs.dart';
import 'package:flash/data/storage/secure_store.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions o) handler;
  final List<RequestOptions> requests = [];

  int count(String path) => requests.where((r) => r.path == path).length;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Map<String, dynamic> body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );

Map<String, dynamic> ok(Object? data) => {'success': true, 'code': 'OK', 'message': 'Thành công', 'data': data};

Map<String, dynamic> fail(String code, {String message = '', Object? data, List<Map<String, String>>? errors}) =>
    {'success': false, 'code': code, 'message': message, 'data': data, 'errors': errors};

Map<String, dynamic> tokens(String access, String refresh) =>
    ok({'accessToken': access, 'refreshToken': refresh, 'expiresIn': 900});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStore store;
  late AppPrefs prefs;
  late int forceLogouts;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    store = SecureStore();
    prefs = AppPrefs.fromInstance(await SharedPreferences.getInstance());
    forceLogouts = 0;
    await store.saveSession(
      accessToken: 'old',
      refreshToken: 'r1',
      accessExpiresAt: Clock.now().toUtc().add(const Duration(minutes: 10)),
      userId: 'u1',
      role: 'USER',
    );
  });

  ApiClient make(FakeAdapter a) => ApiClient(
        prefs: prefs,
        store: store,
        baseUrl: 'http://test',
        httpAdapter: a,
        onForceLogout: () async => forceLogouts++,
      );

  group('envelope', () {
    test('thành công: trả về data', () async {
      final api = make(FakeAdapter((_) => json(200, ok({'x': 1}))));
      expect(await api.get('/v1/anything'), {'x': 1});
    });

    test('204 không body: trả null', () async {
      final api = make(FakeAdapter((_) => ResponseBody.fromString('', 204)));
      expect(await api.delete('/v1/anything'), isNull);
    });

    test('lỗi: ApiException mang đúng status và code', () async {
      final api = make(FakeAdapter((_) => json(401, fail('INVALID_CREDENTIALS', message: 'sai'))));
      await expectLater(
        api.post('/v1/auth/login', body: {}),
        throwsA(isA<ApiException>()
            .having((e) => e.status, 'status', 401)
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS')
            .having((e) => e.userMessage, 'userMessage', 'Email hoặc mật khẩu không đúng.')),
      );
    });

    test('409 VERSION_CONFLICT mang theo bản server trong data', () async {
      final api = make(FakeAdapter((_) => json(409, fail('VERSION_CONFLICT', data: {'version': 7}))));
      await expectLater(
        api.put('/v1/users/update', body: {}),
        throwsA(isA<ApiException>()
            .having((e) => e.isVersionConflict, 'isVersionConflict', true)
            .having((e) => (e.data as Map)['version'], 'data.version', 7)),
      );
    });

    test('VALIDATION_ERROR hiện errors[].message', () async {
      final api = make(FakeAdapter((_) => json(400, fail('VALIDATION_ERROR', errors: [
            {'field': 'password', 'message': 'Mật khẩu tối thiểu 8 ký tự'},
          ]))));
      await expectLater(
        api.post('/v1/auth/register', body: {}),
        throwsA(isA<ApiException>().having((e) => e.userMessage, 'userMessage', 'Mật khẩu tối thiểu 8 ký tự')),
      );
    });

    test('mất mạng: NetworkException', () async {
      final api = make(FakeAdapter((o) => throw DioException(requestOptions: o, type: DioExceptionType.connectionError)));
      await expectLater(api.get('/v1/anything'), throwsA(isA<NetworkException>()));
    });
  });

  group('auth interceptor', () {
    test('gắn Bearer token; /v1/auth/** thì không gắn', () async {
      final a = FakeAdapter((_) => json(200, ok(null)));
      final api = make(a);
      await api.get('/v1/users/me');
      await api.post('/v1/auth/login', body: {});
      expect(a.requests[0].headers['Authorization'], 'Bearer old');
      expect(a.requests[1].headers.containsKey('Authorization'), false);
    });

    test('2 request cùng gặp 401 chỉ refresh 1 lần, cả hai đều thành công', () async {
      late FakeAdapter a;
      a = FakeAdapter((o) {
        if (o.path == '/v1/auth/refresh-token') return json(200, tokens('new', 'r2'));
        return o.headers['Authorization'] == 'Bearer new'
            ? json(200, ok({'ok': true}))
            : json(401, fail('UNAUTHORIZED'));
      });
      final api = make(a);

      final results = await Future.wait([api.get('/v1/data'), api.get('/v1/data')]);

      expect(results, [
        {'ok': true},
        {'ok': true},
      ]);
      expect(a.count('/v1/auth/refresh-token'), 1);
      expect(await store.refreshToken(), 'r2'); // refresh token đã rotate
      expect(forceLogouts, 0);
    });

    test('token sắp hết hạn (< 60s): refresh trước khi gửi request', () async {
      await store.saveTokens(
        accessToken: 'old',
        refreshToken: 'r1',
        accessExpiresAt: Clock.now().toUtc().add(const Duration(seconds: 10)),
      );
      final a = FakeAdapter((o) {
        if (o.path == '/v1/auth/refresh-token') return json(200, tokens('new', 'r2'));
        return json(200, ok(null));
      });
      await make(a).get('/v1/data');

      expect(a.count('/v1/auth/refresh-token'), 1);
      expect(a.requests.last.headers['Authorization'], 'Bearer new');
    });

    test('refresh bị server từ chối (401): forceLogout và request thất bại', () async {
      final a = FakeAdapter((o) {
        if (o.path == '/v1/auth/refresh-token') return json(401, fail('INVALID_TOKEN'));
        return json(401, fail('UNAUTHORIZED'));
      });
      await expectLater(make(a).get('/v1/data'), throwsA(isA<ApiException>()));
      expect(forceLogouts, 1);
    });

    test('refresh gặp lỗi mạng: KHÔNG đăng xuất (offline-first)', () async {
      final a = FakeAdapter((o) {
        if (o.path == '/v1/auth/refresh-token') {
          throw DioException(requestOptions: o, type: DioExceptionType.connectionError);
        }
        return json(401, fail('UNAUTHORIZED'));
      });
      await expectLater(make(a).get('/v1/data'), throwsA(isA<ApiException>()));
      expect(forceLogouts, 0);
      expect(await store.refreshToken(), 'r1');
    });
  });
}
