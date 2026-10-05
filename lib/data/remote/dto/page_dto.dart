/// `{items, page, size, totalElements, totalPages}` của mọi danh sách phân trang.
class PageDto<T> {
  const PageDto({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  bool get isLast => page + 1 >= totalPages;

  factory PageDto.fromJson(Map<String, dynamic> j, T Function(Map<String, dynamic>) itemFromJson) {
    return PageDto(
      items: (j['items'] as List? ?? const [])
          .map((e) => itemFromJson(e as Map<String, dynamic>))
          .toList(),
      page: (j['page'] ?? 0) as int,
      size: (j['size'] ?? 0) as int,
      totalElements: (j['totalElements'] ?? 0) as int,
      totalPages: (j['totalPages'] ?? 0) as int,
    );
  }
}
