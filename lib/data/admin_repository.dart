import '../models/admin_models.dart';
import '../models/flashcard_model.dart';
import '../models/grammar_model.dart';
import '../models/json_helpers.dart';
import '../models/quiz_model.dart';
import '../models/reward_item_model.dart';
import '../models/topic_model.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'content_repository.dart';

/// Các thao tác quản trị (chỉ tài khoản ADMIN gọi được, online).
class AdminRepository {
  AdminRepository._();

  static ApiClient get _api => ApiClient.I;

  static Future<AdminOverview> overview() async => AdminOverview.fromJson(asMap(await _api.get('/v1/admin/overview')));

  // ------------------------------------------------------------------ người dùng

  /// [role] = 'USER' (học viên) hoặc 'ADMIN' (quản trị viên).
  static Future<PageResult<UserModel>> users({String role = 'USER', String? keyword, int page = 0, int size = 50}) async {
    final data = await _api.get('/v1/users', query: {
      'role': role,
      'keyword': (keyword ?? '').trim().isEmpty ? null : keyword!.trim(),
      'page': page,
      'size': size,
    });
    return PageResult.from(data, UserModel.fromJson);
  }

  static Future<void> createUser(
          {required String fullName, required String email, required String password, required String role, required String level}) =>
      _api.post('/v1/users/create', body: {'fullName': fullName, 'email': email, 'password': password, 'role': role, 'level': level});

  static Future<void> updateUser(String id, {String? fullName, String? level, String? role, String? status}) =>
      _api.put('/v1/users/update/$id', body: {
        'fullName': ?fullName,
        'level': ?level,
        'role': ?role,
        'status': ?status,
      });

  static Future<void> deleteUser(String id) => _api.delete('/v1/users/delete/$id');

  // ------------------------------------------------------------------ từ vựng

  static Future<List<Topic>> topics() => ContentRepository.allPages<Topic>(
      (page) async => PageResult.from(await _api.get('/v1/topics', query: {'includeUnpublished': true, 'page': page, 'size': 100}), Topic.fromJson));

  static Future<void> saveTopic(String? id, Map<String, dynamic> body) =>
      id == null ? _api.post('/v1/topics/create', body: body) : _api.put('/v1/topics/update/$id', body: body);

  static Future<void> deleteTopic(String id) => _api.delete('/v1/topics/delete/$id');

  static Future<List<Flashcard>> flashcards(String topicId) => ContentRepository.flashcards(topicId);

  static Future<void> saveFlashcard(String? id, Map<String, dynamic> body) =>
      id == null ? _api.post('/v1/flashcards/create', body: body) : _api.put('/v1/flashcards/update/$id', body: body);

  static Future<void> deleteFlashcard(String id) => _api.delete('/v1/flashcards/delete/$id');

  // ------------------------------------------------------------------ ngữ pháp

  static Future<List<Grammar>> grammarLessons() => ContentRepository.allPages<Grammar>(
      (page) async => PageResult.from(await _api.get('/v1/grammar', query: {'includeUnpublished': true, 'page': page, 'size': 100}), Grammar.fromJson));

  static Future<GrammarDetail> grammarDetail(String id) => ContentRepository.grammarDetail(id);

  static Future<void> saveGrammar(String? id, Map<String, dynamic> body) =>
      id == null ? _api.post('/v1/grammar/create', body: body) : _api.put('/v1/grammar/update/$id', body: body);

  static Future<void> deleteGrammar(String id) => _api.delete('/v1/grammar/delete/$id');

  // ------------------------------------------------------------------ bài kiểm tra

  static Future<List<QuizInfo>> quizzes() async {
    final data = await _api.get('/v1/quizzes', query: {'includeUnpublished': true});
    return asMapList(data).map(QuizInfo.fromJson).toList();
  }

  static Future<QuizDetail> quizDetail(String id) async => QuizDetail.fromJson(asMap(await _api.get('/v1/quizzes/get/$id')));

  static Future<void> saveQuiz(String? id, Map<String, dynamic> body) =>
      id == null ? _api.post('/v1/quizzes/create', body: body) : _api.put('/v1/quizzes/update/$id', body: body);

  static Future<void> deleteQuiz(String id) => _api.delete('/v1/quizzes/delete/$id');

  // ------------------------------------------------------------------ kinh tế

  static Future<List<RewardItem>> rewardItems() async {
    final data = await _api.get('/v1/shop/items/definitions');
    return asMapList(data).map(RewardItem.fromJson).toList();
  }

  static Future<void> saveRewardItem(String? id, Map<String, dynamic> body) =>
      id == null ? _api.post('/v1/shop/items/create', body: body) : _api.put('/v1/shop/items/update/$id', body: body);

  static Future<void> deleteRewardItem(String id) => _api.delete('/v1/shop/items/delete/$id');

  static Future<List<QuestDefinition>> questDefinitions() async {
    final data = await _api.get('/v1/quests/definitions');
    return asMapList(data).map(QuestDefinition.fromJson).toList();
  }

  static Future<void> saveQuest(String? id, Map<String, dynamic> body) =>
      id == null ? _api.post('/v1/quests/create', body: body) : _api.put('/v1/quests/update/$id', body: body);

  static Future<void> deleteQuest(String id) => _api.delete('/v1/quests/delete/$id');
}
