import 'package:drift/drift.dart' show QueryRow;

import '../../../models/_json.dart';
import '../../../models/daily_statistic_model.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `daily_statistics`: client cộng dồn lạc quan để vẽ biểu đồ offline, server ghi đè khi pull.
class StatsDao extends BaseDao {
  StatsDao(super.db);

  static const _t = 'daily_statistics';

  /// Các ngày có số liệu trong [fromKey, toKey] ('YYYY-MM-DD'); ngày trống do UI điền 0.
  Stream<List<DailyStatistic>> watchDaily(String fromKey, String toKey) => select(
        'SELECT * FROM $_t WHERE stat_date >= ? AND stat_date <= ? ORDER BY stat_date',
        [fromKey, toKey],
        const [_t],
      ).watch().map((rows) => rows.map(_fromRow).toList());

  Stream<List<DailyStatistic>> watchAll() =>
      select('SELECT * FROM $_t ORDER BY stat_date', const [], const [_t]).watch().map((rows) => rows.map(_fromRow).toList());

  Stream<DailyStatistic?> watchDay(String key) => select('SELECT * FROM $_t WHERE stat_date = ?', [key], const [_t])
      .watch()
      .map((rows) => rows.isEmpty ? null : _fromRow(rows.first));

  /// Cộng dồn lạc quan vào ngày [dateKey].
  Future<void> bump(
    String dateKey, {
    int wordsLearned = 0,
    int cardsReviewed = 0,
    int xpGained = 0,
    int lessonsCompleted = 0,
    int quizzesCompleted = 0,
    int correctAnswers = 0,
    int totalAnswers = 0,
    int studySeconds = 0,
  }) =>
      db.customInsert(
        'INSERT INTO $_t (stat_date, words_learned, cards_reviewed, xp_gained, lessons_completed, quizzes_completed, '
        'correct_answers, total_answers, study_seconds, is_dirty) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1) '
        'ON CONFLICT(stat_date) DO UPDATE SET '
        'words_learned = MAX(0, words_learned + excluded.words_learned), '
        'cards_reviewed = MAX(0, cards_reviewed + excluded.cards_reviewed), '
        'xp_gained = MAX(0, xp_gained + excluded.xp_gained), '
        'lessons_completed = MAX(0, lessons_completed + excluded.lessons_completed), '
        'quizzes_completed = MAX(0, quizzes_completed + excluded.quizzes_completed), '
        'correct_answers = MAX(0, correct_answers + excluded.correct_answers), '
        'total_answers = MAX(0, total_answers + excluded.total_answers), '
        'study_seconds = MAX(0, study_seconds + excluded.study_seconds), is_dirty = 1',
        variables: [
          dateKey,
          wordsLearned,
          cardsReviewed,
          xpGained,
          lessonsCompleted,
          quizzesCompleted,
          correctAnswers,
          totalAnswers,
          studySeconds,
        ].map(sqlVar).toList(),
        updates: {table(_t)},
      );

  /// Pull: `DailyStatisticResponse`. Không đè ngày đang có số lạc quan chưa xác nhận.
  Future<void> applyServer(Map<String, dynamic> d, int nowMs) async {
    final key = d['date'] as String;
    final cur = await select('SELECT is_dirty FROM $_t WHERE stat_date = ?', [key]).get();
    if (cur.isNotEmpty && cur.first.b('is_dirty')) return;
    await upsert(_t, {
      'stat_date': key,
      'id': d['id'],
      'words_learned': jInt(d['wordsLearned']),
      'cards_reviewed': jInt(d['cardsReviewed']),
      'xp_gained': jInt(d['xpGained']),
      'lessons_completed': jInt(d['lessonsCompleted']),
      'quizzes_completed': jInt(d['quizzesCompleted']),
      'correct_answers': jInt(d['correctAnswers']),
      'total_answers': jInt(d['totalAnswers']),
      'study_seconds': jInt(d['studySeconds']),
      'is_dirty': 0,
      'last_synced_at': nowMs,
    }, const ['stat_date']);
  }

  static DailyStatistic _fromRow(QueryRow r) => DailyStatistic(
        date: parseDateKey(r.read<String>('stat_date')),
        wordsLearned: r.read<int>('words_learned'),
        cardsReviewed: r.read<int>('cards_reviewed'),
        xpGained: r.read<int>('xp_gained'),
        lessonsCompleted: r.read<int>('lessons_completed'),
        quizzesCompleted: r.read<int>('quizzes_completed'),
        correctAnswers: r.read<int>('correct_answers'),
        totalAnswers: r.read<int>('total_answers'),
        studySeconds: r.read<int>('study_seconds'),
      );
}
