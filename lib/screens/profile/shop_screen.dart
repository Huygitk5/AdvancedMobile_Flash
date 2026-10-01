import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/reward_item_model.dart';
import '../../models/user_inventory_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late List<RewardItem> shopItems;
  final int currentUserRank = 1;

  @override
  void initState() {
    super.initState();
    shopItems = MockData.shopItems; // Lấy danh mục sản phẩm từ DB
  }

  // Hàm check xem user đã mua chưa
  bool _isItemUnlocked(String itemId) {
    return MockData.myInventory.any((inv) => inv.rewardItemId == itemId);
  }

  // Hàm check xem user có đang dùng không
  bool _isItemEquipped(String itemId) {
    return MockData.myInventory.any((inv) => inv.rewardItemId == itemId && inv.isEquipped);
  }

  void _unlockItem(RewardItem item) {
    if (item.requiredRank > 0 && currentUserRank > item.requiredRank) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cần đạt Top ${item.requiredRank} Bảng xếp hạng!'), backgroundColor: Colors.red));
      return;
    }
    if (MockData.currentUser.currentXp >= item.xpCost) {
      setState(() {
        MockData.currentUser.currentXp -= item.xpCost;
        // Thêm vật phẩm mới vào Kho đồ của User (Mô phỏng POST request)
        MockData.myInventory.add(UserInventory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: MockData.currentUser.id,
            rewardItemId: item.id,
            isEquipped: false,
            unlockedAt: DateTime.now()
        ));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã mua: ${item.name}!'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không đủ XP!'), backgroundColor: Colors.red));
    }
  }

  void _equipItem(RewardItem item) {
    setState(() {
      // Bỏ trang bị tất cả đồ cùng loại (Mô phỏng PUT request)
      for (var inv in MockData.myInventory) {
        var shopItem = shopItems.firstWhere((s) => s.id == inv.rewardItemId);
        if (shopItem.type == item.type) inv.isEquipped = false;
      }
      // Trang bị đồ mới
      var targetInv = MockData.myInventory.firstWhere((inv) => inv.rewardItemId == item.id);
      targetInv.isEquipped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cửa hàng XP', style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    // Hiển thị XP hiện tại trực tiếp từ Model
                    Text('${MockData.currentUser.currentXp}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
        itemCount: shopItems.length,
        itemBuilder: (context, index) {
          final item = shopItems[index];
          List<Color> gradientColors = item.borderColors.map((hex) => Color(hex)).toList();

          return Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(radius: 30, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.person, size: 35, color: AppTheme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 15),
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 15),

                if (_isItemEquipped(item.id))
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text('Đang dùng', style: TextStyle(fontSize: 12)),
                  )
                else if (_isItemUnlocked(item.id))
                  ElevatedButton(
                    onPressed: () => _equipItem(item),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text('Sử dụng', style: TextStyle(fontSize: 12, color: Colors.white)),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _unlockItem(item),
                    icon: Icon(item.requiredRank > 0 ? Icons.lock : Icons.stars, size: 14, color: Colors.white),
                    label: Text(item.requiredRank > 0 ? 'Top ${item.requiredRank} + ${item.xpCost}' : '${item.xpCost}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: item.requiredRank > 0 ? Colors.grey.shade400 : Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}