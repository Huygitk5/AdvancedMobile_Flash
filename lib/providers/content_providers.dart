import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/daos/content_dao.dart';
import '../models/flashcard_model.dart';
import '../models/grammar_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import '../models/quiz_review_model.dart';
import '../models/saved_word_topic_model.dart';
import '../models/topic_model.dart';
import 'providers.dart';

typedef ListQuery = ({ProgressFilter filter, String keyword});
typedef SavedWordsQuery = ({String? topicId, String keyword});

final topicsProvider = StreamProvider.autoDispose.family<List<Topic>, ListQuery>(
  (ref, q) => ref.watch(dbProvider).contentDao.watchTopicsWithProgress(filter: q.filter, keyword: q.keyword),
);

final grammarListProvider = StreamProvider.autoDispose.family<List<Grammar>, ListQuery>(
  (ref, q) => ref.watch(dbProvider).contentDao.watchGrammarWithProgress(filter: q.filter, keyword: q.keyword),
);

/// Từ đã lưu (màn "Từ đã lưu" ở Cá nhân).
final bookmarkedCardsProvider = StreamProvider.autoDispose<List<Flashcard>>(
  (ref) => ref.watch(dbProvider).contentDao.watchBookmarkedCards(),
);

/// Các topic có từ đã lưu, kèm số lượng từ mỗi topic.
final savedWordTopicsProvider =
    StreamProvider.autoDispose<List<SavedWordTopic>>(
      (ref) => ref.watch(dbProvider).contentDao.watchBookmarkedTopicSummaries(),
    );

/// Từ đã lưu sau khi lọc theo topic / keyword.
final filteredBookmarkedCardsProvider = StreamProvider.autoDispose
    .family<List<Flashcard>, SavedWordsQuery>(
      (ref, q) => ref
          .watch(dbProvider)
          .contentDao
          .watchBookmarkedCards(topicId: q.topicId, keyword: q.keyword),
    );

/// Từ vựng khớp từ khoá (từ hoặc nghĩa), tối đa 10 kết quả.
final searchCardsProvider = StreamProvider.autoDispose.family<List<Flashcard>, String>(
  (ref, keyword) => ref.watch(dbProvider).contentDao.watchSearchCards(keyword),
);

final topicProvider = StreamProvider.autoDispose.family<Topic?, String>(
  (ref, id) => ref.watch(dbProvider).contentDao.watchTopic(id),
);

/// Thẻ của topic (thẻ đến hạn trước), kèm SRS + ghi chú + bookmark.
final cardsProvider = StreamProvider.autoDispose.family<List<Flashcard>, String>(
  (ref, topicId) => ref.watch(dbProvider).contentDao.watchCards(topicId),
);

final grammarDetailProvider = StreamProvider.autoDispose.family<GrammarDetail?, String>(
  (ref, id) => ref.watch(dbProvider).contentDao.watchGrammar(id),
);

final topicQuizProvider = StreamProvider.autoDispose.family<Quiz?, String>(
  (ref, topicId) => ref.watch(dbProvider).contentDao.watchQuizForTopic(topicId),
);

/// Mọi bài kiểm tra (có câu hỏi) của một topic.
final topicQuizzesProvider = StreamProvider.autoDispose.family<List<Quiz>, String>(
  (ref, topicId) => ref
      .watch(dbProvider)
      .contentDao
      .watchQuizzesForTopic(topicId)
      .map((qs) => qs.where((q) => q.questionCount > 0).toList()),
);

/// Đề + câu hỏi (4 đáp án) của một quiz.
final quizContentProvider = FutureProvider.autoDispose.family<({Quiz? quiz, List<QuizQuestion> questions}), String>(
  (ref, quizId) async {
    final dao = ref.watch(dbProvider).contentDao;
    return (quiz: await dao.quiz(quizId), questions: await dao.questionsWithOptions(quizId));
  },
);

/// Dòng `quiz_attempts`: tự cập nhật khi server chấm lại (xpAwarded). null = bị từ chối khi đồng bộ.
final quizAttemptProvider = StreamProvider.autoDispose.family<QuizResult?, String>(
  (ref, attemptId) => ref.watch(dbProvider).quizDao.watchAttempt(attemptId),
);

final quizReviewProvider = FutureProvider.autoDispose.family<List<QuizReviewItem>, String>(
  (ref, attemptId) => ref.watch(dbProvider).quizDao.reviewItems(attemptId),
);
