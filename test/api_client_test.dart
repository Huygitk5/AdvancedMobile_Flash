import 'dart:convert';
import 'package:flash/core/l10n.dart';
import 'package:flash/data/api/api_client.dart';
import 'package:flash/data/api/api_exception.dart';
import 'package:flash/data/api/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'fixtures.dart';

http.Response jsonResponse(String body, int status) =>
    http.Response.bytes(utf8.encode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  setUp(() {
    AppLocale.language.value = 'vi';
    SessionStore.accessToken = 'old-access';
    SessionStore.refreshToken = 'old-refresh';
    SessionStore.deviceId = 'device-1';
    ApiClient.I.onSessionExpired = null;
  });

  test('thành công trả data và gửi Bearer token + Accept-Language', () async {
    late http.Request seen;
    ApiClient.I.useClient(MockClient((request) async {
      seen = request;
      return jsonResponse(envelope({'hello': 'xin chào'}), 200);
    }));

    final data = await ApiClient.I.get('/v1/health', query: {'a': 1, 'b': null});
    expect(data, {'hello': 'xin chào'}); // tiếng Việt không bị đọc sai charset
    expect(seen.headers['Authorization'], 'Bearer old-access');
    expect(seen.headers['Accept-Language'], 'vi');
    expect(seen.url.queryParameters, {'a': '1'}); // tham số null bị bỏ
  });

  test('không gửi token cho request auth = false', () async {
    late http.Request seen;
    ApiClient.I.useClient(MockClient((request) async {
      seen = request;
      return jsonResponse(envelope(null), 200);
    }));
    await ApiClient.I.post('/v1/auth/login', body: {'email': 'a@b.c'}, auth: false);
    expect(seen.headers.containsKey('Authorization'), isFalse);
    expect(jsonDecode(seen.body), {'email': 'a@b.c'});
  });

  test('lỗi nghiệp vụ ném ApiException có code, message và lỗi theo trường', () async {
    ApiClient.I.useClient(MockClient((request) async => jsonResponse(
        envelope(null, success: false, code: 'VALIDATION_ERROR', message: 'Dữ liệu không hợp lệ', errors: [
          {'field': 'email', 'message': 'Email không hợp lệ'}
        ]),
        400)));
    try {
      await ApiClient.I.post('/v1/auth/register', body: {}, auth: false);
      fail('phải ném ApiException');
    } on ApiException catch (e) {
      expect(e.status, 400);
      expect(e.code, 'VALIDATION_ERROR');
      expect(e.userMessage, 'Email không hợp lệ'); // ưu tiên lỗi theo trường
    }
  });

  test('mã lỗi đã biết được dịch theo ngôn ngữ giao diện', () async {
    ApiClient.I.useClient(MockClient((request) async =>
        jsonResponse(envelope(null, success: false, code: 'INVALID_CREDENTIALS', message: 'Email hoặc mật khẩu không đúng'), 401)));
    AppLocale.language.value = 'en';
    try {
      await ApiClient.I.post('/v1/auth/login', body: {}, auth: false);
      fail('phải ném ApiException');
    } on ApiException catch (e) {
      expect(e.userMessage, 'Incorrect email or password');
    }
  });

  test('204 không có nội dung trả null', () async {
    ApiClient.I.useClient(MockClient((request) async => http.Response('', 204)));
    expect(await ApiClient.I.post('/v1/auth/logout', body: {'refreshToken': 'x'}, auth: false), isNull);
  });

  test('lỗi mạng ném NetworkException', () async {
    ApiClient.I.useClient(MockClient((request) async => throw http.ClientException('Connection refused')));
    expect(() => ApiClient.I.get('/v1/health'), throwsA(isA<NetworkException>()));
  });

  test('401: tự refresh token một lần rồi gọi lại với token mới', () async {
    var calls = 0;
    var refreshCalls = 0;
    final authHeaders = <String?>[];
    ApiClient.I.useClient(MockClient((request) async {
      if (request.url.path == '/v1/auth/refresh-token') {
        refreshCalls++;
        expect(jsonDecode(request.body)['refreshToken'], 'old-refresh');
        return jsonResponse(envelope({'accessToken': 'new-access', 'refreshToken': 'new-refresh'}), 200);
      }
      calls++;
      authHeaders.add(request.headers['Authorization']);
      if (request.headers['Authorization'] == 'Bearer old-access') {
        return jsonResponse(envelope(null, success: false, code: 'UNAUTHORIZED', message: 'Hết hạn'), 401);
      }
      return jsonResponse(envelope({'ok': true}), 200);
    }));

    final data = await ApiClient.I.get('/v1/users/me');
    expect(data, {'ok': true});
    expect(calls, 2);
    expect(refreshCalls, 1);
    expect(authHeaders, ['Bearer old-access', 'Bearer new-access']);
    expect(SessionStore.refreshToken, 'new-refresh');
  });

  test('nhiều request cùng gặp 401 chỉ refresh một lần', () async {
    var refreshCalls = 0;
    ApiClient.I.useClient(MockClient((request) async {
      if (request.url.path == '/v1/auth/refresh-token') {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return jsonResponse(envelope({'accessToken': 'new-access', 'refreshToken': 'new-refresh'}), 200);
      }
      if (request.headers['Authorization'] == 'Bearer old-access') {
        return jsonResponse(envelope(null, success: false, code: 'UNAUTHORIZED', message: 'Hết hạn'), 401);
      }
      return jsonResponse(envelope({'path': request.url.path}), 200);
    }));

    final results = await Future.wait([ApiClient.I.get('/v1/a'), ApiClient.I.get('/v1/b'), ApiClient.I.get('/v1/c')]);
    expect(results.map((r) => r['path']), ['/v1/a', '/v1/b', '/v1/c']);
    expect(refreshCalls, 1);
  });

  test('refresh thất bại: gọi onSessionExpired và ném 401', () async {
    var expired = false;
    ApiClient.I.onSessionExpired = () async => expired = true;
    ApiClient.I.useClient(MockClient((request) async {
      if (request.url.path == '/v1/auth/refresh-token') {
        return jsonResponse(envelope(null, success: false, code: 'INVALID_TOKEN', message: 'Token không hợp lệ'), 401);
      }
      return jsonResponse(envelope(null, success: false, code: 'UNAUTHORIZED', message: 'Hết hạn'), 401);
    }));

    await expectLater(() => ApiClient.I.get('/v1/users/me'), throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)));
    expect(expired, isTrue);
  });
}
