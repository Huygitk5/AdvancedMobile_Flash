import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart'; // Import UserModel chuẩn

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late List<UserModel> xpLeaderboard;
  late List<UserModel> streakLeaderboard;

  @override
  void initState() {
    super.initState();
    // Lấy Top 10 Point
    List<UserModel> xpList = List<UserModel>.from(MockData.users);
    xpList.sort((a, b) => b.totalLifetimeXp.compareTo(a.totalLifetimeXp));
    xpLeaderboard = xpList.take(10).toList();

    // Lấy Top 10 Streak
    List<UserModel> streakList = List<UserModel>.from(MockData.users);
    streakList.sort((a, b) => b.longestStreak.compareTo(a.longestStreak));
    streakLeaderboard = streakList.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new,  size: 20), onPressed: () => Navigator.pop(context)),
          title: Text('Top 10 Vinh Danh', style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [Tab(text: 'Tổng Point (XP)'), Tab(text: 'Chuỗi Streak')],
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

  Widget _buildListView(List<UserModel> users, {required bool isXp}) {
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: rank <= 3 ? Border.all(color: _getRankColor(rank), width: 2.0) : null,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: rank <= 3
                    ? Icon(Icons.emoji_events, color: _getRankColor(rank), size: 28)
                    : Text('#$rank', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor, fontSize: 16)),
              ),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 22,
                backgroundColor: _getRankColor(rank).withOpacity(0.1),
                // Lấy chữ cái đầu của fullName
                child: Text(user.fullName[0].toUpperCase(), style: TextStyle(color: _getRankColor(rank), fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị fullName và slogan
                    Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(user.slogan, style: TextStyle(color: AppTheme.greyColor, fontSize: 12, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isXp ? '${user.totalLifetimeXp}' : '${user.longestStreak}',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isXp ? Colors.amber.shade600 : Colors.orange.shade600),
                  ),
                  Text(isXp ? 'Point' : 'Ngày', style: TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8); // Màu bạc xám xanh nổi bật
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.primaryColor;
  }
}