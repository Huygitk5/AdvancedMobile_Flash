import '../../../models/feedback_model.dart';
import '../api_client.dart';
import '../dto/page_dto.dart';

/// Ngày gửi lên server dạng `yyyy-MM-dd` (theo ngày địa phương người dùng chọn).
String feedbackDateParam(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Query chung của danh sách góp ý (user và admin); tham số null thì bỏ khỏi query.
Map<String, dynamic> feedbackListQuery({
  FeedbackType? type,
  bool? isViewed,
  DateTime? from,
  DateTime? to,
  int page = 0,
  int size = 20,
}) =>
    {
      'feedbackFor': ?type?.code,
      'isViewed': ?isViewed,
      'from': ?(from == null ? null : feedbackDateParam(from)),
      'to': ?(to == null ? null : feedbackDateParam(to)),
      'page': page,
      'size': size,
    };

/// Góp ý của user (§feedbacks) và màn quản lý của admin. Chỉ chạy online, không ghi SQLite.
class FeedbackApi {
  FeedbackApi(this._c);

  final ApiClient _c;

  // ---- user
  Future<FeedbackItem> create({required FeedbackType type, required String itemId, required String content}) async =>
      FeedbackItem.fromJson(await _c.post('/v1/feedbacks/create', body: {
        'feedbackFor': type.code,
        'itemId': itemId,
        'content': content,
      }) as Map<String, dynamic>);

  Future<PageDto<FeedbackItem>> myFeedbacks({
    FeedbackType? type,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int size = 20,
  }) =>
      _c.getPage(
        '/v1/feedbacks/me',
        FeedbackItem.fromJson,
        query: feedbackListQuery(type: type, from: from, to: to, page: page, size: size),
      );

  Future<FeedbackSummary> mySummary() async =>
      FeedbackSummary.fromJson(await _c.get('/v1/feedbacks/me/summary') as Map<String, dynamic>);

  /// Lỗi `FEEDBACK_ALREADY_VIEWED` (409) nếu admin đã xem.
  Future<FeedbackItem> update(String id, String content) async =>
      FeedbackItem.fromJson(await _c.put('/v1/feedbacks/update/$id', body: {'content': content}) as Map<String, dynamic>);

  /// Lỗi `FEEDBACK_ALREADY_VIEWED` (409) nếu admin đã xem.
  Future<void> delete(String id) => _c.delete('/v1/feedbacks/delete/$id');

  // ---- admin
  Future<PageDto<FeedbackItem>> adminList({
    FeedbackType? type,
    bool? isViewed,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int size = 20,
  }) =>
      _c.getPage(
        '/v1/feedbacks',
        FeedbackItem.fromJson,
        query: feedbackListQuery(type: type, isViewed: isViewed, from: from, to: to, page: page, size: size),
      );

  Future<FeedbackItem> setViewed(String id, bool isViewed) async =>
      FeedbackItem.fromJson(await _c.put('/v1/feedbacks/$id/viewed', body: {'isViewed': isViewed}) as Map<String, dynamic>);
}
