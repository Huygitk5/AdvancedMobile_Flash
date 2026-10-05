import 'json_helpers.dart';

/// Thông tin tóm tắt của một bài kiểm tra (danh sách bài kiểm tra của chủ đề / chủ điểm).
class QuizInfo {
  final String id;
  final String title;
  final String quizType; // TOPIC | GRAMMAR
  final String? topicId;
  final String? grammarLessonId;
  final int? timeLimitSeconds;
  final int passScorePercent;
  final int questionCount;

  const QuizInfo({
    required this.id,
    required this.title,
    this.quizType = 'TOPIC',
    this.topicId,
    this.grammarLessonId,
    this.timeLimitSeconds,
    this.passScorePercent = 70,
    this.questionCount = 0,
  });

  factory QuizInfo.fromJson(Map<String, dynamic> json) => QuizInfo(
        id: jStr(json, 'id'),
        title: jStr(json, 'title'),
        quizType: jStr(json, 'quizType', 'TOPIC'),
        topicId: jStrOrNull(json, 'topicId'),
        grammarLessonId: jStrOrNull(json, 'grammarLessonId'),
        timeLimitSeconds: json['timeLimitSeconds'] == null ? null : jInt(json, 'timeLimitSeconds'),
        passScorePercent: jInt(json, 'passScorePercent', 70),
        questionCount: jInt(json, 'questionCount'),
      );
}

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  /// Từ vựng mà câu hỏi được sinh ra từ đó (nếu có); admin cần giữ lại khi sửa đề.
  final String? flashcardId;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.flashcardId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: jStr(json, 'id'),
        questionText: jStr(json, 'questionText'),
        options: (json['options'] is List) ? (json['options'] as List).map((e) => '$e').toList() : const [],
        correctAnswerIndex: jInt(json, 'correctAnswerIndex'),
        explanation: jStr(json, 'explanation'),
        flashcardId: jStrOrNull(json, 'flashcardId'),
      );
}

class QuizDetail {
  final QuizInfo quiz;
  final List<QuizQuestion> questions;

  const QuizDetail({required this.quiz, required this.questions});

  factory QuizDetail.fromJson(Map<String, dynamic> json) => QuizDetail(
        quiz: QuizInfo.fromJson(asMap(json['quiz'])),
        questions: jList(json, 'questions').map(QuizQuestion.fromJson).toList(),
      );
}

/// Kết quả một lần làm bài (do server chấm).
class QuizResult {
  final String id;
  final String quizId;
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int scorePercent;
  final bool passed;
  final int timeTakenSeconds;
  final List<String> wrongQuestionIds;
  final int xpAwarded;

  const QuizResult({
    required this.id,
    this.quizId = '',
    this.quizTitle = '',
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.scorePercent = 0,
    this.passed = false,
    this.timeTakenSeconds = 0,
    this.wrongQuestionIds = const [],
    this.xpAwarded = 0,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        id: jStr(json, 'id'),
        quizId: jStr(json, 'quizId'),
        quizTitle: jStr(json, 'quizTitle'),
        totalQuestions: jInt(json, 'totalQuestions'),
        correctAnswers: jInt(json, 'correctAnswers'),
        wrongAnswers: jInt(json, 'wrongAnswers'),
        scorePercent: jInt(json, 'scorePercent'),
        passed: jBool(json, 'passed'),
        timeTakenSeconds: jInt(json, 'timeTakenSeconds'),
        wrongQuestionIds: (json['wrongQuestionIds'] is List) ? (json['wrongQuestionIds'] as List).map((e) => '$e').toList() : const [],
        xpAwarded: jInt(json, 'xpAwarded'),
      );
}

class QuizReviewItem {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int userIndex; // -1 nếu bỏ qua
  final String explanation;

  const QuizReviewItem({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.userIndex,
    this.explanation = '',
  });

  bool get isCorrect => userIndex == correctIndex;

  factory QuizReviewItem.fromJson(Map<String, dynamic> json) => QuizReviewItem(
        id: jStr(json, 'id'),
        question: jStr(json, 'question'),
        options: (json['options'] is List) ? (json['options'] as List).map((e) => '$e').toList() : const [],
        correctIndex: jInt(json, 'correctIndex'),
        userIndex: jInt(json, 'userIndex', -1),
        explanation: jStr(json, 'explanation'),
      );
}
