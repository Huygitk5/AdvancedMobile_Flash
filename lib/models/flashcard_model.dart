import '_json.dart';

class Flashcard {
  final String id;
  final String topicId;
  final String word;
  final String partOfSpeech;
  final String pronunciation;
  final String meaning;
  final String? example;
  final String? exampleTranslation;
  final String? audioUrl;
  final String? imageUrl;
  final int sortOrder;

  // --- trạng thái của user (user_flashcard_notes / user_bookmarks / user_flashcard_progress) ---
  final String? note;
  final String? noteId;
  final int noteVersion;
  final bool isBookmarked;
  final int srsBox;
  final bool isLearned;
  final DateTime? dueAt;

  const Flashcard({
    required this.id,
    required this.topicId,
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.meaning,
    this.example,
    this.exampleTranslation,
    this.audioUrl,
    this.imageUrl,
    this.sortOrder = 0,
    this.note,
    this.noteId,
    this.noteVersion = 0,
    this.isBookmarked = false,
    this.srsBox = 0,
    this.isLearned = false,
    this.dueAt,
  });

  bool get hasNote => note != null && note!.isNotEmpty;

  /// `FlashcardResponse` (admin).
  factory Flashcard.fromJson(Map<String, dynamic> j) => Flashcard(
        id: j['id'] as String,
        topicId: jStr(j['topicId']),
        word: jStr(j['word']),
        partOfSpeech: jStr(j['partOfSpeech']),
        pronunciation: jStr(j['pronunciation']),
        meaning: jStr(j['meaning']),
        example: j['example'] as String?,
        exampleTranslation: j['exampleTranslation'] as String?,
        audioUrl: j['audioUrl'] as String?,
        imageUrl: j['imageUrl'] as String?,
        sortOrder: jInt(j['sortOrder']),
      );
}
