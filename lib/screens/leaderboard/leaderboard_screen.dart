import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common.dart';
import '../profile/profile_screen.dart' show borderColorsOf;

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
          title: Text(tr('Top 10 Vinh Danh'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [Tab(text: tr('Tổng Point (XP)')), Tab(text: tr('Chuỗi Streak'))],
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

  String get _unit => isXp ? 'Point' : tr('Ngày');

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(leaderboardRepositoryProvider).load(board, force: true);
    ref.invalidate(leaderboardProvider(board));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lb = ref.watch(leaderboardProvider(board));
    final myId = ref.watch(profileProvider).value?.id;
    return lb.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(message: trf('Không tải được bảng xếp hạng: {e}', {'e': e}), onRetry: () => _refresh(ref)),
      data: (data) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: data == null
            ? ListView(children: [
                SizedBox(
                    height: 300,
                    child: EmptyView(message: tr('Cần kết nối mạng để xem bảng xếp hạng.'), icon: Icons.cloud_off_rounded)),
              ])
            : data.items.isEmpty
                ? ListView(children: [
                    SizedBox(
                        height: 300,
                        child: EmptyView(message: tr('Chưa có ai trên bảng xếp hạng'), icon: Icons.emoji_events_outlined)),
                  ])
                : ListView(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                    children: [
                      if (data.me != null) _buildMe(context, ref, data.me!),
                      ...data.items.map((e) => _entryCard(context, e, isMe: e.userId == myId)),
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
                Text(tr('Hạng của bạn'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                Text(user?.fullName ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Text('${me.score}',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isXp ? Colors.amber.shade600 : Colors.orange.shade600)),
          const SizedBox(width: 4),
          Text(_unit, style: const TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _entryCard(BuildContext context, LeaderboardEntry entry, {required bool isMe}) {
    final rank = entry.rank;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topColor = _rankColor(rank);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? (isDark ? const Color(0xFF1F2E4A) : const Color(0xFFF0F5FF)) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: rank <= 3
            ? Border.all(color: topColor, width: 2)
            : (isMe ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5)) : null),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: rank <= 3
                ? Icon(Icons.emoji_events, color: topColor, size: 28)
                : Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor, fontSize: 15)),
          ),
          const SizedBox(width: 10),
          // Viền đang trang bị của người chơi; ảnh được cắt tròn bên trong viền nên không bị tràn
          UserAvatar(
            size: 50,
            ringWidth: 3,
            borderColors: borderColorsOf(entry.equippedBorderColors),
            imageUrl: entry.avatarUrl,
            initials: initialsOf(entry.fullName),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isMe ? '${entry.fullName} (${tr('Bạn')})' : entry.fullName,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  entry.slogan.isEmpty ? tr('Chưa có câu châm ngôn') : entry.slogan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppTheme.greyColor,
                      fontSize: 12,
                      // Chỉ in nghiêng slogan thật, câu mặc định thì chữ thường
                      fontStyle: entry.slogan.isNotEmpty ? FontStyle.italic : FontStyle.normal),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.score}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isXp ? Colors.amber.shade600 : Colors.orange.shade600)),
              Text(_unit, style: const TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8); // Màu bạc xám xanh nổi bật
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.primaryColor;
  }
}
