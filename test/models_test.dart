import 'package:flash/models/daily_statistic_model.dart';
import 'package:flash/models/flashcard_model.dart';
import 'package:flash/models/grammar_model.dart';
import 'package:flash/models/leaderboard_model.dart';
import 'package:flash/models/lesson_model.dart';
import 'package:flash/models/quest_model.dart';
import 'package:flash/models/quiz_model.dart';
import 'package:flash/models/reward_item_model.dart';
import 'package:flash/models/topic_model.dart';
import 'package:flash/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  test('UserModel đọc đủ trường và áp UserSnapshot của server', () {
    final user = UserModel.fromJson(userJson());
    expect(user.fullName, startsWith('Nguyễn'));
    expect(user.isAdmin, isFalse);
    expect(user.currentXp, 120);

    final updated = user.applySnapshot({'currentXp': 127, 'totalLifetimeXp': 567, 'streakDays': 4, 'longestStreak': 9, 'totalWordsLearned': 43, 'completedLessons': 7});
    expect(updated.currentXp, 127);
    expect(updated.totalWordsLearned, 43);
    expect(updated.streakDays, 4);
    expect(updated.slogan, user.slogan); // trường không có trong snapshot giữ nguyên
  });

  test('UserModel thiếu trường không làm app lỗi', () {
    final user = UserModel.fromJson({'id': 'x', 'fullName': 'A', 'email': 'a@b.c'});
    expect(user.level, 'A1');
    expect(user.role, 'USER');
    expect(user.currentXp, 0);
  });

  test('Topic, Grammar, Flashcard', () {
    final topic = Topic.fromJson(topicJson('t1', 'Daily Life', words: 28, progress: 0.5));
    expect(topic.totalWords, 28);
    expect(topic.progress, 0.5);
    expect(topic.status, 'IN_PROGRESS');

    final grammar = Grammar.fromJson(grammarJson('g1', 'Present Simple', progress: 1, status: 'COMPLETED'));
    expect(grammar.status, 'COMPLETED');
    expect(grammar.structure, 'S + V(s/es) + O');

    final card = Flashcard.fromJson({...flashcardJson('f1', 'apple'), 'note': 'ghi chú', 'noteVersion': 3, 'isBookmarked': true});
    expect(card.note, 'ghi chú');
    expect(card.noteVersion, 3);
    expect(card.isBookmarked, isTrue);
  });

  test('GrammarDetail', () {
    // Dạng phẳng như server trả: trường của chủ điểm cùng cấp với content / examples / quizId
    final detail = GrammarDetail.fromJson({
      ...grammarJson('g1', 'Present Simple'),
      'content': 'Dòng 1\nDòng 2',
      'usageNotes': 'Lưu ý',
      'quizId': 'q1',
      'examples': [
        {'id': 'e1', 'sentence': 'She goes to school.', 'translation': 'Cô ấy đi học.', 'highlight': 'goes'}
      ],
    });
    expect(detail.summary.title, 'Present Simple');
    expect(detail.examples.single.highlight, 'goes');
    expect(detail.quizId, 'q1');
  });

  test('Quiz: đề, kết quả, xem lại', () {
    final quiz = QuizDetail.fromJson({
      'quiz': {'id': 'q1', 'title': 'Daily Life - Bài kiểm tra 1', 'quizType': 'TOPIC', 'topicId': 't1', 'passScorePercent': 70, 'questionCount': 1, 'timeLimitSeconds': 450},
      'questions': [
        {'id': 'a', 'questionText': 'Nghĩa của "dog"?', 'options': ['mèo', 'chó', 'gà', 'vịt'], 'correctAnswerIndex': 1, 'explanation': 'dog = chó', 'flashcardId': 'f1'}
      ],
    });
    expect(quiz.quiz.timeLimitSeconds, 450);
    expect(quiz.questions.single.options, hasLength(4));
    expect(quiz.questions.single.flashcardId, 'f1');

    final result = QuizResult.fromJson({'id': 'r', 'quizId': 'q1', 'totalQuestions': 10, 'correctAnswers': 8, 'wrongAnswers': 2, 'scorePercent': 80, 'passed': true, 'timeTakenSeconds': 95, 'wrongQuestionIds': ['a', 'b'], 'xpAwarded': 26});
    expect(result.passed, isTrue);
    expect(result.wrongQuestionIds, ['a', 'b']);
    expect(result.xpAwarded, 26);

    final review = QuizReviewItem.fromJson({'id': 'a', 'question': 'Q', 'options': ['1', '2', '3', '4'], 'correctIndex': 1, 'userIndex': -1});
    expect(review.isCorrect, isFalse);
  });

  test('Quest, RewardItem, ShopItem', () {
    final quest = Quest.fromJson({'id': 'q', 'title': 'Học 20 từ', 'iconName': 'style', 'current': 20, 'target': 20, 'xp': 50, 'isClaimed': false});
    expect(quest.isCompleted, isTrue);
    expect(quest.progress, 1.0);

    final shop = ShopItem.fromJson({
      'id': 'i1', 'code': 'BORDER_FIRE', 'name': 'Hỏa thần', 'itemType': 'BORDER', 'xpCost': 500,
      'borderColors': [4294921551, 4294933061, 4294945088], 'requiredRank': 0,
      'isUnlocked': true,
      'isEquipped': false,
      'inventoryId': 'inv1',
      'canAfford': true,
      'meetsRankRequirement': true,
    });
    expect(shop.item.isBorder, isTrue);
    expect(shop.item.colors, hasLength(3));
    expect(shop.item.colors.first.toARGB32(), 4294921551);
    expect(shop.inventoryId, 'inv1');
  });

  test('Leaderboard có slogan và màu viền đang trang bị', () {
    final board = Leaderboard.fromJson({
      'items': [
        {'rank': 1, 'userId': 'u1', 'fullName': 'An', 'slogan': 'Học là vui', 'equippedBorderColors': [4294921551, 4294933061], 'score': 900}
      ],
      'me': {'rank': 4, 'score': 120},
    });
    expect(board.items.single.slogan, 'Học là vui');
    expect(board.items.single.colors, hasLength(2));
    expect(board.myRank, 4);

    final noRank = Leaderboard.fromJson({'items': [], 'me': {'score': 0}});
    expect(noRank.myRank, isNull); // admin không có hạng
  });

  test('HomeSummary và Statistics', () {
    final home = HomeSummary.fromJson(homeJson());
    expect(home.todayDone, 3);
    expect(home.todayGoal, 5);
    expect(home.continueLesson!.isVocabulary, isTrue);
    expect(home.recommended, hasLength(2));
    expect(home.recommended.last.isVocabulary, isFalse);
    expect(home.todayChallenge!.xp, 50);

    final stats = Statistics.fromJson(statisticsJson(daily: [
      {'date': '2026-10-05', 'wordsLearned': 9, 'cardsReviewed': 12, 'xpGained': 70, 'lessonsCompleted': 1, 'quizzesCompleted': 1, 'correctAnswers': 8, 'totalAnswers': 10, 'studySeconds': 300},
    ]));
    expect(stats.daily.single.wordsLearned, 9);
    expect(stats.daily.single.date, DateTime(2026, 10, 5));
    expect(stats.accuracy, 0.85);
    expect(stats.from, DateTime(2026, 9, 29));
  });
}
