import 'dart:convert';

import 'package:drift/drift.dart' show QueryRow;

import '../../../core/clock.dart';
import '../../../models/flashcard_model.dart';
import '../../../models/grammar_model.dart';
import '../../../models/quiz_model.dart';
import '../../../models/topic_model.dart';
import '../../../models/_json.dart';
import '../converters.dart';
import 'base_dao.dart';

/// Bộ lọc ở TopicScreen: Tất cả / Đang học / Đã hoàn thành.
enum ProgressFilter { all, inProgress, completed }

/// Nhóm A: cache nội dung (đọc offline) + đọc kèm tiến độ của user.
class ContentDao extends BaseDao {
  ContentDao(super.db);

  static const _topicTables = ['topics', 'user_topic_progress', 'flashcards'];

  // ---------------------------------------------------------------- đọc

  Stream<List<Topic>> watchTopicsWithProgress({ProgressFilter filter = ProgressFilter.all, String keyword = ''}) {
    final kw = keyword.trim();
    final like = '%${_escapeLike(kw)}%';
    return select(
      'SELECT t.*, COALESCE(p.learned_words, 0) AS learned_words, '
      "COALESCE(p.status, 'NOT_STARTED') AS status, p.last_studied_at "
      'FROM topics t LEFT JOIN user_topic_progress p ON p.topic_id = t.id '
      "WHERE (? = '' OR t.title LIKE ? ESCAPE '\\' OR EXISTS ("
      "  SELECT 1 FROM flashcards f WHERE f.topic_id = t.id AND (f.word LIKE ? ESCAPE '\\' OR f.meaning LIKE ? ESCAPE '\\'))) "
      '${_statusClause(filter, "p.status")} '
      'ORDER BY t.sort_order, t.title',
      [kw, like, like, like],
      _topicTables,
    ).watch().map((rows) => rows.map(_topic).toList());
  }

  Stream<List<Grammar>> watchGrammarWithProgress({ProgressFilter filter = ProgressFilter.all, String keyword = ''}) {
    final kw = keyword.trim();
    final like = '%${_escapeLike(kw)}%';
    return select(
      'SELECT g.*, COALESCE(p.progress, 0.0) AS progress, '
      "COALESCE(p.status, 'NOT_STARTED') AS status, p.best_score_percent "
      'FROM grammar_lessons g LEFT JOIN user_grammar_progress p ON p.grammar_lesson_id = g.id '
      "WHERE (? = '' OR g.title LIKE ? ESCAPE '\\' OR g.structure LIKE ? ESCAPE '\\') "
      '${_statusClause(filter, "p.status")} '
      'ORDER BY g.sort_order, g.title',
      [kw, like, like],
      const ['grammar_lessons', 'user_grammar_progress'],
    ).watch().map((rows) => rows.map(_grammar).toList());
  }

  Stream<Topic?> watchTopic(String id) => select(
        'SELECT t.*, COALESCE(p.learned_words, 0) AS learned_words, '
        "COALESCE(p.status, 'NOT_STARTED') AS status, p.last_studied_at "
        'FROM topics t LEFT JOIN user_topic_progress p ON p.topic_id = t.id WHERE t.id = ?',
        [id],
        const ['topics', 'user_topic_progress'],
      ).watch().map((rows) => rows.isEmpty ? null : _topic(rows.first));

