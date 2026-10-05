import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import để dùng hiệu ứng rung (Haptic Feedback)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/theme.dart';
import '../../models/quest_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';

class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  @override
  void initState() {
    super.initState();
    // Lần đầu trong ngày chưa có nhiệm vụ local: online thì gọi /v1/quests/today rồi pull.
    ref.read(questRepositoryProvider).ensureToday();
  }

  /// Nhận thưởng: ghi lạc quan + QUEST_CLAIM. Server từ chối thì nút quay lại "Nhận" và có snackbar.
  Future<void> _claimReward(Quest quest) async {
    if (ref.read(appPrefsProvider).isVibrationEnabled) HapticFeedback.mediumImpact();
    await ref.read(questRepositoryProvider).claim(quest);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Tuyệt vời! Bạn nhận được +${quest.xp} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalXp = ref.watch(profileProvider).value?.displayXp ?? 0;
    final questsAsync = ref.watch(questsProvider);
    final quests = questsAsync.value ?? const <Quest>[];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Thử thách', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        children: [
          // Thẻ tổng quan XP
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3366FF), Color(0xFF5A85FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Icon(Icons.stars, color: Colors.amber, size: 40),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng điểm XP', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '$totalXp',
                          key: ValueKey<int>(totalXp),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          Text('Nhiệm vụ hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, )),
          const SizedBox(height: 15),

          if (quests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: questsAsync.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Chưa có nhiệm vụ. Kết nối mạng để nhận nhiệm vụ hôm nay.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppTheme.greyColor)),
              ),
            ),
          ...quests.map(_buildQuestItem),
        ],
      ),
    );
  }

  // Widget nhận tham số là 1 object Model Quest thay vì các biến rời rạc
  Widget _buildQuestItem(Quest quest) {
    final isCompleted = quest.isCompleted;
    final progress = quest.progress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: quest.isClaimed ? const Color(0xFFF8FAF9) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: quest.isClaimed ? Colors.green.shade100 : (isCompleted ? Colors.amber : Colors.transparent),
              width: 1.5
          ),
          boxShadow: [
            if (!quest.isClaimed && isCompleted)
              BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 2)
          ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: quest.isClaimed ? Colors.green.shade50 : Colors.blue.shade50,
                shape: BoxShape.circle
            ),
            child: Icon(iconFor(quest.iconName), color: quest.isClaimed ? Colors.green : AppTheme.primaryColor),
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
                      color: quest.isClaimed ? AppTheme.greyColor : const Color(0xFF1E293B),
                      decoration: quest.isClaimed ? TextDecoration.lineThrough : null, // Gạch ngang chữ khi đã nhận
                    )
                ),
                const SizedBox(height: 5),
                Text('+${quest.xp} XP', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: quest.isClaimed ? Colors.green.shade200 : (isCompleted ? Colors.amber : AppTheme.primaryColor),
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),

          // Khu vực nút bấm hoặc trạng thái
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
            child: quest.isClaimed
                ? Icon(Icons.check_circle, color: Colors.green, size: 32, key: ValueKey('claimed'))
                : (isCompleted
                ? ElevatedButton(
              key: const ValueKey('claim_btn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Theme.of(context).cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => _claimReward(quest),
              child: Text('Nhận', style: TextStyle(fontWeight: FontWeight.bold)),
            )
                : Text(
                '${quest.current}/${quest.target}',
                key: const ValueKey('progress_text'),
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor, fontSize: 14)
            )
            ),
          ),
        ],
      ),
    );
  }
}