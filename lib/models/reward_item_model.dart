import '_json.dart';

class RewardItem {
  final String id;
  final String code;
  final String name;
  final String? description;

  /// 'BORDER' | 'AVATAR' (giữ nguyên chuỗi server).
  final String type;
  final int xpCost;

  /// ARGB int.
  final List<int> borderColors;
  final String? imageUrl;
  final int requiredRank;

  /// 'XP' | 'STREAK'
  final String rankBoard;
  final bool isActive;
  final int sortOrder;

  // --- trạng thái của user ---
  final bool isUnlocked;
  final bool isEquipped;
  final String? inventoryId;

  /// Chỉ có khi lấy từ `GET /v1/shop/items` lúc online; null = chưa biết.
  final bool? canAfford;
  final bool? meetsRankRequirement;

  const RewardItem({
    required this.id,
    this.code = '',
    required this.name,
    this.description,
    required this.type,
    required this.xpCost,
    this.borderColors = const [],
    this.imageUrl,
    this.requiredRank = 0,
    this.rankBoard = 'XP',
    this.isActive = true,
    this.sortOrder = 0,
    this.isUnlocked = false,
    this.isEquipped = false,
    this.inventoryId,
    this.canAfford,
    this.meetsRankRequirement,
  });

  bool get isBorder => type == 'BORDER';
  bool get isAvatar => type == 'AVATAR';

  /// `RewardItemResponse` / `ShopItemResponse` (item được unwrap cùng cấp).
  factory RewardItem.fromJson(Map<String, dynamic> j) => RewardItem(
        id: j['id'] as String,
        code: jStr(j['code']),
        name: jStr(j['name']),
        description: j['description'] as String?,
        type: jStr(j['itemType'], 'BORDER'),
        xpCost: jInt(j['xpCost']),
        borderColors: jIntList(j['borderColors']),
        imageUrl: j['imageUrl'] as String?,
        requiredRank: jInt(j['requiredRank']),
        rankBoard: jStr(j['rankBoard'], 'XP'),
        isActive: jBool(j['isActive'], true),
        sortOrder: jInt(j['sortOrder']),
        isUnlocked: jBool(j['isUnlocked']),
        isEquipped: jBool(j['isEquipped']),
        inventoryId: j['inventoryId'] as String?,
        canAfford: j['canAfford'] as bool?,
        meetsRankRequirement: j['meetsRankRequirement'] as bool?,
      );
}