  /// Thẻ của một topic, kèm SRS + ghi chú + bookmark. Thẻ đến hạn ôn đứng trước, rồi thẻ mới, rồi thẻ chưa đến hạn.
  Stream<List<Flashcard>> watchCards(String topicId) => select(
        'SELECT f.*, p.box, p.is_learned, p.due_at, n.id AS note_id, n.content AS note, n.version AS note_version, '
        'CASE WHEN b.flashcard_id IS NOT NULL AND b.deleted_at IS NULL THEN 1 ELSE 0 END AS is_bookmarked '
        'FROM flashcards f '
        'LEFT JOIN user_flashcard_progress p ON p.flashcard_id = f.id '
        'LEFT JOIN user_flashcard_notes n ON n.flashcard_id = f.id AND n.deleted_at IS NULL '
        'LEFT JOIN user_bookmarks b ON b.flashcard_id = f.id '
        'WHERE f.topic_id = ? '
        'ORDER BY CASE WHEN p.due_at IS NOT NULL AND p.due_at <= ? THEN 0 WHEN p.flashcard_id IS NULL THEN 1 ELSE 2 END, '
        'f.sort_order, f.word',
        [topicId, Clock.nowMs()],
        const ['flashcards', 'user_flashcard_progress', 'user_flashcard_notes', 'user_bookmarks'],
      ).watch().map((rows) => rows.map(_card).toList());

  Future<Flashcard?> card(String id) async {
    final rows = await select('SELECT * FROM flashcards WHERE id = ?', [id]).get();
    return rows.isEmpty ? null : _card(rows.first);
  }

  Stream<GrammarDetail?> watchGrammar(String id) => select(
        'SELECT g.*, COALESCE(p.progress, 0.0) AS progress, '
        "COALESCE(p.status, 'NOT_STARTED') AS status, p.best_score_percent "
        'FROM grammar_lessons g LEFT JOIN user_grammar_progress p ON p.grammar_lesson_id = g.id WHERE g.id = ?',
        [id],
        const ['grammar_lessons', 'user_grammar_progress', 'grammar_examples', 'quizzes'],
      ).watch().asyncMap((rows) async {
        if (rows.isEmpty) return null;
        final r = rows.first;
        final examples = await select(
          'SELECT * FROM grammar_examples WHERE grammar_lesson_id = ? ORDER BY sort_order',
          [id],
        ).get();
        final quiz = await quizForGrammar(id);
        return GrammarDetail(
          grammar: _grammar(r),
          content: r.sN('content'),
          usageNotes: r.sN('usage_notes'),
          examples: examples
              .map((e) => GrammarExample(
                    id: e.s('id'),
                    sentence: e.s('sentence'),
                    translation: e.sN('translation'),
                    highlight: e.sN('highlight'),
                    sortOrder: e.i('sort_order'),
                  ))
              .toList(),
          quizId: quiz?.id,
        );
      });

  Future<Quiz?> quizForGrammar(String grammarId) => _firstQuiz('grammar_lesson_id', grammarId);

  Future<Quiz?> quizForTopic(String topicId) => _firstQuiz('topic_id', topicId);

  Stream<Quiz?> watchQuizForTopic(String topicId) => select(
        'SELECT q.*, (SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id = q.id) AS question_count '
        'FROM quizzes q WHERE q.topic_id = ? ORDER BY q.title LIMIT 1',
        [topicId],
        const ['quizzes', 'quiz_questions'],
      ).watch().map((rows) => rows.isEmpty ? null : _quiz(rows.first));

  Future<Quiz?> quiz(String quizId) async {
    final rows = await select(
      'SELECT q.*, (SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id = q.id) AS question_count '
      'FROM quizzes q WHERE q.id = ?',
      [quizId],
    ).get();
    return rows.isEmpty ? null : _quiz(rows.first);
  }

  Future<List<QuizQuestion>> questionsWithOptions(String quizId) async {
    final qRows = await select(
      'SELECT qq.*, q.topic_id FROM quiz_questions qq JOIN quizzes q ON q.id = qq.quiz_id '
      'WHERE qq.quiz_id = ? ORDER BY qq.sort_order',
      [quizId],
    ).get();
    final optRows = await select(
      'SELECT o.* FROM quiz_question_options o JOIN quiz_questions qq ON qq.id = o.question_id '
      'WHERE qq.quiz_id = ? ORDER BY o.option_index',
      [quizId],
    ).get();
    final options = <String, List<String>>{};
    for (final o in optRows) {
      (options[o.s('question_id')] ??= []).add(o.s('option_text'));
    }
    return qRows
        .map((r) => QuizQuestion(
              id: r.s('id'),
              quizId: r.s('quiz_id'),
              topicId: r.sN('topic_id'),
              flashcardId: r.sN('flashcard_id'),
              questionText: r.s('question_text'),
              options: options[r.s('id')] ?? const [],
              correctAnswerIndex: r.i('correct_option_index'),
              explanation: r.sN('explanation') ?? '',
              sortOrder: r.i('sort_order'),
            ))
        .toList();
  }

