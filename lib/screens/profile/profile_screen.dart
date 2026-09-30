import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
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
              // Thẻ thông tin User
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
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Color(0xFFEEF2FF),
                          child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Đoàn Quốc Huy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              SizedBox(height: 5),
                              Text('huy_dev@gmail.com', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                              SizedBox(height: 10),
                              Text('A2', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('120 / 600 XP', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 120 / 600,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primaryColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Thẻ thống kê
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
                    _buildStatTile(Icons.task_alt, Colors.blue, 'Số bài học hoàn thành', '18'),
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