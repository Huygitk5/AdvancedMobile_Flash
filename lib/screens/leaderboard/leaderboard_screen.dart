import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/leaderboard_user_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late List<LeaderboardUser> xpLeaderboard;
  late List<LeaderboardUser> streakLeaderboard;

  @override
  void initState() {
    super.initState();
    // Tạo 2 danh sách riêng và sắp xếp giảm dần
    xpLeaderboard = List.from(MockData.leaderboardUsers);
    xpLeaderboard.sort((a, b) => b.totalXp.compareTo(a.totalXp));

    streakLeaderboard = List.from(MockData.leaderboardUsers);
    streakLeaderboard.sort((a, b) => b.longestStreak.compareTo(a.longestStreak));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Bảng Xếp Hạng', style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Tổng XP'),
              Tab(text: 'Chuỗi Streak'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListView(xpLeaderboard, isXp: true),
            _buildListView(streakLeaderboard, isXp: false),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<LeaderboardUser> users, {required bool isXp}) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final rank = index + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: rank <= 3 ? Border.all(color: _getRankColor(rank).withOpacity(0.5), width: 1.5) : null,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              // Hạng (Rank)
              SizedBox(
                width: 30,
                child: rank <= 3
                    ? Icon(Icons.emoji_events, color: _getRankColor(rank), size: 28)
                    : Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor, fontSize: 16)),
              ),
              const SizedBox(width: 15),

              // Avatar (Lấy ký tự đầu của tên)
              CircleAvatar(
                radius: 22,
                backgroundColor: _getRankColor(rank).withOpacity(0.1),
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(color: _getRankColor(rank), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 15),

              // Tên và Ghi chú
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(user.note, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Chỉ số XP hoặc Streak
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isXp ? '${user.totalXp}' : '${user.longestStreak}',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isXp ? Colors.amber.shade600 : Colors.orange.shade600),
                  ),
                  Text(
                    isXp ? 'XP' : 'Ngày',
                    style: const TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // Hàm phụ trợ lấy màu theo thứ hạng (Top 1 Vàng, Top 2 Bạc, Top 3 Đồng)
  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Vàng
    if (rank == 2) return const Color(0xFFC0C0C0); // Bạc
    if (rank == 3) return const Color(0xFFCD7F32); // Đồng
    return AppTheme.primaryColor; // Hạng 4-50
  }
}