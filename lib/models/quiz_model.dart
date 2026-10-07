import '_json.dart';

class Quiz {
  final String id;
  final String title;

  /// 'TOPIC' | 'GRAMMAR'
  final String quizType;
  final String? topicId;
  final String? grammarLessonId;  
  final int? timeLimitSeconds;
  final int passScorePercent;
  final int questionCount;
  final bool isPublished;

  const Quiz({
    required this.id,
    required this.title,
    required this.quizType,
    this.topicId,
    this.grammarLessonId,
    this.timeLimitSeconds,
    this.passScorePercent = 70,
    this.questionCount = 0,
    this.isPublished = true,
  });

  factory Quiz.fromJson(Map<String, dynamic> j) => Quiz(
        id: j['id'] as String,
        title: jStr(j['title']),
        quizType: jStr(j['quizType'], 'TOPIC'),
        topicId: j['topicId'] as String?,
        grammarLessonId: j['grammarLessonId'] as String?,
        timeLimitSeconds: jIntN(j['timeLimitSeconds']),
        passScorePercent: jInt(j['passScorePercent'], 70),
        questionCount: jInt(j['questionCount']),
        isPublished: jBool(j['isPublished'], true),
      );
}

class QuizQuestion {
  final String id;
  final String quizId;

  /// null với quiz ngữ pháp.
  final String? topicId;
  final String? flashcardId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int sortOrder;

  const QuizQuestion({
    required this.id,
    required this.quizId,
    this.topicId,
    this.flashcardId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.sortOrder = 0,
  });

  /// `QuizQuestionResponse` (admin).
  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        id: jStr(j['id']),
        quizId: jStr(j['quizId']),
        topicId: j['topicId'] as String?,
        flashcardId: j['flashcardId'] as String?,
        questionText: jStr(j['questionText']),
        options: (j['options'] as List? ?? const []).map((e) => e.toString()).toList(),
        correctAnswerIndex: jInt(j['correctAnswerIndex']),
        explanation: jStr(j['explanation']),
      );
}
