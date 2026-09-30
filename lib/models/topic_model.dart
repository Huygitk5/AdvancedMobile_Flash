class Topic {
  final String id;
  final String title;
  final int totalWords;
  final double progress;
  final String iconPath;

  Topic({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.progress,
    required this.iconPath,
  });

  // Chuyển JSON từ API thành Object
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      totalWords: json['totalWords'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
      iconPath: json['iconPath'] ?? '',
    );
  }
}