  Future<int> topicCount() async =>
      (await select('SELECT COUNT(*) AS c FROM topics').getSingle()).i('c');

  // ---------------------------------------------------------------- ghi (từ /v1/sync/content)

  /// Áp `changes` của `/v1/sync/content`. Gọi trong transaction của PullService.
  /// Cha được ghi trước con; con nào chưa có cha ở local thì bỏ qua: khi cha tới ở trang sau,
  /// server gửi kèm toàn bộ con đang hiển thị của nó.
  Future<void> upsertContent(Map<String, dynamic> changes) async {
    List<Map<String, dynamic>> list(String k) => (changes[k] as List? ?? const []).cast<Map<String, dynamic>>();

    for (final t in list('topics')) {
      await upsert('topics', {
        'id': t['id'],
        'title': jStr(t['title']),
        'description': t['description'],
        'icon_path': jStr(t['iconPath'], '📚'),
        'level': jStr(t['level'], 'A1'),
        'cover_color': jIntN(t['coverColor']),
        'estimated_minutes': jInt(t['estimatedMinutes'], 10),
        'total_words': jInt(t['totalWords']),
        'sort_order': jInt(t['sortOrder']),
        'server_updated_at': toEpoch(t['updatedAt'] as String?) ?? Clock.nowMs(),
      }, const ['id']);
    }
    for (final g in list('grammarLessons')) {
      await upsert('grammar_lessons', {
        'id': g['id'],
        'title': jStr(g['title']),
        'description': g['description'],
        'structure': jStr(g['structure']),
        'content': g['content'],
        'usage_notes': g['usageNotes'],
        'icon_name': jStr(g['iconName'], 'menu_book'),
        'level': jStr(g['level'], 'A1'),
        'cover_color': jIntN(g['coverColor']),
        'estimated_minutes': jInt(g['estimatedMinutes'], 10),
        'sort_order': jInt(g['sortOrder']),
        'server_updated_at': toEpoch(g['updatedAt'] as String?) ?? Clock.nowMs(),
      }, const ['id']);
    }

    final topicIds = await ids('topics');
    final grammarIds = await ids('grammar_lessons');

    for (final f in list('flashcards')) {
      if (!topicIds.contains(f['topicId'])) continue;
      await upsert('flashcards', {
        'id': f['id'],
        'topic_id': f['topicId'],
        'word': jStr(f['word']),
        'part_of_speech': jStr(f['partOfSpeech']),
        'pronunciation': jStr(f['pronunciation']),
        'meaning': jStr(f['meaning']),
        'example': f['example'],
        'example_translation': f['exampleTranslation'],
        'audio_url': f['audioUrl'],
        'image_url': f['imageUrl'],
        'sort_order': jInt(f['sortOrder']),
        'server_updated_at': toEpoch(f['updatedAt'] as String?) ?? Clock.nowMs(),
      }, const ['id']);
    }
    for (final e in list('grammarExamples')) {
      if (!grammarIds.contains(e['grammarLessonId'])) continue;
      await upsert('grammar_examples', {
        'id': e['id'],
        'grammar_lesson_id': e['grammarLessonId'],
        'sentence': jStr(e['sentence']),
        'translation': e['translation'],
        'highlight': e['highlight'],
        'sort_order': jInt(e['sortOrder']),
      }, const ['id']);
    }
    for (final q in list('quizzes')) {
      final topicId = q['topicId'] as String?;
      final grammarId = q['grammarLessonId'] as String?;
      if (topicId != null && !topicIds.contains(topicId)) continue;
      if (grammarId != null && !grammarIds.contains(grammarId)) continue;
      if ((topicId == null) == (grammarId == null)) continue;
      await upsert('quizzes', {
        'id': q['id'],
        'title': jStr(q['title']),
        'quiz_type': jStr(q['quizType'], topicId != null ? 'TOPIC' : 'GRAMMAR'),
        'topic_id': topicId,
        'grammar_lesson_id': grammarId,
        'time_limit_seconds': jIntN(q['timeLimitSeconds']),
        'pass_score_percent': jInt(q['passScorePercent'], 70),
        'server_updated_at': toEpoch(q['updatedAt'] as String?) ?? Clock.nowMs(),
      }, const ['id']);
    }

    final quizIds = await ids('quizzes');
    for (final q in list('quizQuestions')) {
      if (!quizIds.contains(q['quizId'])) continue;
      await upsert('quiz_questions', {
        'id': q['id'],
        'quiz_id': q['quizId'],
        'flashcard_id': q['flashcardId'],
        'question_text': jStr(q['questionText']),
        'correct_option_index': jInt(q['correctOptionIndex']),
        'explanation': q['explanation'],
        'sort_order': jInt(q['sortOrder']),
      }, const ['id']);
      // 4 đáp án: xoá cũ, chèn mới (bảng không có updated_at riêng).
      await deleteWhere('quiz_question_options', 'question_id = ?', [q['id']]);
      final options = (q['options'] as List? ?? const []);
      for (var i = 0; i < options.length && i < 4; i++) {
        await upsert('quiz_question_options',
            {'question_id': q['id'], 'option_index': i, 'option_text': options[i].toString()},
            const ['question_id', 'option_index']);
      }
    }

    for (final d in list('questDefinitions')) {
      await upsert('quest_definitions', {
        'id': d['id'],
        'code': jStr(d['code']),
        'title': jStr(d['title']),
        'quest_type': jStr(d['questType']),
        'frequency': jStr(d['frequency'], 'DAILY'),
        'target_value': jInt(d['targetValue'], 1),
        'xp_reward': jInt(d['xpReward']),
        'icon_name': jStr(d['iconName'], 'stars'),
        'is_active': jBool(d['isActive'], true),
        'sort_order': jInt(d['sortOrder']),
      }, const ['id']);
    }
    for (final r in list('rewardItems')) {
      await upsertRewardItem(r);
    }
  }

