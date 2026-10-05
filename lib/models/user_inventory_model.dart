/// Một dòng `user_inventories` (DB local chỉ chứa 1 user nên không có userId).
class UserInventory {
  final String id;
  final String rewardItemId;
  final bool isEquipped;
  final DateTime unlockedAt;
  final DateTime? clientUpdatedAt;

  const UserInventory({
    required this.id,
    required this.rewardItemId,
    required this.isEquipped,
    required this.unlockedAt,
    this.clientUpdatedAt,
  });
}
