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

  List<Widget> get _pages => [
    HomeScreen(onSwitchTab: (index) => setState(() => _currentIndex = index)),
    const TopicScreen(),
    const ProgressScreen(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Ép nội dung tràn xuống đáy màn hình
      body: _pages[_currentIndex],

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent, // Xóa bỏ khối màu đặc phía sau
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  selectedItemColor: AppTheme.primaryColor,
                  unselectedItemColor: AppTheme.greyColor,
                  showUnselectedLabels: true,
                  showSelectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).cardColor,
                  elevation: 0,
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: const [
                    BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_filled)), label: 'Trang chủ'),
                    BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.menu_book)), label: 'Học tập'),
                    BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.bar_chart)), label: 'Tiến độ'),
                    BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.emoji_events_outlined)), label: 'Thử thách'),
                    BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), label: 'Cá nhân'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}