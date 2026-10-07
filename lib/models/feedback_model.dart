import '_json.dart';

/// Loại đối tượng được góp ý. `code` khớp `feedbackFor` của backend (1 flashcard, 2 grammar, 3 quiz).
enum FeedbackType {
  flashcard,
  grammar,
  quiz;

  int get code => index + 1;

  static FeedbackType fromCode(int code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    throw ArgumentError.value(code, 'code', 'feedbackFor không hợp lệ');
  }
}

class FeedbackUser {
  final String id;
  final String fullName;
  final String email;

  const FeedbackUser({required this.id, required this.fullName, required this.email});

  factory FeedbackUser.fromJson(Map<String, dynamic> j) =>
      FeedbackUser(id: jStr(j['id']), fullName: jStr(j['fullName']), email: jStr(j['email']));
}

/// Khớp `FeedbackResponse`. Đặt tên khác `Feedback` để khỏi trùng widget `Feedback` của Flutter.
class FeedbackItem {
  final String id;
  final String content;
  final FeedbackType type;
  final String itemId;
  final bool isViewed;
  final DateTime createdAt;

  /// flashcard: từ vựng; grammar: tên bài; quiz: tên topic/grammar mà quiz thuộc về.
  final String itemTitle;

  /// flashcard: tên topic; quiz: tiêu đề quiz.
  final String? parentTitle;
  final String? topicId;
  final String? grammarLessonId;
  final FeedbackUser createdBy;

  const FeedbackItem({
    required this.id,
    required this.content,
    required this.type,
    required this.itemId,
    required this.isViewed,
    required this.createdAt,
    required this.itemTitle,
    this.parentTitle,
    this.topicId,
    this.grammarLessonId,
    required this.createdBy,
  });

  /// Admin đã xem thì user không được sửa / xóa nữa.
  bool get canModify => !isViewed;

  factory FeedbackItem.fromJson(Map<String, dynamic> j) {
    final by = j['createdBy'];
    return FeedbackItem(
      id: jStr(j['id']),
      content: jStr(j['content']),
      type: FeedbackType.fromCode(jInt(j['feedbackFor'])),
      itemId: jStr(j['itemId']),
      isViewed: jBool(j['isViewed']),
      createdAt: jDate(j['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      itemTitle: jStr(j['itemTitle']),
      parentTitle: j['parentTitle'] as String?,
      topicId: j['topicId'] as String?,
      grammarLessonId: j['grammarLessonId'] as String?,
      createdBy: by is Map<String, dynamic>
          ? FeedbackUser.fromJson(by)
          : const FeedbackUser(id: '', fullName: '', email: ''),
    );
  }

  FeedbackItem copyWith({String? content, bool? isViewed}) => FeedbackItem(
        id: id,
        content: content ?? this.content,
        type: type,
        itemId: itemId,
        isViewed: isViewed ?? this.isViewed,
        createdAt: createdAt,
        itemTitle: itemTitle,
        parentTitle: parentTitle,
        topicId: topicId,
        grammarLessonId: grammarLessonId,
        createdBy: createdBy,
      );
}

/// Số góp ý của chính user theo từng loại (`GET /v1/feedbacks/me/summary`).
class FeedbackSummary {
  final int flashcard;
  final int grammar;
  final int quiz;

  const FeedbackSummary({this.flashcard = 0, this.grammar = 0, this.quiz = 0});

  int get total => flashcard + grammar + quiz;

  int countOf(FeedbackType t) => switch (t) {
        FeedbackType.flashcard => flashcard,
        FeedbackType.grammar => grammar,
        FeedbackType.quiz => quiz,
      };

  factory FeedbackSummary.fromJson(Map<String, dynamic> j) =>
      FeedbackSummary(flashcard: jInt(j['flashcard']), grammar: jInt(j['grammar']), quiz: jInt(j['quiz']));
}
