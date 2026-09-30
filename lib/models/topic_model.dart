class Topic {
  final String id;
  final String title;
  final int totalWords;
  final double progress; // 0.0 đến 1.0
  final String iconPath;

  Topic({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.progress,
    required this.iconPath,
  });
}