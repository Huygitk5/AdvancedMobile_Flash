import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';

/// Top 10 XP / Streak: gọi API khi online và cache quá 5 phút; offline hiện bản cache.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('Top 10 Vinh Danh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [Tab(text: 'Tổng Point (XP)'), Tab(text: 'Chuỗi Streak')],
          ),
        ),
        body: const TabBarView(
          children: [
            _BoardView(board: 'XP'),
            _BoardView(board: 'STREAK'),
          ],
        ),
      ),
    );
  }
}

class _BoardView extends ConsumerWidget {
  const _BoardView({required this.board});

  final String board;

  bool get isXp => board == 'XP';

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(leaderboardRepositoryProvider).load(board, force: true);
    ref.invalidate(leaderboardProvider(board));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lb = ref.watch(leaderboardProvider(board));
    return lb.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Không tải được bảng xếp hạng: $e')),
      data: (data) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: data == null || data.items.isEmpty
            ? ListView(children: const [
                SizedBox(height: 120),
                Center(child: Text('Cần kết nối mạng để xem bảng xếp hạng.', style: TextStyle(color: AppTheme.greyColor))),
              ])
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (data.me != null) _buildMe(context, ref, data.me!),
                  ...data.items.map((e) => _buildEntry(context, e)),
                ],
              ),
      ),
    );
  }

  Widget _buildMe(BuildContext context, WidgetRef ref, LeaderboardMe me) {
    final user = ref.watch(profileProvider).value;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(me.rank == null ? '—' : '#${me.rank}',
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor, fontSize: 16)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hạng của bạn', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                Text(user?.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Text('${me.score}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isXp ? Colors.amber.shade600 : Colors.orange.shade600)),
          const SizedBox(width: 4),
          Text(isXp ? 'Point' : 'Ngày', style: const TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEntry(BuildContext context, LeaderboardEntry user) {
    final rank = user.rank;
    final border = user.equippedBorderColors.map((c) => Color(c)).toList();
    final hasAvatar = (user.avatarUrl ?? '').isNotEmpty;
    final initial = user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase();

    final avatar = CircleAvatar(
      radius: 22,
      backgroundColor: _getRankColor(rank).withValues(alpha: 0.1),
      backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
      child: hasAvatar ? null : Text(initial, style: TextStyle(color: _getRankColor(rank), fontWeight: FontWeight.bold, fontSize: 18)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: rank <= 3 ? Border.all(color: _getRankColor(rank), width: 2.0) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: rank <= 3
                ? Icon(Icons.emoji_events, color: _getRankColor(rank), size: 28)
                : Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor, fontSize: 16)),
          ),
          const SizedBox(width: 15),
          // Viền đang trang bị (ARGB) của người chơi
          border.isEmpty
              ? avatar
              : Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: border.length == 1 ? [border.first, border.first] : border),
                  ),
                  child: avatar,
                ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.score}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isXp ? Colors.amber.shade600 : Colors.orange.shade600),
              ),
              Text(isXp ? 'Point' : 'Ngày', style: const TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8); // Màu bạc xám xanh nổi bật
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.primaryColor;
  }
}
