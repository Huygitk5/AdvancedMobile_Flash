import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Màu nền xanh nhạt theo ảnh
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildProgressSection(),
              const SizedBox(height: 25),
              _buildSectionTitle('Danh mục học tập', 'Xem tất cả >'),
              const SizedBox(height: 15),
              _buildCategories(),
              const SizedBox(height: 25),
              _buildSectionTitle('Bài học gợi ý cho bạn', 'Xem tất cả >'),
              const SizedBox(height: 15),
              _buildSuggestedLessons(),
              const SizedBox(height: 25),
              _buildSectionTitle('Thử thách hôm nay', 'Xem tất cả >'),
              const SizedBox(height: 15),
              _buildChallengeSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Header: Xin chào, Avatar, Chuỗi ngày (Streak)
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white), // Thay bằng Image.asset nếu có ảnh
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Xin chào,', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                Text('Minh 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Badge(
                smallSize: 8,
                backgroundColor: Colors.red,
                child: Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
              ),
              onPressed: () {},
            ),
            const Icon(Icons.settings_outlined, color: Color(0xFF1E293B)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Hôm nay là một ngày tuyệt vời\nđể học tiếng Anh!',
                style: TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('7 ngày', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
                      Text('Streak học tập', style: TextStyle(color: Colors.orange, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.orange, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Section Tiến độ hôm nay
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Tiến độ hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('3/5 bài >', style: TextStyle(color: AppTheme.greyColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primaryColor,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 15),
              const Text('60%', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tiếp tục học', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('Business Vocabulary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Bài 12/20 • 8 phút', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    ],
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 20,
                  child: Icon(Icons.play_arrow, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Section Danh mục học tập
  Widget _buildCategories() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildCategoryCard('Từ vựng', 'Hơn 2000+ từ', Icons.menu_book, const Color(0xFFE8F5E9), Colors.green)),
            const SizedBox(width: 15),
            Expanded(child: _buildCategoryCard('Ngữ pháp', 'Các chủ điểm', Icons.description, const Color(0xFFF3E5F5), Colors.purple)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildCategoryCard('Listening', 'Luyện nghe', Icons.headphones, const Color(0xFFFFEBEE), Colors.redAccent)),
            const SizedBox(width: 15),
            Expanded(child: _buildCategoryCard('Speaking', 'Luyện nói', Icons.mic, const Color(0xFFFFF3E0), Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
        ],
      ),
    );
  }

  // Section Bài học gợi ý (Scroll ngang)
  Widget _buildSuggestedLessons() {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildLessonCard('Travel Vocabulary', 'A2', 0.6, '20 từ', '8 phút', Colors.blue.shade100),
          const SizedBox(width: 15),
          _buildLessonCard('Present Simple', 'A2', 0.4, '3 bài', '12 phút', Colors.purple.shade100),
          const SizedBox(width: 15),
          _buildLessonCard('Daily Conversation', 'B1', 0.2, '15 câu', '10 phút', Colors.orange.shade100),
        ],
      ),
    );
  }

  Widget _buildLessonCard(String title, String level, double progress, String data1, String data2, Color imageBg) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khu vực ảnh (dùng Container màu tạm, bạn thay bằng Image.asset sau)
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: imageBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(child: Icon(Icons.image, color: Colors.white54, size: 40)),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(level, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 14, color: AppTheme.greyColor),
                    const SizedBox(width: 4),
                    Text(data1, style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 14, color: AppTheme.greyColor),
                    const SizedBox(width: 4),
                    Text(data2, style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Section Thử thách hôm nay
  Widget _buildChallengeSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.amber,
            radius: 24,
            child: Icon(Icons.emoji_events, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Hoàn thành bài kiểm tra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('Kiểm tra kiến thức sau bài học', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {},
            child: const Text('Bắt đầu', style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  // Helper Title
  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(actionText, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}