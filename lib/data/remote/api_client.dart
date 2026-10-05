import 'package:dio/dio.dart';

import '../../core/env.dart';
import '../storage/app_prefs.dart';
import '../storage/secure_store.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'dto/page_dto.dart';

/// Bóc envelope `{success, code, message, data, errors, timestamp}`: thành công trả `data`,
/// thất bại ném [ApiException]. Body không phải envelope (204, rỗng) trả nguyên.
dynamic unwrapEnvelope(dynamic body) {
  if (body is Map<String, dynamic> && body.containsKey('success')) {
    if (body['success'] == true) return body['data'];
    throw _fromEnvelope(body, null);
  }
  if (body is String && body.isEmpty) return null;
  return body;
}

ApiException _fromEnvelope(Map<String, dynamic> body, int? status) => ApiException(
      status: status ?? 0,
      code: (body['code'] ?? 'UNKNOWN') as String,
      message: (body['message'] ?? '') as String,
      errors: (body['errors'] as List? ?? const [])
          .map((e) => FieldErrorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      data: body['data'],
    );

/// Nơi DUY NHẤT bóc envelope và đổi lỗi Dio thành [ApiException] / [NetworkException].
class ApiClient {
  ApiClient({
    required AppPrefs prefs,
    required SecureStore store,
    required Future<void> Function() onForceLogout,
    String? baseUrl,
    HttpClientAdapter? httpAdapter, // test
  })  : dio = Dio(_options(baseUrl)),
        _refreshDio = Dio(_options(baseUrl)) {
    if (httpAdapter != null) {
      dio.httpClientAdapter = httpAdapter;
      _refreshDio.httpClientAdapter = httpAdapter;
    }
    dio.interceptors
      ..add(InterceptorsWrapper(onRequest: (o, h) {
        o.headers['Accept-Language'] = prefs.appLanguage;
        h.next(o);
      }))
      ..add(AuthInterceptor(
        dio: dio,
        refreshDio: _refreshDio,
        store: store,
        onForceLogout: onForceLogout,
      ));
  }

  final Dio dio;
  final Dio _refreshDio;

  static BaseOptions _options(String? baseUrl) => BaseOptions(
        baseUrl: baseUrl ?? Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      );

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? headers}) =>
      _send('POST', path, body: body, headers: headers);

  Future<dynamic> put(String path, {Object? body, Map<String, dynamic>? headers}) =>
      _send('PUT', path, body: body, headers: headers);

  Future<dynamic> delete(String path, {Object? body}) => _send('DELETE', path, body: body);

  Future<PageDto<T>> getPage<T>(
    String path,
    T Function(Map<String, dynamic>) itemFromJson, {
    Map<String, dynamic>? query,
  }) async {
    final data = await get(path, query: query) as Map<String, dynamic>;
    return PageDto.fromJson(data, itemFromJson);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final res = await dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method, headers: headers),
      );
      return unwrapEnvelope(res.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Object _mapError(DioException e) {
    final res = e.response;
    if (res != null) {
      final body = res.data;
      if (body is Map<String, dynamic> && body.containsKey('code')) {
        return _fromEnvelope(body, res.statusCode);
      }
      // Body không phải envelope (proxy, 502...): không đưa chuỗi kỹ thuật của Dio lên UI.
      return ApiException(status: res.statusCode ?? 0, code: 'HTTP_${res.statusCode}', message: '');
    }
    if (e.type == DioExceptionType.cancel) return e;
    return NetworkException(e);
  }
}
