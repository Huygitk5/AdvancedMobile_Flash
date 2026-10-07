import '../../../models/leaderboard_model.dart';
import '../../../models/reward_item_model.dart';
import '../api_client.dart';

/// §6.8–§6.10: nhiệm vụ, shop, bảng xếp hạng (phần cần online).
class GamificationApi {
  GamificationApi(this._c);

  final ApiClient _c;

  /// Server tự giao nhiệm vụ của kỳ hiện tại. `{totalXp, quests: [...]}`.
  Future<Map<String, dynamic>> todayQuests() async => await _c.get('/v1/quests/today') as Map<String, dynamic>;

  /// Kèm `isUnlocked`, `isEquipped`, `inventoryId`, `canAfford`, `meetsRankRequirement`.
  Future<List<RewardItem>> shopItems() async => (await _c.get('/v1/shop/items') as List)
      .map((e) => RewardItem.fromJson(e as Map<String, dynamic>))
      .toList();

  /// `{inventory, currentXp}`. Cùng [idempotencyKey] gửi lại trả đúng kết quả cũ.
  Future<Map<String, dynamic>> purchase(String rewardItemId, String idempotencyKey) async => await _c.post(
        '/v1/shop/purchase',
        body: {'rewardItemId': rewardItemId},
        headers: {'Idempotency-Key': idempotencyKey},
      ) as Map<String, dynamic>;

  /// [board]: 'xp' | 'streak'.
  Future<Leaderboard> leaderboard(String board, {int limit = 10}) async {
    final data = await _c.get('/v1/leaderboard/$board', query: {'limit': limit}) as Map<String, dynamic>;
    return Leaderboard(
      items: (data['items'] as List? ?? const [])
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      me: data['me'] is Map<String, dynamic> ? LeaderboardMe.fromJson(data['me'] as Map<String, dynamic>) : null,
      fetchedAt: DateTime.now().toUtc(),
    );
  }
}