  /// `RewardItemResponse` -> `reward_items` (dùng chung cho content pull và item kèm trong inventory).
  Future<void> upsertRewardItem(Map<String, dynamic> r) => upsert('reward_items', {
        'id': r['id'],
        'code': jStr(r['code'], r['id'] as String),
        'name': jStr(r['name']),
        'item_type': jStr(r['itemType'], 'BORDER'),
        'xp_cost': jInt(r['xpCost']),
        'border_colors': r['borderColors'] == null ? null : jsonEncode(r['borderColors']),
        'image_url': r['imageUrl'],
        'required_rank': jInt(r['requiredRank']),
        'rank_board': jStr(r['rankBoard'], 'XP'),
        'is_active': jBool(r['isActive'], true),
        'sort_order': jInt(r['sortOrder']),
        'server_updated_at': toEpoch(r['updatedAt'] as String?) ?? Clock.nowMs(),
      }, const ['id']);

  /// `changes.deleted`: xoá theo id; FK ON DELETE CASCADE dọn bảng con (và tiến độ/ghi chú của thẻ đó).
  Future<void> deleteContent(Map<String, dynamic>? deleted) async {
    if (deleted == null) return;
    const tableOf = {
      'quizQuestions': 'quiz_questions',
      'quizzes': 'quizzes',
      'grammarExamples': 'grammar_examples',
      'flashcards': 'flashcards',
      'grammarLessons': 'grammar_lessons',
      'topics': 'topics',
    };
    for (final e in tableOf.entries) {
      final idList = (deleted[e.key] as List? ?? const []).cast<String>();
      for (final id in idList) {
        await deleteWhere(e.value, 'id = ?', [id]);
      }
    }
  }

