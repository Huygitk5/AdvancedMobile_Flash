import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_content_screen.dart';
import 'admin_economy_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // Danh sách 4 màn hình chức năng của Admin
  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
    const AdminContentScreen(),
    const AdminEconomyScreen(),
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
        elevation: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Học viên'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Nội dung'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Kinh tế'),
        ],
      ),
    );
  }
}