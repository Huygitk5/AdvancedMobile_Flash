import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart'; // Bổ sung import dữ liệu
import '../../widgets/reminder_dialog.dart';
import '../vocabulary/topic_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../challenge/challenge_screen.dart';
import '../grammar/grammar_detail_screen.dart';
import '../leaderboard/leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onSwitchTab; // Bổ sung hàm callback để đổi tab
  const HomeScreen({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 25),
              _buildProgressSection(context),
              const SizedBox(height: 25),

              _buildSectionTitle('Danh mục học tập'),
              const SizedBox(height: 15),
              _buildCategories(context),
              const SizedBox(height: 25),

              _buildSectionTitle('Bài học gợi ý cho bạn'),
              const SizedBox(height: 15),
              _buildSuggestedLessons(context), // Truyền context vào đây
              const SizedBox(height: 25),

              _buildSectionTitle('Thử thách hôm nay'),
              const SizedBox(height: 15),
              _buildChallengeSection(context),
              const SizedBox(height: 25),

              _buildLeaderboardBanner(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Lấy thông tin user hiện tại
    final user = MockData.currentUser;

    // Hàm lấy màu viền đang được dùng từ Shop
    List<Color> getEquippedBorderColors() {
      final equipped = MockData.shopItems.firstWhere(
            (item) => item.isEquipped && item.type == 'border',
        orElse: () => MockData.shopItems[0],
      );
      return equipped.borderColors.map((hex) => Color(hex)).toList();
    }

    return Column(
      children: [
        Row(
          children: [
            // Thay thế CircleAvatar cũ bằng Avatar có viền Gradient
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: getEquippedBorderColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(Icons.person, color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Xin chào,', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                // Sử dụng fullName từ dữ liệu động
                Text('${user.fullName} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Badge(
                smallSize: 8,
                backgroundColor: Colors.red,
                child: Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
              ),
              onPressed: () => ReminderDialog.show(context),
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
                    children: [
                      // Lấy số ngày streak từ dữ liệu động
                      Text('${user.streakDays} ngày', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
                      const Text('Streak học tập', style: TextStyle(color: Colors.orange, fontSize: 10)),
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

  Widget _buildProgressSection(BuildContext context) {
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
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardScreen(topicTitle: 'Business Vocabulary')));
            },
            child: Container(
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
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryCard(
            'Từ vựng', 'Hơn 2000+ từ', Icons.menu_book, const Color(0xFFE8F5E9), Colors.green,
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TopicScreen(initialIndex: 0))),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildCategoryCard(
            'Ngữ pháp', 'Các chủ điểm', Icons.description, const Color(0xFFF3E5F5), Colors.purple,
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TopicScreen(initialIndex: 1))),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildSuggestedLessons(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: MockData.suggestedLessons.map((lesson) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: _buildLessonCard(
                lesson.title,
                lesson.level,
                lesson.progress,
                lesson.itemCounts,
                lesson.estimatedTime,
                lesson.imageBg,
                    () {
                      if (lesson.type == 'vocabulary') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardScreen(topicTitle: lesson.title)));
                      } else if (lesson.type == 'grammar') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GrammarDetailScreen(title: lesson.title)));
                      }
                }
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonCard(String title, String level, double progress, String data1, String data2, Color imageBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }

  Widget _buildChallengeSection(BuildContext context) {
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
            onPressed: () {
              if (onSwitchTab != null) {
                onSwitchTab!(3);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengeScreen()));
              }
            },
            child: const Text('Bắt đầu', style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Top 10 Vinh Danh',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xem vị trí của bạn và các học viên khác',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
    );
  }
}