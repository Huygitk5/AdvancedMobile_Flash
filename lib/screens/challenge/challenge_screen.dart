import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/game_repository.dart';
import '../../models/quest_model.dart';
import '../../widgets/common.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  List<Quest> _quests = const [];
  bool _loading = true;
  String? _error;
  String? _claimingId;

  @override
  void initState() {
    super.initState();
    AppState.I.addListener(_onUserChanged);
    _load();
  }

  @override
  void dispose() {
    AppState.I.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([GameRepository.todayQuests(), AppState.I.refreshAll()]);
      if (!mounted) return;
      setState(() {
        _quests = (results[0] as TodayQuests).quests;
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

  Future<void> _claim(Quest quest) async {
    if (_claimingId != null) return;
    setState(() => _claimingId = quest.id);
    try {
      final xp = await GameRepository.claimQuest(quest);
      if (!mounted) return;
      showAppSnack(context, trf('Tuyệt vời! Bạn nhận được +{xp} XP', {'xp': xp}), icon: Icons.stars);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
    if (mounted) setState(() => _claimingId = null);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.I.user;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(tr('Thử thách'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 100 + MediaQuery.of(context).padding.bottom),
          children: [
            // Thẻ XP: số dư và tổng tích lũy đều lấy từ hồ sơ do server quản lý
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3366FF), Color(0xFF5A85FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.stars, color: Colors.amber, size: 40),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Tổng điểm XP'), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                          child: Text(
                            '${user?.currentXp ?? 0}',
                            key: ValueKey<int>(user?.currentXp ?? 0),
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(trf('Tích lũy: {n} XP', {'n': user?.totalLifetimeXp ?? 0}),
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(tr('Nhiệm vụ hôm nay'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (_loading)
              const LoadingView()
            else if (_error != null)
              ErrorView(message: _error!, onRetry: _load)
            else if (_quests.isEmpty)
              EmptyView(message: tr('Hôm nay chưa có nhiệm vụ nào'), icon: Icons.flag_outlined)
            else
              for (final quest in _quests) _buildQuestItem(quest),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestItem(Quest quest) {
    final isCompleted = quest.isCompleted;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: quest.isClaimed ? (isDark ? const Color(0xFF16222F) : const Color(0xFFF8FAF9)) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: quest.isClaimed ? Colors.green.shade100 : (isCompleted ? Colors.amber : Colors.transparent),
          width: 1.5,
        ),
        boxShadow: [
          if (!quest.isClaimed && isCompleted) BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: quest.isClaimed ? Colors.green.shade50 : Colors.blue.shade50, shape: BoxShape.circle),
            child: Icon(quest.icon, color: quest.isClaimed ? Colors.green : AppTheme.primaryColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: quest.isClaimed ? AppTheme.greyColor : null,
                    decoration: quest.isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text('+${quest.xp} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: quest.progress,
                  backgroundColor: Colors.grey.shade200,
                  color: quest.isClaimed ? Colors.green.shade200 : (isCompleted ? Colors.amber : AppTheme.primaryColor),
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
            child: quest.isClaimed
                ? const Icon(Icons.check_circle, color: Colors.green, size: 32, key: ValueKey('claimed'))
                : (isCompleted
                    ? ElevatedButton(
                        key: const ValueKey('claim_btn'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: _claimingId == null ? () => _claim(quest) : null,
                        child: _claimingId == quest.id
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(tr('Nhận'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      )
                    : Text('${quest.current}/${quest.target}',
                        key: const ValueKey('progress_text'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor, fontSize: 14))),
          ),
        ],
      ),
    );
  }
}
