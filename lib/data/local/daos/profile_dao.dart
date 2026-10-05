import 'dart:convert';

import '../../../models/_json.dart';
import '../../../models/user_model.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `user_profile`: bản cache 1 dòng của user đang đăng nhập. XP / streak / tổng số là số server;
/// client chỉ được sửa slogan / full_name / level, và cộng `pending_xp` (ước lượng hiển thị).
class ProfileDao extends BaseDao {
  ProfileDao(super.db);

  static const _t = 'user_profile';

  Stream<UserModel?> watchProfile() => select(
        'SELECT u.*, '
        '(SELECT r.border_colors FROM user_inventories i JOIN reward_items r ON r.id = i.reward_item_id '
        " WHERE i.is_equipped = 1 AND r.item_type = 'BORDER' LIMIT 1) AS eq_border, "
        '(SELECT r.image_url FROM user_inventories i JOIN reward_items r ON r.id = i.reward_item_id '
        " WHERE i.is_equipped = 1 AND r.item_type = 'AVATAR' LIMIT 1) AS eq_avatar "
        'FROM $_t u LIMIT 1',
        const [],
        const [_t, 'user_inventories', 'reward_items'],
      ).watch().map((rows) {
        if (rows.isEmpty) return null;
        final r = rows.first;
        final border = r.sN('eq_border');
        return UserModel(
          id: r.s('id'),
          fullName: r.s('full_name'),
          email: r.s('email'),
          avatarUrl: r.sN('avatar_url'),
          level: r.s('level'),
          slogan: r.s('slogan'),
          currentXp: r.i('current_xp'),
          pendingXp: r.i('pending_xp'),
          targetXp: r.i('target_xp'),
          totalLifetimeXp: r.i('total_lifetime_xp'),
          streakDays: r.i('streak_days'),
          longestStreak: r.i('longest_streak'),
          totalWordsLearned: r.i('total_words_learned'),
          completedLessons: r.i('completed_lessons'),
          version: r.i('version'),
          equippedBorderColors: border == null ? const [] : jIntList(jsonDecode(border)),
          equippedAvatarUrl: r.sN('eq_avatar'),
        );
      });

  Future<UserModel?> current() => watchProfile().first;

  Future<String?> userId() async {
    final rows = await select('SELECT id FROM $_t LIMIT 1').get();
    return rows.isEmpty ? null : rows.first.s('id');
  }

  /// `UserResponse` của server. Profile đang dirty (slogan chưa đồng bộ) thì giữ các cột hồ sơ local.
  Future<void> upsertFromUser(Map<String, dynamic> u, int nowMs) async {
    final cur = await select('SELECT * FROM $_t WHERE id = ?', [u['id']]).get();
    final dirty = cur.isNotEmpty && cur.first.b('is_dirty');
    // Chỉ một dòng: dòng của user khác (nếu có) bị thay.
    await deleteWhere(_t, 'id <> ?', [u['id']]);
    await upsert(_t, {
      'id': u['id'],
      'email': jStr(u['email']),
      'full_name': dirty ? cur.first.s('full_name') : jStr(u['fullName']),
      'avatar_url': u['avatarUrl'],
      'level': dirty ? cur.first.s('level') : jStr(u['level'], 'A1'),
      'slogan': dirty ? cur.first.s('slogan') : jStr(u['slogan']),
      'current_xp': jInt(u['currentXp']),
      'pending_xp': cur.isEmpty ? 0 : cur.first.i('pending_xp'),
      'target_xp': jInt(u['targetXp'], 100),
      'total_lifetime_xp': jInt(u['totalLifetimeXp']),
      'streak_days': jInt(u['streakDays']),
      'longest_streak': jInt(u['longestStreak']),
      'total_words_learned': jInt(u['totalWordsLearned']),
      'completed_lessons': jInt(u['completedLessons']),
      'version': dirty ? cur.first.i('version') : jInt(u['version']),
      'client_updated_at': toEpoch(u['clientUpdatedAt'] as String?),
      'is_dirty': dirty ? 1 : 0,
      'sync_status': dirty ? 'pending_update' : 'synced',
      'last_synced_at': nowMs,
    }, const ['id']);
  }

  /// `UserSnapshot` trong response của push / review / lesson.
  Future<void> applySnapshot(Map<String, dynamic>? s) async {
    if (s == null) return;
    await update(
      'UPDATE $_t SET current_xp = ?, total_lifetime_xp = ?, streak_days = ?, longest_streak = ?, '
      'total_words_learned = ?, completed_lessons = ?',
      [
        jInt(s['currentXp']),
        jInt(s['totalLifetimeXp']),
        jInt(s['streakDays']),
        jInt(s['longestStreak']),
        jInt(s['totalWordsLearned']),
        jInt(s['completedLessons']),
      ],
      const [_t],
    );
  }

  Future<void> setXp({required int currentXp, int? totalLifetimeXp}) => update(
        'UPDATE $_t SET current_xp = ?, total_lifetime_xp = COALESCE(?, total_lifetime_xp)',
        [currentXp, totalLifetimeXp],
        const [_t],
      );

  Future<void> addPendingXp(int delta) => update(
        'UPDATE $_t SET pending_xp = MAX(0, pending_xp + ?)',
        [delta],
        const [_t],
      );

  Future<void> resetPendingXp() => update('UPDATE $_t SET pending_xp = 0', const [], const [_t]);

  Future<void> bumpCounters({int completedLessons = 0, int wordsLearned = 0}) => update(
        'UPDATE $_t SET completed_lessons = MAX(0, completed_lessons + ?), '
        'total_words_learned = MAX(0, total_words_learned + ?)',
        [completedLessons, wordsLearned],
        const [_t],
      );

  Future<void> setTotalWordsLearned(int n) =>
      update('UPDATE $_t SET total_words_learned = ?', [n], const [_t]);

  /// Sửa hồ sơ lạc quan. Trả `baseVersion` cho payload PROFILE_UPDATE.
  Future<int> updateProfileLocal({String? slogan, String? fullName, String? level, required int nowMs}) async {
    final rows = await select('SELECT version FROM $_t LIMIT 1').get();
    await update(
      'UPDATE $_t SET slogan = COALESCE(?, slogan), full_name = COALESCE(?, full_name), level = COALESCE(?, level), '
      "client_updated_at = ?, is_dirty = 1, sync_status = 'pending_update'",
      [slogan, fullName, level, nowMs],
      const [_t],
    );
    return rows.isEmpty ? 0 : rows.first.i('version');
  }

  Future<void> markClean(int nowMs) => update(
        "UPDATE $_t SET is_dirty = 0, sync_status = 'synced', last_synced_at = ?",
        [nowMs],
        const [_t],
      );
}
