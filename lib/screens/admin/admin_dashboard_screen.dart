import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../splash/welcome_screen.dart';
import '../../data/mock_data.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor, elevation: 0, automaticallyImplyLeading: false,
        title: Text('Tổng quan hệ thống', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.logout, color: Theme.of(context).cardColor), onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.3,
              children: [
                _buildStatCard(context, 'Học viên', '${MockData.users.length}', Icons.people, const [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
                _buildStatCard(context, 'Chủ đề', '${MockData.vocabularyTopics.length}', Icons.library_books, const [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                _buildStatCard(context, 'Từ vựng', '${MockData.flashcards.length}', Icons.style, const [Color(0xFFFA709A), Color(0xFFFEE140)]),
                _buildStatCard(context, 'Vật phẩm', '${MockData.shopItems.length}', Icons.storefront, const [Color(0xFFF6D365), Color(0xFFFDA085)]),
              ],
            ),
            const SizedBox(height: 30),
            Text('Hoạt động gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
                itemCount: 4,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF4F6FA)),
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(Icons.person_add, color: AppTheme.primaryColor)),
                  title: Text('Người dùng mới đăng ký', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  subtitle: Text('10 phút trước', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const Spacer(),
          Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}