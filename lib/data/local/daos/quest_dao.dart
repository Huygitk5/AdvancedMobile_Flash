import '../../../models/_json.dart';
import '../../../models/quest_model.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `user_quests` ⨝ `quest_definitions`. Server giao nhiệm vụ (GET /v1/quests/today hoặc khi có sự kiện học);
/// client chỉ tăng tiến độ lạc quan cho nhiệm vụ đã có ở local.
class QuestDao extends BaseDao {
  QuestDao(super.db);

  static const _t = 'user_quests';

  /// Nhiệm vụ của kỳ hiện tại: ngày [now], tuần chứa [now], và ONE_TIME chưa nhận.
  Stream<List<Quest>> watchCurrentQuests(DateTime now) => select(
        'SELECT uq.*, d.title, d.icon_name FROM $_t uq JOIN quest_definitions d ON d.id = uq.quest_definition_id '
        "WHERE (d.frequency = 'DAILY' AND uq.period_start = ?) "
        "OR (d.frequency = 'WEEKLY' AND uq.period_start = ?) "
        "OR (d.frequency = 'ONE_TIME' AND uq.is_claimed = 0) "
        'ORDER BY d.sort_order, d.title',
        [localDateKey(now), weekStartKey(now)],
        const [_t, 'quest_definitions'],
      ).watch().map((rows) => rows
          .map((r) => Quest(
                id: r.s('id'),
                questDefinitionId: r.s('quest_definition_id'),
                title: r.s('title'),
                iconName: r.s('icon_name'),
                current: r.i('current_value'),
                target: r.i('target_value'),
                xp: r.i('xp_reward'),
                isClaimed: r.b('is_claimed'),
                periodStart: r.s('period_start'),
              ))
          .toList());

  /// Tăng tiến độ lạc quan các nhiệm vụ loại [questType] của kỳ chứa [at].
  Future<void> bump(String questType, int delta, DateTime at) async {
    if (delta <= 0) return;
    final atMs = at.toUtc().millisecondsSinceEpoch;
    await update(
      'UPDATE $_t SET '
      'completed_at = CASE WHEN completed_at IS NULL AND current_value + ? >= target_value THEN ? ELSE completed_at END, '
      'current_value = MIN(target_value, current_value + ?), is_dirty = 1, sync_status = \'pending_update\' '
      'WHERE is_claimed = 0 AND id IN (SELECT uq.id FROM $_t uq JOIN quest_definitions d ON d.id = uq.quest_definition_id '
      "WHERE d.quest_type = ? AND ((d.frequency = 'DAILY' AND uq.period_start = ?) "
      "OR (d.frequency = 'WEEKLY' AND uq.period_start = ?) OR d.frequency = 'ONE_TIME'))",
      [delta, atMs, delta, questType, localDateKey(at), weekStartKey(at)],
      const [_t],
    );
  }

  Future<({int current, int target, int xpReward, bool isClaimed})?> byId(String id) async {
    final rows = await select('SELECT * FROM $_t WHERE id = ?', [id]).get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return (current: r.i('current_value'), target: r.i('target_value'), xpReward: r.i('xp_reward'), isClaimed: r.b('is_claimed'));
  }

  Future<void> setClaimed(String id, bool claimed, int? atMs) => update(
        'UPDATE $_t SET is_claimed = ?, claimed_at = ?, is_dirty = 1, sync_status = \'pending_update\' WHERE id = ?',
        [claimed, claimed ? atMs : null, id],
        const [_t],
      );

  Future<void> markClean(String id, int nowMs) => update(
        "UPDATE $_t SET is_dirty = 0, sync_status = 'synced', last_synced_at = ? WHERE id = ?",
        [nowMs, id],
        const [_t],
      );

  /// Pull: `QuestRow`.
  Future<void> applyServer(Map<String, dynamic> q, int nowMs) async {
    final id = q['id'] as String;
    final cur = await select('SELECT is_dirty FROM $_t WHERE id = ?', [id]).get();
    if (cur.isNotEmpty && cur.first.b('is_dirty')) return;
    final defId = q['questDefinitionId'] as String;
    if ((await select('SELECT COUNT(*) AS c FROM quest_definitions WHERE id = ?', [defId]).getSingle()).i('c') == 0) {
      return;
    }
    // UNIQUE(quest_definition_id, period_start): dòng cũ cùng kỳ mang id khác thì thay.
    await deleteWhere(_t, 'quest_definition_id = ? AND period_start = ? AND id <> ?', [defId, q['periodStart'], id]);
    await upsert(_t, {
      'id': id,
      'quest_definition_id': defId,
      'period_start': jStr(q['periodStart']),
      'current_value': jInt(q['currentValue']),
      'target_value': jInt(q['targetValue'], 1),
      'xp_reward': jInt(q['xpReward']),
      'completed_at': toEpoch(q['completedAt'] as String?),
      'is_claimed': jBool(q['isClaimed']),
      'claimed_at': toEpoch(q['claimedAt'] as String?),
      'version': jInt(q['version']),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['id']);
  }

  Future<int> countForPeriod(String dateKey) async => (await select(
        'SELECT COUNT(*) AS c FROM $_t WHERE period_start = ?',
        [dateKey],
      ).getSingle())
          .i('c');
}
