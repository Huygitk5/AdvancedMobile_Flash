import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/theme.dart';
import '../../models/lesson_model.dart';
import '../../models/quest_model.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/reminder_dialog.dart';
import '../challenge/challenge_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/settings_screen.dart';
import '../vocabulary/topic_screen.dart';

/// Mọi số liệu đọc từ SQLite nên mở offline vẫn hiển thị đủ.
class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Lần đầu trong ngày chưa có nhiệm vụ local: online thì nhờ server giao.
    ref.read(questRepositoryProvider).ensureToday();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final today = await ref.read(todayStatsProvider.future);
      if (!mounted) return;
      ReminderDialog.maybeShowDaily(context, ref.read(appPrefsProvider),
          studiedToday: (today?.lessonsCompleted ?? 0) + (today?.cardsReviewed ?? 0) > 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider).value;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(syncWorkerProvider).syncNow(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10 + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 25),
                _buildProgressSection(context),
                const SizedBox(height: 25),
                _buildSectionTitle('Danh mục học tập', context),
                const SizedBox(height: 15),
                _buildCategories(context),
                const SizedBox(height: 25),
                _buildSectionTitle('Bài học gợi ý cho bạn', context),
                const SizedBox(height: 15),
                _buildSuggestedLessons(context),
                const SizedBox(height: 25),
                _buildSectionTitle('Thử thách hôm nay', context),
                const SizedBox(height: 15),
                _buildChallengeSection(context),
                const SizedBox(height: 25),
                _buildLeaderboardBanner(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLesson(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => lesson.isVocabulary
            ? FlashcardScreen(topicId: lesson.refId, topicTitle: lesson.title)
            : GrammarDetailScreen(grammarId: lesson.refId, title: lesson.title),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    final gradientColors = (user?.equippedBorderColors.isNotEmpty ?? false)
        ? user!.equippedBorderColors.map((c) => Color(c)).toList()
        : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)];
    final avatarUrl = user?.equippedAvatarUrl ?? user?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: gradientColors.length == 1 ? [gradientColors.first, gradientColors.first] : gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                  child: hasAvatar ? null : const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin chào,', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                  Text('${user?.fullName ?? ''} 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ),
            IconButton(
              icon: Badge(smallSize: 8, backgroundColor: Colors.red, child: Icon(Icons.notifications_none, color: Theme.of(context).textTheme.bodyLarge?.color)),
              onPressed: () => ReminderDialog.show(context, ref.read(appPrefsProvider), onStart: () => widget.onSwitchTab?.call(1)),
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: Text('Hôm nay là một ngày tuyệt vời để học tiếng Anh!', style: TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4))),
            GestureDetector(
              onTap: () => widget.onSwitchTab?.call(2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user?.streakDays ?? 0} ngày', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
                        const Text('Streak học tập', style: TextStyle(color: Colors.orange, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.orange, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final goal = ref.watch(appPrefsProvider).dailyGoalLessons;
    final done = ref.watch(todayStatsProvider).value?.lessonsCompleted ?? 0;
    final ratio = goal <= 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
    final cont = ref.watch(homeLessonsProvider).value?.continueLesson;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiến độ hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              GestureDetector(
                onTap: () => widget.onSwitchTab?.call(2),
                child: Text('$done/$goal bài >', style: const TextStyle(color: AppTheme.greyColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primaryColor,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 15),
              Text('${(ratio * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyColor)),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => cont != null ? _openLesson(cont) : widget.onSwitchTab?.call(1),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cont != null ? 'Tiếp tục học' : 'Bắt đầu học', style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(cont?.title ?? 'Chọn một chủ đề từ vựng',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Text(
                          cont != null
                              ? '${(cont.progress * cont.itemCount).round()}/${cont.itemCount} từ • ${cont.estimatedMinutes} phút'
                              : 'Mở tab Học để chọn bài',
                          style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    radius: 20,
                    child: Icon(Icons.play_arrow, color: Theme.of(context).cardColor),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final words = ref.watch(contentCountsProvider).value?.words ?? 0;
    return Row(
      children: [
        Expanded(
          child: _buildCategoryCard(
            context, 'Từ vựng', words > 0 ? '$words từ' : 'Chủ đề từ vựng', Icons.menu_book, const Color(0xFFE8F5E9), Colors.green,
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TopicScreen(initialIndex: 0))),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildCategoryCard(
            context, 'Ngữ pháp', 'Các chủ điểm', Icons.description, const Color(0xFFF3E5F5), Colors.purple,
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TopicScreen(initialIndex: 1))),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Theme.of(context).cardColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedLessons(BuildContext context) {
    final lessons = ref.watch(homeLessonsProvider).value?.recommended ?? const <Lesson>[];
    if (lessons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text('Bạn đã bắt đầu mọi bài học. Tuyệt vời!', style: TextStyle(color: AppTheme.greyColor)),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: lessons.map((lesson) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: _buildLessonCard(
              context,
              lesson.title,
              lesson.level,
              lesson.progress,
              lesson.isVocabulary ? '${lesson.itemCount} từ' : 'Ngữ pháp',
              '${lesson.estimatedMinutes} phút',
              lesson.coverColor != null
                  ? Color(lesson.coverColor!)
                  : (lesson.isVocabulary ? Colors.blue.shade100 : Colors.purple.shade100),
              () => _openLesson(lesson),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, String title, String level, double progress, String data1, String data2, Color imageBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: imageBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(child: Icon(Icons.image, color: Theme.of(context).cardColor.withValues(alpha: 0.54), size: 40)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(level, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 14, color: AppTheme.greyColor),
                      const SizedBox(width: 4),
                      Text(data1, style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: AppTheme.greyColor),
                      const SizedBox(width: 4),
                      Text(data2, style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeSection(BuildContext context) {
    final quests = ref.watch(questsProvider).value ?? const <Quest>[];
    final quest = quests.where((q) => !q.isClaimed).firstOrNull;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.amber,
            radius: 24,
            child: Icon(quest == null ? Icons.emoji_events : iconFor(quest.iconName), color: Theme.of(context).cardColor, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest?.title ?? 'Đã hoàn thành mọi thử thách',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                  quest == null ? 'Quay lại vào ngày mai nhé!' : 'Tiến độ ${quest.current}/${quest.target} • +${quest.xp} XP',
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              if (widget.onSwitchTab != null) {
                widget.onSwitchTab!(3);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengeScreen()));
              }
            },
            child: Text(quest != null && quest.isCompleted ? 'Nhận' : 'Bắt đầu', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildLeaderboardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, color: Theme.of(context).cardColor, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top 10 Vinh Danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Xem vị trí của bạn trên bảng xếp hạng', style: TextStyle(color: Theme.of(context).cardColor.withValues(alpha: 0.9), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)
    );
  }
}
