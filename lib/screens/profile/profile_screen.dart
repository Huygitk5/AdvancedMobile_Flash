import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import 'settings_screen.dart';
import 'shop_screen.dart'; // Import màn hình Shop

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentTotalXp = 1200; // Số điểm giả lập

  // Lấy viền đang được trang bị từ MockData
  List<Color> get equippedBorderColors {
    final equipped = MockData.shopItems.firstWhere(
          (item) => item.isEquipped && item.type == 'border',
      orElse: () => MockData.shopItems[0],
    );
    return equipped.borderColors.map((hex) => Color(hex)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        title: const Text('Hồ sơ cá nhân', style: TextStyle(color: Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E293B)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Thẻ thông tin User & Avatar có viền
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // VẼ VIỀN AVATAR (Border Gradient)
                        Container(
                          padding: const EdgeInsets.all(4), // Độ dày của viền
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: equippedBorderColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2), // Khoảng cách trắng giữa viền và avatar
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundColor: Color(0xFFEEF2FF),
                              child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Đoàn Quốc Huy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              const SizedBox(height: 5),
                              const Text('huy_dev@gmail.com', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text('A2', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
                                  const Icon(Icons.stars, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('$currentTotalXp XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    // NÚT VÀO CỬA HÀNG
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF7E6),
                          foregroundColor: Colors.orange,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        icon: const Icon(Icons.storefront),
                        label: const Text('Cửa hàng đổi thưởng', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          // Điều hướng sang Shop và nhận lại XP thừa nếu có chi tiêu
                          final updatedXp = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ShopScreen(currentXp: currentTotalXp)),
                          );
                          if (updatedXp != null) {
                            setState(() {
                              currentTotalXp = updatedXp as int;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Thống kê... (Giữ nguyên phần dưới của bạn)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    _buildStatTile(Icons.local_fire_department, Colors.orange, 'Streak', '7 ngày'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.menu_book, Colors.green, 'Tổng số từ đã học', '248'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.task_alt, Colors.blue, 'Số bài hoàn thành', '18'),
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
      title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B))),
      trailing: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
    );
  }
}