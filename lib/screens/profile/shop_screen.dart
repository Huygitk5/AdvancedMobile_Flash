import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/reward_item_model.dart';

class ShopScreen extends StatefulWidget {
  final int currentXp;
  const ShopScreen({Key? key, required this.currentXp}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late int userXp;
  late List<RewardItem> items;

  @override
  void initState() {
    super.initState();
    userXp = widget.currentXp;
    items = MockData.shopItems;
  }

  void _unlockItem(RewardItem item) {
    if (userXp >= item.xpCost) {
      setState(() {
        userXp -= item.xpCost;
        item.isUnlocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã mở khóa: ${item.name}!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đủ XP! Hãy làm thêm thử thách.'), backgroundColor: Colors.red),
      );
    }
  }

  void _equipItem(RewardItem item) {
    setState(() {
      for (var i in items) {
        if (i.type == item.type) i.isEquipped = false;
      }
      item.isEquipped = true;
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
          onPressed: () => Navigator.pop(context, userXp), // Trả về XP còn lại khi thoát
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
                    Text('$userXp', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          List<Color> gradientColors = item.borderColors.map((hex) => Color(hex)).toList();

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hiển thị Preview Viền Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFEEF2FF),
                      child: Icon(Icons.person, size: 35, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 15),

                // Nút trạng thái
                if (item.isEquipped)
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green, side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Đang dùng', style: TextStyle(fontSize: 12)),
                  )
                else if (item.isUnlocked)
                  ElevatedButton(
                    onPressed: () => _equipItem(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Sử dụng', style: TextStyle(fontSize: 12, color: Colors.white)),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _unlockItem(item),
                    icon: const Icon(Icons.lock, size: 14, color: Colors.white),
                    label: Text('${item.xpCost}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}