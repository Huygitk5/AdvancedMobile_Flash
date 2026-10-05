import 'json_helpers.dart';

class Flashcard {
  final String id;
  final String topicId;
  final String word;
  final String partOfSpeech;
  final String pronunciation;
  final String meaning;
  final String example;
  final String exampleTranslation;
  final String? audioUrl;
  final int sortOrder;
  bool isBookmarked;
  bool isLearned;
  int srsBox;

  /// Ghi chú cá nhân của user cho từ này.
  String? note;
  int? noteVersion;

  Flashcard({
    required this.id,
    required this.topicId,
    required this.word,
    this.partOfSpeech = '',
    this.pronunciation = '',
    this.meaning = '',
    this.example = '',
    this.exampleTranslation = '',
    this.audioUrl,
    this.sortOrder = 0,
    this.isBookmarked = false,
    this.isLearned = false,
    this.srsBox = 0,
    this.note,
    this.noteVersion,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: jStr(json, 'id'),
      topicId: jStr(json, 'topicId'),
      word: jStr(json, 'word'),
      partOfSpeech: jStr(json, 'partOfSpeech'),
      pronunciation: jStr(json, 'pronunciation'),
      meaning: jStr(json, 'meaning'),
      example: jStr(json, 'example'),
      exampleTranslation: jStr(json, 'exampleTranslation'),
      audioUrl: jStrOrNull(json, 'audioUrl'),
      sortOrder: jInt(json, 'sortOrder'),
      isBookmarked: jBool(json, 'isBookmarked'),
      isLearned: jBool(json, 'isLearned'),
      srsBox: jInt(json, 'srsBox'),
      note: jStrOrNull(json, 'note'),
      noteVersion: json['noteVersion'] == null ? null : jInt(json, 'noteVersion'),
    );
  }
}
