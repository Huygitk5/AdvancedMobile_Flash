class UserInventory {
  final String id;
  final String userId;
  final String rewardItemId;
  bool isEquipped;
  final DateTime unlockedAt;

  UserInventory({
    required this.id, required this.userId, required this.rewardItemId,
    required this.isEquipped, required this.unlockedAt
  });

  factory UserInventory.fromJson(Map<String, dynamic> json) {
    return UserInventory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      rewardItemId: json['rewardItemId'] ?? '',
      isEquipped: json['isEquipped'] ?? false,
      unlockedAt: DateTime.parse(json['unlockedAt']),
    );
  }
}