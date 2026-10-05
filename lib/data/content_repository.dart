import '../models/flashcard_model.dart';
import '../models/grammar_model.dart';
import '../models/json_helpers.dart';
import '../models/quiz_model.dart';
import '../models/topic_model.dart';
import 'api/api_client.dart';

/// Trang kết quả phân trang: `{items, page, size, totalElements, totalPages}`.
class PageResult<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalElements;

  const PageResult(this.items, {this.page = 0, this.totalPages = 1, this.totalElements = 0});

  factory PageResult.from(dynamic data, T Function(Map<String, dynamic>) parse) {
    final map = asMap(data);
    return PageResult(
      jList(map, 'items').map(parse).toList(),
      page: jInt(map, 'page'),
      totalPages: jInt(map, 'totalPages', 1),
      totalElements: jInt(map, 'totalElements'),
    );
  }
}

/// Bộ lọc tiến độ của danh sách chủ đề / ngữ pháp, khớp ProgressFilter của server.
enum ProgressFilter { all, notStarted, inProgress, completed }

String _filterValue(ProgressFilter f) {
  switch (f) {
    case ProgressFilter.notStarted:
      return 'NOT_STARTED';
    case ProgressFilter.inProgress:
      return 'IN_PROGRESS';
    case ProgressFilter.completed:
      return 'COMPLETED';
    case ProgressFilter.all:
      return 'ALL';
  }
}

class ContentRepository {
  ContentRepository._();

  static ApiClient get _api => ApiClient.I;

  static Future<PageResult<Topic>> topics(
      {ProgressFilter status = ProgressFilter.all, String? keyword, int page = 0, int size = 50}) async {
    final data = await _api.get('/v1/topics', query: {
      'status': _filterValue(status),
      'keyword': (keyword ?? '').trim().isEmpty ? null : keyword!.trim(),
      'page': page,
      'size': size,
    });
    return PageResult.from(data, Topic.fromJson);
  }

  static Future<Topic> topic(String id) async => Topic.fromJson(asMap(await _api.get('/v1/topics/get/$id')));

  static Future<PageResult<Grammar>> grammarLessons(
      {ProgressFilter status = ProgressFilter.all, String? keyword, int page = 0, int size = 50}) async {
    final data = await _api.get('/v1/grammar', query: {
      'status': _filterValue(status),
      'keyword': (keyword ?? '').trim().isEmpty ? null : keyword!.trim(),
      'page': page,
      'size': size,
    });
    return PageResult.from(data, Grammar.fromJson);
  }

  static Future<GrammarDetail> grammarDetail(String id) async =>
      GrammarDetail.fromJson(asMap(await _api.get('/v1/grammar/get/$id')));

  static Future<List<Flashcard>> flashcards(String topicId) async {
    final data = await _api.get('/v1/flashcards', query: {'topicId': topicId});
    return asMapList(data).map(Flashcard.fromJson).toList();
  }

  /// Thẻ đến hạn ôn lại (SRS), hạn sớm nhất trước.
  static Future<List<Flashcard>> dueFlashcards({String? topicId, int limit = 20}) async {
    final data = await _api.get('/v1/flashcards/due', query: {'topicId': topicId, 'limit': limit});
    return asMapList(data).map(Flashcard.fromJson).toList();
  }

  static Future<PageResult<Flashcard>> bookmarks({int page = 0, int size = 50}) async {
    final data = await _api.get('/v1/flashcards/bookmarks', query: {'page': page, 'size': size});
    return PageResult.from(data, Flashcard.fromJson);
  }

  /// Tìm từ vựng theo từ khoá (khớp từ hoặc nghĩa).
  static Future<PageResult<Flashcard>> searchFlashcards(String keyword, {int page = 0, int size = 20}) async {
    final data = await _api.get('/v1/flashcards/search', query: {'keyword': keyword.trim(), 'page': page, 'size': size});
    return PageResult.from(data, Flashcard.fromJson);
  }

  /// Tải hết các trang của một danh sách phân trang (tối đa [maxPages] trang để không kéo quá nhiều).
  static Future<List<T>> allPages<T>(Future<PageResult<T>> Function(int page) fetch, {int maxPages = 5}) async {
    final all = <T>[];
    for (var page = 0; page < maxPages; page++) {
      final result = await fetch(page);
      all.addAll(result.items);
      if (page + 1 >= result.totalPages) break;
    }
    return all;
  }

  static Future<List<QuizInfo>> quizzesOfTopic(String topicId) async {
    final data = await _api.get('/v1/quizzes', query: {'topicId': topicId});
    return asMapList(data).map(QuizInfo.fromJson).toList();
  }

  static Future<List<QuizInfo>> quizzesOfGrammar(String grammarLessonId) async {
    final data = await _api.get('/v1/quizzes', query: {'grammarLessonId': grammarLessonId});
    return asMapList(data).map(QuizInfo.fromJson).toList();
  }

  static Future<QuizDetail> quiz(String id) async => QuizDetail.fromJson(asMap(await _api.get('/v1/quizzes/get/$id')));
}
