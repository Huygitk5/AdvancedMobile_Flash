import '../models/json_helpers.dart';
import '../models/leaderboard_model.dart';
import '../models/quest_model.dart';
import '../models/reward_item_model.dart';
import 'api/api_client.dart';
import 'app_state.dart';

class TodayQuests {
  final int totalXp;
  final List<Quest> quests;
  const TodayQuests(this.totalXp, this.quests);
}

class GameRepository {
  GameRepository._();

  static ApiClient get _api => ApiClient.I;

  static Future<TodayQuests> todayQuests() async {
    final data = asMap(await _api.get('/v1/quests/today'));
    return TodayQuests(jInt(data, 'totalXp'), jList(data, 'quests').map(Quest.fromJson).toList());
  }

  /// Nhận thưởng nhiệm vụ; trả về số XP vừa nhận. Số dư XP được cập nhật vào [AppState].
  static Future<int> claimQuest(Quest quest) async {
    final data = asMap(await _api.post('/v1/quests/claim/${quest.id}'));
    quest.isClaimed = true;
    AppState.I.updateUser((u) => u.copyWith(
          currentXp: jInt(data, 'currentXp', u.currentXp),
          totalLifetimeXp: jInt(data, 'totalLifetimeXp', u.totalLifetimeXp),
        ));
    return jInt(data, 'xpAwarded');
  }

  static Future<List<ShopItem>> shopItems() async {
    final data = await _api.get('/v1/shop/items');
    return asMapList(data).map(ShopItem.fromJson).toList();
  }

  static Future<void> purchase(RewardItem item) async {
    final data = asMap(await _api.post('/v1/shop/purchase', body: {'rewardItemId': item.id}));
    AppState.I.updateUser((u) => u.copyWith(currentXp: jInt(data, 'currentXp', u.currentXp)));
    await AppState.I.refreshInventory();
  }

  static Future<void> equip(String inventoryId) async {
    await _api.put('/v1/shop/equip/$inventoryId', body: {'clientUpdatedAt': DateTime.now().toUtc().toIso8601String()});
    await AppState.I.refreshInventory();
  }

  static Future<void> unequip(String inventoryId) async {
    await _api.put('/v1/shop/unequip/$inventoryId', body: {'clientUpdatedAt': DateTime.now().toUtc().toIso8601String()});
    await AppState.I.refreshInventory();
  }

  /// board: 'xp' hoặc 'streak'.
  static Future<Leaderboard> leaderboard(String board, {int limit = 10}) async {
    final data = await _api.get('/v1/leaderboard/$board', query: {'limit': limit});
    return Leaderboard.fromJson(asMap(data));
  }
}
