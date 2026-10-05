import 'package:dio/dio.dart';

import '../../core/clock.dart';
import '../storage/secure_store.dart';
import 'api_client.dart' show unwrapEnvelope;

/// Gắn access token, chủ động refresh trước khi hết hạn, và refresh + gọi lại khi gặp 401.
///
/// Dùng [QueuedInterceptor] để các request không refresh đồng thời. Khi nhiều request cùng 401,
/// request đầu refresh, các request sau thấy token trong kho đã khác token chúng đã gửi nên chỉ gọi lại.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.store,
    required this.onForceLogout,
  });

  /// Dio chính, dùng để gọi lại request sau khi refresh.
  final Dio dio;

  /// Dio riêng KHÔNG gắn interceptor này, dùng để gọi `/v1/auth/refresh-token` (tránh đệ quy).
  final Dio refreshDio;
  final SecureStore store;

  /// Gọi khi server từ chối refresh token (đã bị thu hồi / hết hạn). KHÔNG gọi khi chỉ mất mạng.
  final Future<void> Function() onForceLogout;

  static const _retryFlag = 'auth_retried';
  static const _refreshAheadOfExpiry = Duration(seconds: 60);

  /// `/v1/auth/**` là public ở backend (login, register, refresh, logout...).
  static bool _isPublic(String path) => path.startsWith('/v1/auth/');

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isPublic(options.path)) return handler.next(options);

    if (options.extra[_retryFlag] != true) {
      final exp = await store.accessTokenExpiresAt();
      final hasRefresh = (await store.refreshToken()) != null;
      if (hasRefresh && exp != null && exp.difference(Clock.now().toUtc()) < _refreshAheadOfExpiry) {
        await _refresh();
      }
    }

    final token = await store.accessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final canRetry = err.response?.statusCode == 401 &&
        !_isPublic(req.path) &&
        req.extra[_retryFlag] != true;
    if (!canRetry) return handler.next(err);

    final current = await store.accessToken();
    final sentWith = req.headers['Authorization'];
    final alreadyRefreshed = current != null && sentWith != 'Bearer $current';

    if (alreadyRefreshed || await _refresh()) {
      try {
        req.extra[_retryFlag] = true;
        return handler.resolve(await dio.fetch(req));
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }

  /// true nếu đã có cặp token mới trong kho.
  Future<bool> _refresh() async {
    final rt = await store.refreshToken();
    if (rt == null) return false;
    try {
      final res = await refreshDio.post<dynamic>(
        '/v1/auth/refresh-token',
        data: {'refreshToken': rt, 'deviceId': await store.deviceId()},
      );
      final data = unwrapEnvelope(res.data) as Map<String, dynamic>;
      await store.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        accessExpiresAt: Clock.now().toUtc().add(Duration(seconds: (data['expiresIn'] as num).toInt())),
      );
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Chỉ khi server TRẢ LỜI là token không dùng được mới đăng xuất.
      // Mất mạng / timeout / 5xx / 429: giữ phiên, để offline-first tiếp tục chạy.
      if (status != null && status >= 400 && status < 500 && status != 429) {
        await onForceLogout();
      }
      return false;
    }
  }
}
