class Grammar {
  final String id;
  final String title;
  final double progress;
  final String status;
  // Lưu ý: Backend API thường không trả về IconData (lớp riêng của Flutter),
  // API sẽ trả về chuỗi (vd: "access_alarm") và bạn mapping nó trên Flutter.
  final String iconName;

  Grammar({
    required this.id,
    required this.title,
    required this.progress,
    required this.status,
    required this.iconName,
  });

  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      iconName: json['iconName'] ?? '',
    );
  }
}