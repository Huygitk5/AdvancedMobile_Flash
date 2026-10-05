import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../../core/l10n.dart';
import 'api_exception.dart';
import 'session_store.dart';

/// Client REST dùng chung. Bóc envelope `{success, code, message, data, errors}` ở một chỗ:
/// thành công trả `data`, lỗi nghiệp vụ ném [ApiException], lỗi mạng ném [NetworkException].
/// Access token hết hạn (401) thì tự đổi bằng refresh token một lần rồi gọi lại.
class ApiClient {
  ApiClient._();

  static final ApiClient I = ApiClient._();

  static const Duration _timeout = Duration(seconds: 20);

  http.Client _http = http.Client();
  Future<bool>? _refreshing;

  /// Được gọi khi refresh token cũng hết hạn: app phải đưa người dùng về màn đăng nhập.
  Future<void> Function()? onSessionExpired;

  /// Dùng cho test: thay client HTTP.
  void useClient(http.Client client) => _http = client;

  Uri _uri(String path, Map<String, dynamic>? query) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    return base.replace(path: '${base.path}$path'.replaceAll('//', '/'), queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> _headers({required bool auth, required bool hasBody}) => {
        'Accept': 'application/json',
        'Accept-Language': AppLocale.language.value,
        if (hasBody) 'Content-Type': 'application/json; charset=utf-8',
        if (auth && (SessionStore.accessToken ?? '').isNotEmpty) 'Authorization': 'Bearer ${SessionStore.accessToken}',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) =>
      request('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query, bool auth = true}) =>
      request('POST', path, body: body, query: query, auth: auth);

  Future<dynamic> put(String path, {Object? body, bool auth = true}) => request('PUT', path, body: body, auth: auth);

  Future<dynamic> delete(String path, {Object? body, bool auth = true}) => request('DELETE', path, body: body, auth: auth);

  Future<dynamic> request(String method, String path,
      {Map<String, dynamic>? query, Object? body, bool auth = true}) async {
    var response = await _send(method, path, query, body, auth);
    if (response.statusCode == 401 && auth && SessionStore.hasSession) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        response = await _send(method, path, query, body, auth);
      } else {
        await onSessionExpired?.call();
      }
    }
    return _unwrap(response);
  }

  Future<http.Response> _send(String method, String path, Map<String, dynamic>? query, Object? body, bool auth) async {
    final uri = _uri(path, query);
    final request = http.Request(method, uri)..headers.addAll(_headers(auth: auth, hasBody: body != null));
    if (body != null) request.body = jsonEncode(body);
    try {
      final streamed = await _http.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed).timeout(_timeout);
    } on TimeoutException {
      throw const NetworkException('timeout');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('$e');
    }
  }

  dynamic _unwrap(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode == 204 || text.trim().isEmpty) {
      if (response.statusCode >= 400) throw ApiException(response.statusCode, 'HTTP_${response.statusCode}', '');
      return null;
    }
    dynamic json;
    try {
      json = jsonDecode(text);
    } catch (_) {
      throw ApiException(response.statusCode, 'BAD_RESPONSE', tr('Phản hồi từ máy chủ không hợp lệ'));
    }
    if (json is Map<String, dynamic> && json.containsKey('success')) {
      if (json['success'] == true) return json['data'];
      final errors = <FieldError>[];
      final rawErrors = json['errors'];
      if (rawErrors is List) {
        for (final e in rawErrors) {
          if (e is Map) errors.add(FieldError('${e['field'] ?? ''}', '${e['message'] ?? ''}'));
        }
      }
      throw ApiException(response.statusCode, '${json['code'] ?? 'ERROR'}', '${json['message'] ?? ''}',
          errors: errors, data: json['data']);
    }
    if (response.statusCode >= 400) throw ApiException(response.statusCode, 'HTTP_${response.statusCode}', '');
    return json;
  }

  /// Chỉ một request refresh chạy tại một thời điểm; các request khác cùng chờ kết quả đó.
  Future<bool> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refresh = SessionStore.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final response = await _send('POST', '/v1/auth/refresh-token', null,
          {'refreshToken': refresh, 'deviceId': SessionStore.deviceId}, false);
      final data = _unwrap(response);
      if (data is Map<String, dynamic> && data['accessToken'] != null) {
        await SessionStore.save(access: '${data['accessToken']}', refresh: '${data['refreshToken']}');
        return true;
      }
    } on ApiException {
      return false;
    } on NetworkException {
      // mất mạng: giữ phiên, để lần sau thử lại
      return false;
    }
    return false;
  }
}
