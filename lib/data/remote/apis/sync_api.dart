import '../api_client.dart';

/// §6.11. Rate limit 30 request/phút/user, tính chung push/pull/content.
class SyncApi {
  SyncApi(this._c);

  final ApiClient _c;

  /// `{serverTime, clockOffsetMs, results: [{opId, status, data, errorCode, message}], user}`.
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required DateTime clientSentAt,
    required List<Map<String, dynamic>> operations,
  }) async =>
      await _c.post('/v1/sync/push', body: {
        'deviceId': deviceId,
        'clientSentAt': clientSentAt.toUtc().toIso8601String(),
        'operations': operations,
      }) as Map<String, dynamic>;

  /// Dữ liệu của user: `{cursor, hasMore, changes}`.
  Future<Map<String, dynamic>> pull({String? since, int limit = 500}) async =>
      await _c.get('/v1/sync/pull', query: {'since': ?since, 'limit': limit}) as Map<String, dynamic>;

  /// Nội dung (topics, flashcards, ...): `{cursor, hasMore, changes}`.
  Future<Map<String, dynamic>> content({String? since, int limit = 500}) async =>
      await _c.get('/v1/sync/content', query: {'since': ?since, 'limit': limit}) as Map<String, dynamic>;
}