  // ---------------------------------------------------------------- mapper

  static String _escapeLike(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');

  static String _statusClause(ProgressFilter f, String col) => switch (f) {
        ProgressFilter.all => '',
        ProgressFilter.inProgress => "AND $col = 'IN_PROGRESS'",
        ProgressFilter.completed => "AND $col = 'COMPLETED'",
      };

  Future<Quiz?> _firstQuiz(String col, String id) async {
    final rows = await select(
      'SELECT q.*, (SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id = q.id) AS question_count '
      'FROM quizzes q WHERE q.$col = ? ORDER BY q.title LIMIT 1',
      [id],
    ).get();
    return rows.isEmpty ? null : _quiz(rows.first);
  }

  static Topic _topic(QueryRow r) => Topic(
        id: r.s('id'),
        title: r.s('title'),
        description: r.sN('description'),
        iconPath: r.s('icon_path'),
        level: r.s('level'),
        coverColor: r.iN('cover_color'),
        estimatedMinutes: r.i('estimated_minutes'),
        totalWords: r.i('total_words'),
        learnedWords: r.i('learned_words'),
        status: r.s('status'),
        sortOrder: r.i('sort_order'),
        lastStudiedAt: fromEpoch(r.iN('last_studied_at')),
      );

  static Grammar _grammar(QueryRow r) => Grammar(
        id: r.s('id'),
        title: r.s('title'),
        description: r.sN('description'),
        structure: r.s('structure'),
        iconName: r.s('icon_name'),
        level: r.s('level'),
        coverColor: r.iN('cover_color'),
        estimatedMinutes: r.i('estimated_minutes'),
        progress: r.d('progress'),
        status: r.s('status'),
        bestScorePercent: r.iN('best_score_percent'),
        sortOrder: r.i('sort_order'),
      );

  static Flashcard _card(QueryRow r) {
    final data = r.data;
    return Flashcard(
      id: r.s('id'),
      topicId: r.s('topic_id'),
      word: r.s('word'),
      partOfSpeech: r.s('part_of_speech'),
      pronunciation: r.s('pronunciation'),
      meaning: r.s('meaning'),
      example: r.sN('example'),
      exampleTranslation: r.sN('example_translation'),
      audioUrl: r.sN('audio_url'),
      imageUrl: r.sN('image_url'),
      sortOrder: r.i('sort_order'),
      note: data.containsKey('note') ? r.sN('note') : null,
      noteId: data.containsKey('note_id') ? r.sN('note_id') : null,
      noteVersion: data.containsKey('note_version') ? (r.iN('note_version') ?? 0) : 0,
      isBookmarked: data.containsKey('is_bookmarked') && r.b('is_bookmarked'),
      srsBox: data.containsKey('box') ? (r.iN('box') ?? 0) : 0,
      isLearned: data.containsKey('is_learned') && r.b('is_learned'),
      dueAt: data.containsKey('due_at') ? fromEpoch(r.iN('due_at')) : null,
    );
  }

  static Quiz _quiz(QueryRow r) => Quiz(
        id: r.s('id'),
        title: r.s('title'),
        quizType: r.s('quiz_type'),
        topicId: r.sN('topic_id'),
        grammarLessonId: r.sN('grammar_lesson_id'),
        timeLimitSeconds: r.iN('time_limit_seconds'),
        passScorePercent: r.i('pass_score_percent'),
        questionCount: r.i('question_count'),
      );
}
