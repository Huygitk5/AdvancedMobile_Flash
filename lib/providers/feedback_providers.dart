import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/apis/feedback_api.dart';
import '../data/remote/dto/page_dto.dart';
import '../models/feedback_model.dart';
import 'providers.dart';

export '../data/remote/apis/feedback_api.dart' show FeedbackApi;
export '../models/feedback_model.dart';
export 'providers.dart' show feedbackApiProvider;

const _unset = Object();

/// Bộ lọc danh sách góp ý (user và admin dùng chung). Bất biến, so sánh theo giá trị để làm khoá của family.
/// [isViewed] chỉ có nghĩa với admin; API của user bỏ qua.
class FeedbackFilter {
  const FeedbackFilter({this.type, this.isViewed, this.from, this.to});

  final FeedbackType? type;
  final bool? isViewed;
  final DateTime? from;
  final DateTime? to;

  bool get isEmpty => type == null && isViewed == null && from == null && to == null;

  /// Truyền `null` để xóa một điều kiện, bỏ qua tham số để giữ nguyên.
  FeedbackFilter copyWith({
    Object? type = _unset,
    Object? isViewed = _unset,
    Object? from = _unset,
    Object? to = _unset,
  }) =>
      FeedbackFilter(
        type: identical(type, _unset) ? this.type : type as FeedbackType?,
        isViewed: identical(isViewed, _unset) ? this.isViewed : isViewed as bool?,
        from: identical(from, _unset) ? this.from : from as DateTime?,
        to: identical(to, _unset) ? this.to : to as DateTime?,
      );

  @override
  bool operator ==(Object other) =>
      other is FeedbackFilter && other.type == type && other.isViewed == isViewed && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(type, isViewed, from, to);
}

/// Trạng thái danh sách phân trang tải-thêm.
class FeedbackListState {
  const FeedbackListState({
    this.items = const [],
    this.page = -1,
    this.hasMore = false,
    this.loading = true,
    this.loadingMore = false,
    this.error,
    this.totalElements = 0,
  });

  final List<FeedbackItem> items;

  /// Trang đã tải gần nhất (-1 = chưa có).
  final int page;
  final bool hasMore;

  /// Đang tải trang đầu / làm mới.
  final bool loading;
  final bool loadingMore;

  /// Lỗi của lần tải gần nhất (null = ổn).
  final Object? error;
  final int totalElements;

  FeedbackListState copyWith({
    List<FeedbackItem>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error = _unset,
    int? totalElements,
  }) =>
      FeedbackListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: identical(error, _unset) ? this.error : error,
        totalElements: totalElements ?? this.totalElements,
      );
}

const feedbackPageSize = 20;

/// Nền chung: tự tải trang đầu khi được watch, `loadMore()` nối trang kế, `refresh()` tải lại từ đầu.
abstract class FeedbackListNotifier extends Notifier<FeedbackListState> {
  FeedbackListNotifier(this.filter);

  final FeedbackFilter filter;

  /// Mỗi lần refresh tăng lên để bỏ kết quả của request cũ về muộn.
  int _gen = 0;

  Future<PageDto<FeedbackItem>> fetch(FeedbackApi api, int page);

  @override
  FeedbackListState build() {
    Future.microtask(refresh);
    return const FeedbackListState();
  }

  /// Giữ danh sách đang hiển thị trong lúc tải lại (cho RefreshIndicator).
  Future<void> refresh() async {
    final gen = ++_gen;
    if (!ref.mounted) return;
    state = state.copyWith(loading: true, loadingMore: false, error: null);
    try {
      final p = await fetch(ref.read(feedbackApiProvider), 0);
      if (!ref.mounted || gen != _gen) return;
      state = FeedbackListState(
        items: p.items,
        page: 0,
        hasMore: !p.isLast && p.items.isNotEmpty,
        loading: false,
        totalElements: p.totalElements,
      );
    } catch (e) {
      if (!ref.mounted || gen != _gen) return;
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s.loading || s.loadingMore || !s.hasMore) return;
    final gen = _gen;
    state = s.copyWith(loadingMore: true, error: null);
    try {
      final p = await fetch(ref.read(feedbackApiProvider), s.page + 1);
      if (!ref.mounted || gen != _gen) return;
      state = state.copyWith(
        items: [...state.items, ...p.items],
        page: s.page + 1,
        hasMore: !p.isLast && p.items.isNotEmpty,
        loadingMore: false,
        totalElements: p.totalElements,
      );
    } catch (e) {
      if (!ref.mounted || gen != _gen) return;
      state = state.copyWith(loadingMore: false, error: e);
    }
  }

  /// Thay một góp ý trong danh sách (sau sửa / đổi trạng thái đã xem).
  void replace(FeedbackItem item) {
    state = state.copyWith(items: [for (final e in state.items) e.id == item.id ? item : e]);
  }

  void remove(String id) {
    final left = state.items.where((e) => e.id != id).toList();
    state = state.copyWith(items: left, totalElements: state.totalElements > 0 ? state.totalElements - 1 : 0);
  }
}

/// Danh sách góp ý của chính user (`type`, `from`, `to`).
class MyFeedbackListNotifier extends FeedbackListNotifier {
  MyFeedbackListNotifier(super.filter);

  @override
  Future<PageDto<FeedbackItem>> fetch(FeedbackApi api, int page) =>
      api.myFeedbacks(type: filter.type, from: filter.from, to: filter.to, page: page, size: feedbackPageSize);
}

/// Danh sách góp ý của mọi user cho admin (thêm `isViewed`).
class AdminFeedbackListNotifier extends FeedbackListNotifier {
  AdminFeedbackListNotifier(super.filter);

  @override
  Future<PageDto<FeedbackItem>> fetch(FeedbackApi api, int page) => api.adminList(
        type: filter.type,
        isViewed: filter.isViewed,
        from: filter.from,
        to: filter.to,
        page: page,
        size: feedbackPageSize,
      );
}

final myFeedbackListProvider = NotifierProvider.autoDispose
    .family<MyFeedbackListNotifier, FeedbackListState, FeedbackFilter>(MyFeedbackListNotifier.new);

final adminFeedbackListProvider = NotifierProvider.autoDispose
    .family<AdminFeedbackListNotifier, FeedbackListState, FeedbackFilter>(AdminFeedbackListNotifier.new);

/// Số góp ý của user theo loại. `ref.invalidate` sau khi gửi / sửa / xóa.
final feedbackSummaryProvider =
    FutureProvider.autoDispose<FeedbackSummary>((ref) => ref.watch(feedbackApiProvider).mySummary());
