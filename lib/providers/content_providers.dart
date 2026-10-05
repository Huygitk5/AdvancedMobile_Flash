import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/daos/content_dao.dart';
import '../models/flashcard_model.dart';
import '../models/grammar_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import '../models/quiz_review_model.dart';
import '../models/topic_model.dart';
import 'providers.dart';

typedef ListQuery = ({ProgressFilter filter, String keyword});

final topicsProvider = StreamProvider.autoDispose.family<List<Topic>, ListQuery>(
  (ref, q) => ref.watch(dbProvider).contentDao.watchTopicsWithProgress(filter: q.filter, keyword: q.keyword),
);

final grammarListProvider = StreamProvider.autoDispose.family<List<Grammar>, ListQuery>(
  (ref, q) => ref.watch(dbProvider).contentDao.watchGrammarWithProgress(filter: q.filter, keyword: q.keyword),
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
