import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';
import '../vocabulary/topic_screen.dart';
import '../progress/progress_screen.dart';
import '../challenge/challenge_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Sắp xếp các màn hình tương ứng với thứ tự dưới thanh BottomNavigationBar
  List<Widget> get _pages => [
    HomeScreen(
      onSwitchTab: (index) {
        setState(() {
          _currentIndex = index; // Lắng nghe và cập nhật tab khi Home yêu cầu
        });
      },
    ),
    const TopicScreen(),
    const ProgressScreen(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.greyColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Học tập'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Tiến độ'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Thử thách'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
    );
  }
}