import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/auth_providers.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';

typedef _DashboardStats = ({int users, int topics, int words, int items});

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Future<_DashboardStats>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() { _future = _fetch(); });

  Future<_DashboardStats> _fetch() async {
    final api = ref.read(adminApiProvider);
    final results = await Future.wait([api.users(size: 1), api.topics(size: 100), api.rewardItems()]);
    final users = results[0] as dynamic;
    final topics = results[1] as dynamic;
    final items = results[2] as List;
    return (
      users: users.totalElements as int,
      topics: topics.totalElements as int,
      words: (topics.items as List).fold<int>(0, (a, t) => a + (t.totalWords as int)),
      items: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor, elevation: 0, automaticallyImplyLeading: false,
        title: Text('Tổng quan hệ thống', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: Theme.of(context).cardColor), onPressed: _load),
          // StartGate đưa về màn đăng nhập.
          IconButton(icon: Icon(Icons.logout, color: Theme.of(context).cardColor), onPressed: () => ref.read(authStateProvider.notifier).logout()),
        ],
      ),
      body: AdminAsync<_DashboardStats>(
        future: _future,
        onRetry: _load,
        builder: (s) => SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.3,
            children: [
              _buildStatCard(context, 'Học viên', '${s.users}', Icons.people, const [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
              _buildStatCard(context, 'Chủ đề', '${s.topics}', Icons.library_books, const [Color(0xFF43E97B), Color(0xFF38F9D7)]),
              _buildStatCard(context, 'Từ vựng', '${s.words}', Icons.style, const [Color(0xFFFA709A), Color(0xFFFEE140)]),
              _buildStatCard(context, 'Vật phẩm', '${s.items}', Icons.storefront, const [Color(0xFFF6D365), Color(0xFFFDA085)]),
            ],
          ),
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
          boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))]
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
