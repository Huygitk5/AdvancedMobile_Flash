class Flashcard {
  final String id;
  final String topicId;
  final String word;
  final String partOfSpeech;
  final String pronunciation;
  final String meaning;
  final String example;
  final String exampleTranslation;

  String? note; // Thêm trường này (cho phép null)

  Flashcard({
    required this.id,
    required this.topicId,
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.meaning,
    required this.example,
    required this.exampleTranslation,
    this.note, // Không bắt buộc
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] ?? '',
      topicId: json['topicId'] ?? '',
      word: json['word'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
      exampleTranslation: json['exampleTranslation'] ?? '',
      note: json['note'],
    );
  }
}