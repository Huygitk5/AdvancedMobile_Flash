import 'package:flutter/material.dart';
import 'json_helpers.dart';

class RewardItem {
  final String id;
  final String code;
  final String name;
  final String description;
  final String type; // BORDER | AVATAR
  final int xpCost;
  final List<int> borderColors;
  final String? imageUrl;
  final int requiredRank;
  final bool isActive;

  const RewardItem({
    required this.id,
    this.code = '',
    required this.name,
    this.description = '',
    this.type = 'BORDER',
    this.xpCost = 0,
    this.borderColors = const [],
    this.imageUrl,
    this.requiredRank = 0,
    this.isActive = true,
  });

  bool get isBorder => type == 'BORDER';
  bool get isAvatar => type == 'AVATAR';

  List<Color> get colors => borderColors.map((v) => Color(v)).toList();

  factory RewardItem.fromJson(Map<String, dynamic> json) => RewardItem(
        id: jStr(json, 'id'),
        code: jStr(json, 'code'),
        name: jStr(json, 'name'),
        description: jStr(json, 'description'),
        type: jStr(json, 'itemType', 'BORDER'),
        xpCost: jInt(json, 'xpCost'),
        borderColors: (json['borderColors'] is List) ? (json['borderColors'] as List).whereType<num>().map((e) => e.toInt()).toList() : const [],
        imageUrl: jStrOrNull(json, 'imageUrl'),
        requiredRank: jInt(json, 'requiredRank'),
        isActive: jBool(json, 'isActive', true),
      );
}

/// Vật phẩm trong cửa hàng kèm trạng thái của user hiện tại.
class ShopItem {
  final RewardItem item;
  bool isUnlocked;
  bool isEquipped;
  String? inventoryId;
  final bool canAfford;
  final bool meetsRank;

  ShopItem({
    required this.item,
    this.isUnlocked = false,
    this.isEquipped = false,
    this.inventoryId,
    this.canAfford = false,
    this.meetsRank = true,
  });

  /// Server trả các trường của vật phẩm cùng cấp với isUnlocked / isEquipped / inventoryId / canAfford.
  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        item: RewardItem.fromJson(json),
        isUnlocked: jBool(json, 'isUnlocked'),
        isEquipped: jBool(json, 'isEquipped'),
        inventoryId: jStrOrNull(json, 'inventoryId'),
        canAfford: jBool(json, 'canAfford'),
        meetsRank: jBool(json, 'meetsRankRequirement', true),
      );
}

/// Một món trong kho đồ của user.
class InventoryItem {
  final String id;
  final String rewardItemId;
  bool isEquipped;
  final RewardItem item;

  InventoryItem({required this.id, required this.rewardItemId, required this.isEquipped, required this.item});

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: jStr(json, 'id'),
        rewardItemId: jStr(json, 'rewardItemId'),
        isEquipped: jBool(json, 'isEquipped'),
        item: RewardItem.fromJson(asMap(json['item'])),
      );
}
