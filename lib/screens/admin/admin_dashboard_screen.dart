import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/admin_repository.dart';
import '../../models/admin_models.dart';
import '../../widgets/common.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminOverview? _overview;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final overview = await AdminRepository.overview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(tr('Tổng quan hệ thống'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: tr('Đăng xuất'),
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => signOutAndGoToWelcome(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(children: const [SizedBox(height: 300, child: LoadingView())])
            : _overview == null
                ? ListView(children: [SizedBox(height: 400, child: ErrorView(message: _error ?? '', onRetry: _load))])
                : _buildContent(context, _overview!),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminOverview o) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.3,
            children: [
              // Chỉ đếm tài khoản role USER là học viên; quản trị viên được đếm riêng
              _buildStatCard(tr('Học viên'), '${o.students}', Icons.people, const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  footer: trf('{n} mới trong 7 ngày', {'n': o.newStudentsLast7Days})),
              _buildStatCard(tr('Chủ đề'), '${o.topics}', Icons.library_books, const [Color(0xFF43E97B), Color(0xFF38F9D7)]),
              _buildStatCard(tr('Từ vựng'), '${o.flashcards}', Icons.style, const [Color(0xFFFA709A), Color(0xFFFEE140)]),
              _buildStatCard(tr('Ngữ pháp'), '${o.grammarLessons}', Icons.description, const [Color(0xFFA18CD1), Color(0xFFFBC2EB)]),
              _buildStatCard(tr('Bài kiểm tra'), '${o.quizzes}', Icons.quiz, const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]),
              _buildStatCard(tr('Vật phẩm'), '${o.rewardItems}', Icons.storefront, const [Color(0xFFF6D365), Color(0xFFFDA085)],
                  footer: trf('{n} quản trị viên', {'n': o.admins})),
            ],
          ),
          const SizedBox(height: 30),
          Text(tr('Học viên mới đăng ký'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: o.recentStudents.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(tr('Chưa có học viên nào'), style: const TextStyle(color: AppTheme.greyColor))),
                  )
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: o.recentStudents.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF4F6FA)),
                    itemBuilder: (context, index) {
                      final s = o.recentStudents[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person_add, color: AppTheme.primaryColor)),
                        title: Text(s.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${s.email}${s.createdAt == null ? '' : '  •  ${formatDate(s.createdAt!.toLocal())}'}',
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, List<Color> gradient, {String? footer}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 26),
          const Spacer(),
          Text(count, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          if (footer != null) Text(footer, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}
