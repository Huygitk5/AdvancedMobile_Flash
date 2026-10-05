import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import 'admin_content_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_economy_screen.dart';
import 'admin_users_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  Widget get _page {
    switch (_currentIndex) {
      case 1:
        return const AdminUsersScreen();
      case 2:
        return const AdminContentScreen();
      case 3:
        return const AdminEconomyScreen();
      default:
        return const AdminDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.greyColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: tr('Tổng quan')),
          BottomNavigationBarItem(icon: const Icon(Icons.people_alt), label: tr('Học viên')),
          BottomNavigationBarItem(icon: const Icon(Icons.library_books), label: tr('Nội dung')),
          BottomNavigationBarItem(icon: const Icon(Icons.storefront), label: tr('Kinh tế')),
        ],
      ),
    );
  }
}
