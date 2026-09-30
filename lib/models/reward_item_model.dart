class RewardItem {
  final String id;
  final String name;
  final String type; // 'border' hoặc 'avatar'
  final int xpCost;
  final List<int> borderColors; // Mã màu hex để vẽ gradient viền
  bool isUnlocked;
  bool isEquipped;

  RewardItem({
    required this.id,
    required this.name,
    required this.type,
    required this.xpCost,
    required this.borderColors,
    this.isUnlocked = false,
    this.isEquipped = false,
  });
}