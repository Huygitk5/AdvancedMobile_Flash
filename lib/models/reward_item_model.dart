class RewardItem {
  final String id;
  final String name;
  final String type; // 'border' hoặc 'avatar'
  final int xpCost;
  final List<int> borderColors;
  final String? imageUrl; // THÊM TRƯỜNG NÀY CHO AVATAR
  final int requiredRank;
  bool isUnlocked;
  bool isEquipped;

  RewardItem({
    required this.id,
    required this.name,
    required this.type,
    required this.xpCost,
    required this.borderColors,
    this.imageUrl, // Thêm vào constructor
    this.requiredRank = 0,
    this.isUnlocked = false,
    this.isEquipped = false,
  });
}