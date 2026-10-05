import 'dart:convert';

import 'package:drift/drift.dart' show QueryRow;

import '../../../models/_json.dart';
import '../../../models/reward_item_model.dart';
import '../converters.dart';
import 'base_dao.dart';

/// `reward_items` (catalog, cache) + `user_inventories` (kho đồ của user).
class ShopDao extends BaseDao {
  ShopDao(super.db);

  static const _inv = 'user_inventories';

  static const _itemSelect = 'SELECT r.*, i.id AS inventory_id, i.is_equipped '
      'FROM reward_items r LEFT JOIN $_inv i ON i.reward_item_id = r.id ';

  /// Danh mục Shop: vật phẩm đang bán + mọi thứ đã sở hữu (kể cả đã gỡ khỏi shop).
  Stream<List<RewardItem>> watchShopItems() => select(
        '${_itemSelect}WHERE r.is_active = 1 OR i.id IS NOT NULL ORDER BY r.item_type DESC, r.sort_order, r.xp_cost',
        const [],
        const ['reward_items', _inv],
      ).watch().map((rows) => rows.map(itemFromRow).toList());

  /// Kho đồ (chỉ món đã sở hữu).
  Stream<List<RewardItem>> watchInventoryWithItems() => select(
        '${_itemSelect}WHERE i.id IS NOT NULL ORDER BY r.item_type DESC, r.sort_order',
        const [],
        const ['reward_items', _inv],
      ).watch().map((rows) => rows.map(itemFromRow).toList());

  Future<RewardItem?> equippedOf(String itemType) async {
    final rows = await select('${_itemSelect}WHERE i.is_equipped = 1 AND r.item_type = ? LIMIT 1', [itemType]).get();
    return rows.isEmpty ? null : itemFromRow(rows.first);
  }

  Future<({String rewardItemId, bool isEquipped, String itemType})?> inventory(String inventoryId) async {
    final rows = await select(
      'SELECT i.reward_item_id, i.is_equipped, r.item_type FROM $_inv i JOIN reward_items r ON r.id = i.reward_item_id '
      'WHERE i.id = ?',
      [inventoryId],
    ).get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return (rewardItemId: r.s('reward_item_id'), isEquipped: r.b('is_equipped'), itemType: r.s('item_type'));
  }

  /// Trang bị / tháo lạc quan. Trang bị thì tháo món cùng loại (giống `ShopService.equip`).
  Future<void> equipLocal(String inventoryId, bool equipped, int nowMs) async {
    final inv = await inventory(inventoryId);
    if (inv == null) return;
    if (equipped) {
      await update(
        "UPDATE $_inv SET is_equipped = 0, client_updated_at = ?, is_dirty = 1, sync_status = 'pending_update' "
        'WHERE is_equipped = 1 AND id <> ? AND reward_item_id IN (SELECT id FROM reward_items WHERE item_type = ?)',
        [nowMs, inventoryId, inv.itemType],
        const [_inv],
      );
    }
    await update(
      "UPDATE $_inv SET is_equipped = ?, client_updated_at = ?, is_dirty = 1, sync_status = 'pending_update' WHERE id = ?",
      [equipped, nowMs, inventoryId],
      const [_inv],
    );
  }

  /// `InventoryResponse` (mua, trang bị, pull). Ghi kèm `item` vào `reward_items` nếu có.
  Future<void> applyInventory(Map<String, dynamic> inv, {required int nowMs, bool skipIfDirty = false}) async {
    final id = inv['id'] as String;
    final rewardItemId = inv['rewardItemId'] as String;
    if (skipIfDirty) {
      final cur = await select('SELECT is_dirty FROM $_inv WHERE id = ?', [id]).get();
      if (cur.isNotEmpty && cur.first.b('is_dirty')) return;
    }
    final item = inv['item'];
    if (item is Map<String, dynamic>) await db.contentDao.upsertRewardItem(item);
    if ((await select('SELECT COUNT(*) AS c FROM reward_items WHERE id = ?', [rewardItemId]).getSingle()).i('c') == 0) {
      return;
    }
    await deleteWhere(_inv, 'reward_item_id = ? AND id <> ?', [rewardItemId, id]);
    await upsert(_inv, {
      'id': id,
      'reward_item_id': rewardItemId,
      'is_equipped': jBool(inv['isEquipped']),
      'unlocked_at': toEpoch(inv['unlockedAt'] as String?) ?? nowMs,
      'version': jInt(inv['version']),
      'client_updated_at': toEpoch(inv['clientUpdatedAt'] as String?),
      'is_dirty': 0,
      'sync_status': 'synced',
      'last_synced_at': nowMs,
    }, const ['id']);
  }

  static RewardItem itemFromRow(QueryRow r) {
    final colors = r.sN('border_colors');
    return RewardItem(
      id: r.s('id'),
      code: r.s('code'),
      name: r.s('name'),
      type: r.s('item_type'),
      xpCost: r.i('xp_cost'),
      borderColors: colors == null ? const [] : jIntList(jsonDecode(colors)),
      imageUrl: r.sN('image_url'),
      requiredRank: r.i('required_rank'),
      rankBoard: r.s('rank_board'),
      isActive: r.b('is_active'),
      sortOrder: r.i('sort_order'),
      isUnlocked: r.sN('inventory_id') != null,
      isEquipped: r.b('is_equipped'),
      inventoryId: r.sN('inventory_id'),
    );
  }
}
