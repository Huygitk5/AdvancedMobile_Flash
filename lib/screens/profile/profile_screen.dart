import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/reward_item_model.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  List<Color> get equippedBorderColors {
    try {
      final inv = MockData.myInventory.firstWhere((i) => i.isEquipped && MockData.shopItems.firstWhere((s) => s.id == i.rewardItemId).type == 'border');
      final item = MockData.shopItems.firstWhere((s) => s.id == inv.rewardItemId);
      return item.borderColors.map((hex) => Color(hex)).toList();
    } catch (e) {
      return [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)]; // Trắng xám mặc định
    }
  }

  RewardItem? get equippedAvatar {
    try {
      final inv = MockData.myInventory.firstWhere((i) => i.isEquipped && MockData.shopItems.firstWhere((s) => s.id == i.rewardItemId).type == 'avatar');
      return MockData.shopItems.firstWhere((s) => s.id == inv.rewardItemId);
    } catch (e) { return null; }
  }

  void _showEditNoteDialog() {
    TextEditingController noteController = TextEditingController(text: MockData.currentUser.slogan);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cập nhật Slogan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: noteController,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: 'Nhập câu châm ngôn của bạn...',
            filled: true,
            fillColor: const Color(0xFFF4F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              setState(() {
                // Cập nhật Slogan thẳng vào UserModel
                MockData.currentUser.slogan = noteController.text.trim();
              });
              Navigator.pop(context);
            },
            child: Text('Lưu', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gọi user hiện tại
    final user = MockData.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text('Hồ sơ cá nhân', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: equippedBorderColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFFEEF2FF),
                            backgroundImage: (equippedAvatar != null && equippedAvatar!.imageUrl != null && equippedAvatar!.imageUrl!.isNotEmpty)
                                ? NetworkImage(equippedAvatar!.imageUrl!) as ImageProvider
                                : null,
                            child: (equippedAvatar == null || equippedAvatar!.imageUrl == null || equippedAvatar!.imageUrl!.isEmpty)
                                ? Icon(Icons.person, size: 40, color: AppTheme.primaryColor)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Lấy Tên từ UserModel
                                  Expanded(
                                    child: Text(user.fullName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                                    child: Text('Top 1 Point', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Lấy Email từ UserModel
                              Text(user.email, style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: _showEditNoteDialog,
                                child: Row(
                                  children: [
                                    Expanded(
                                      // Lấy Slogan từ UserModel
                                      child: Text(user.slogan, style: TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    Icon(Icons.edit, size: 14, color: AppTheme.primaryColor),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Lấy Level
                                  Text(user.level, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
                                  Icon(Icons.stars, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  // Lấy XP hiện tại để mua sắm
                                  Text('${user.currentXp} XP', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF7E6), foregroundColor: Colors.orange, elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        icon: Icon(Icons.storefront),
                        label: Text('Cửa hàng đổi thưởng', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          // Điều hướng sang Shop, đợi quay về rồi reload UI để cập nhật XP/Viền mới
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen()));
                          setState(() {});
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // Cập nhật động dữ liệu thống kê từ UserModel
                    _buildStatTile(Icons.local_fire_department, Colors.orange, 'Streak', '${user.streakDays} ngày'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.menu_book, Colors.green, 'Tổng số từ đã học', '${user.totalWordsLearned}'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.task_alt, Colors.blue, 'Số bài hoàn thành', '${user.completedLessons}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(IconData icon, Color iconColor, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(fontSize: 15, )),
      trailing: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, )),
    );
  }
}
