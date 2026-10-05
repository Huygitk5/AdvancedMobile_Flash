import '../../../models/flashcard_model.dart';
import '../../../models/grammar_model.dart';
import '../../../models/quest_definition_model.dart';
import '../../../models/quiz_model.dart';
import '../../../models/reward_item_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/user_model.dart';
import '../api_client.dart';
import '../dto/page_dto.dart';

/// Mọi endpoint `[ADMIN]` (Swagger). Admin chỉ chạy online, không ghi SQLite.
class AdminApi {
  AdminApi(this._c);

  final ApiClient _c;

  // ---- users
  Future<PageDto<UserModel>> users({String? keyword, String? status, int page = 0, int size = 20}) => _c.getPage(
        '/v1/users',
        UserModel.fromJson,
        query: {'keyword': ?keyword, 'status': ?status, 'page': page, 'size': size},
      );

  Future<UserModel> createUser(Map<String, dynamic> body) async =>
      UserModel.fromJson(await _c.post('/v1/users/create', body: body) as Map<String, dynamic>);

  Future<UserModel> updateUser(String id, Map<String, dynamic> body) async =>
      UserModel.fromJson(await _c.put('/v1/users/update/$id', body: body) as Map<String, dynamic>);

  Future<void> deleteUser(String id) => _c.delete('/v1/users/delete/$id');

  // ---- topics
  Future<PageDto<Topic>> topics({String? keyword, int page = 0, int size = 100}) => _c.getPage(
        '/v1/topics',
        Topic.fromJson,
        query: {'keyword': ?keyword, 'includeUnpublished': true, 'page': page, 'size': size},
      );

  Future<void> createTopic(Map<String, dynamic> body) => _c.post('/v1/topics/create', body: body);
  Future<void> updateTopic(String id, Map<String, dynamic> body) => _c.put('/v1/topics/update/$id', body: body);
  Future<void> deleteTopic(String id) => _c.delete('/v1/topics/delete/$id');

  // ---- flashcards
  Future<List<Flashcard>> flashcards(String topicId) async =>
      (await _c.get('/v1/flashcards', query: {'topicId': topicId}) as List)
          .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList();

  Future<void> createFlashcard(Map<String, dynamic> body) => _c.post('/v1/flashcards/create', body: body);
  Future<void> updateFlashcard(String id, Map<String, dynamic> body) => _c.put('/v1/flashcards/update/$id', body: body);
  Future<void> deleteFlashcard(String id) => _c.delete('/v1/flashcards/delete/$id');

  // ---- grammar
  Future<PageDto<Grammar>> grammar({String? keyword, int page = 0, int size = 100}) => _c.getPage(
        '/v1/grammar',
        Grammar.fromJson,
        query: {'keyword': ?keyword, 'includeUnpublished': true, 'page': page, 'size': size},
      );

  Future<GrammarDetail> grammarDetail(String id) async =>
      GrammarDetail.fromJson(await _c.get('/v1/grammar/get/$id') as Map<String, dynamic>);

  Future<void> createGrammar(Map<String, dynamic> body) => _c.post('/v1/grammar/create', body: body);

  /// Server THAY TOÀN BỘ danh sách ví dụ bằng `examples` gửi lên.
  Future<void> updateGrammar(String id, Map<String, dynamic> body) => _c.put('/v1/grammar/update/$id', body: body);
  Future<void> deleteGrammar(String id) => _c.delete('/v1/grammar/delete/$id');

  // ---- quizzes
  Future<List<Quiz>> quizzes() async => (await _c.get('/v1/quizzes', query: {'includeUnpublished': true}) as List)
      .map((e) => Quiz.fromJson(e as Map<String, dynamic>))
      .toList();

  /// `{quiz, questions}`.
  Future<({Quiz quiz, List<QuizQuestion> questions})> quizDetail(String id) async {
    final j = await _c.get('/v1/quizzes/get/$id') as Map<String, dynamic>;
    return (
      quiz: Quiz.fromJson(j['quiz'] as Map<String, dynamic>),
      questions: (j['questions'] as List? ?? const [])
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> createQuiz(Map<String, dynamic> body) => _c.post('/v1/quizzes/create', body: body);

  /// Server THAY TOÀN BỘ câu hỏi bằng `questions` gửi lên.
  Future<void> updateQuiz(String id, Map<String, dynamic> body) => _c.put('/v1/quizzes/update/$id', body: body);
  Future<void> deleteQuiz(String id) => _c.delete('/v1/quizzes/delete/$id');

  // ---- economy
  Future<List<RewardItem>> rewardItems() async => (await _c.get('/v1/shop/items/definitions') as List)
      .map((e) => RewardItem.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<void> createRewardItem(Map<String, dynamic> body) => _c.post('/v1/shop/items/create', body: body);
  Future<void> updateRewardItem(String id, Map<String, dynamic> body) => _c.put('/v1/shop/items/update/$id', body: body);

  /// Gỡ khỏi shop (kho đồ của user vẫn giữ).
  Future<void> deleteRewardItem(String id) => _c.delete('/v1/shop/items/delete/$id');

  Future<List<QuestDefinition>> questDefinitions() async => (await _c.get('/v1/quests/definitions') as List)
      .map((e) => QuestDefinition.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<void> createQuest(Map<String, dynamic> body) => _c.post('/v1/quests/create', body: body);
  Future<void> updateQuest(String id, Map<String, dynamic> body) => _c.put('/v1/quests/update/$id', body: body);
  Future<void> deleteQuest(String id) => _c.delete('/v1/quests/delete/$id');
}
