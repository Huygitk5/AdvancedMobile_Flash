import '../../../models/leaderboard_model.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `leaderboard_cache`: cache chỉ đọc có TTL, ghi lại toàn bộ mỗi lần gọi API thành công.
/// Bảng không có cột viền / "hạng của bạn" nên bản offline hiện viền mặc định và không có dòng của mình.
class LeaderboardDao extends BaseDao {
  LeaderboardDao(super.db);

  static const _t = 'leaderboard_cache';

  Future<Leaderboard?> cached(String board) async {
    final rows = await select('SELECT * FROM $_t WHERE board = ? ORDER BY rank_no', [board]).get();
    if (rows.isEmpty) return null;
    return Leaderboard(
      items: rows
          .map((r) => LeaderboardEntry(
                rank: r.i('rank_no'),
                userId: r.s('user_id'),
                fullName: r.s('full_name'),
                avatarUrl: r.sN('avatar_url'),
                score: r.i('score'),
              ))
          .toList(),
      fetchedAt: fromEpoch(rows.first.i('fetched_at')),
    );
  }

  Future<void> replace(String board, List<LeaderboardEntry> items, int fetchedAtMs) => db.transaction(() async {
        await deleteWhere(_t, 'board = ?', [board]);
        for (final e in items) {
          await upsert(_t, {
            'board': board,
            'rank_no': e.rank,
            'user_id': e.userId,
            'full_name': e.fullName,
            'avatar_url': e.avatarUrl,
            'score': e.score,
            'fetched_at': fetchedAtMs,
          }, const ['board', 'user_id']);
        }
      });
}
