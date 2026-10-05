import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/game_repository.dart';
import '../../models/leaderboard_model.dart';
import '../../widgets/common.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Leaderboard? _xp;
  Leaderboard? _streak;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _xp == null;
      _error = null;
    });
    try {
      final results = await Future.wait([GameRepository.leaderboard('xp'), GameRepository.leaderboard('streak')]);
      if (!mounted) return;
      setState(() {
        _xp = results[0];
        _streak = results[1];
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
        body: _loading
            ? const LoadingView()
            : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : TabBarView(children: [_buildList(_xp!, isXp: true), _buildList(_streak!, isXp: false)]),
      ),
    );
  }

  Widget _buildList(Leaderboard board, {required bool isXp}) {
    final myId = AppState.I.user?.id;
    final inTop = board.items.any((e) => e.userId == myId);
    return RefreshIndicator(
      onRefresh: _load,
      child: board.items.isEmpty
          ? ListView(children: [SizedBox(height: 300, child: EmptyView(message: tr('Chưa có ai trên bảng xếp hạng'), icon: Icons.emoji_events_outlined))])
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
              itemCount: board.items.length + (!inTop && board.myRank != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == board.items.length) return _myRankCard(board, isXp);
                return _entryCard(board.items[index], isXp: isXp, isMe: board.items[index].userId == myId);
              },
            ),
    );
  }

  Widget _entryCard(LeaderboardEntry entry, {required bool isXp, required bool isMe}) {
    final rank = entry.rank;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topColor = _rankColor(rank);
    final borderColors = entry.colors.isNotEmpty ? entry.colors : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? (isDark ? const Color(0xFF1F2E4A) : const Color(0xFFF0F5FF)) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: rank <= 3 ? Border.all(color: topColor, width: 2) : (isMe ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5)) : null),
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
            borderColors: borderColors,
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
                  style: TextStyle(color: AppTheme.greyColor, fontSize: 12, fontStyle: FontStyle.italic.takeIf(entry.slogan.isNotEmpty)),
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
              Text(isXp ? 'Point' : tr('Ngày'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _myRankCard(Leaderboard board, bool isXp) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_circle_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(trf('Hạng của bạn: #{r}', {'r': board.myRank ?? 0}),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
          Text('${board.myScore} ${isXp ? 'Point' : tr('Ngày')}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFF94A3B8);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.primaryColor;
  }
}

extension on FontStyle {
  /// Chỉ in nghiêng khi [condition] đúng (slogan thật), còn câu mặc định thì chữ thường.
  FontStyle takeIf(bool condition) => condition ? this : FontStyle.normal;
}
