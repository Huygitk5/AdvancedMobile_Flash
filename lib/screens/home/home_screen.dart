import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/clock.dart';
import '../../core/icons.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/local/converters.dart';
import '../../data/widget/home_widget_service.dart';
import '../../models/lesson_model.dart';
import '../../models/quest_model.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/add_home_widget_card.dart';
import '../../widgets/common.dart';
import '../../widgets/reminder_dialog.dart';
import '../challenge/challenge_screen.dart';
import '../flashcard/flashcard_screen.dart';
import '../grammar/grammar_detail_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart' show borderColorsOf;
import '../profile/settings_screen.dart';
import '../profile/widget_settings_screen.dart';
import '../vocabulary/topic_screen.dart';

/// Mọi số liệu đọc từ SQLite nên mở offline vẫn hiển thị đủ.
class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  static bool _handledLaunch = false; // chỉ xử lý "mở app từ widget" một lần
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    // Lần đầu trong ngày chưa có nhiệm vụ local: online thì nhờ server giao.
    ref.read(questRepositoryProvider).ensureToday();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Đọc thẳng DAO: todayStatsProvider là autoDispose, `ref.read(...future)` khi chưa ai watch sẽ bị huỷ trước khi có dữ liệu.
      final today = await ref.read(dbProvider).statsDao.watchDay(localDateKey(Clock.now())).first;
      if (!mounted) return;
      ReminderDialog.maybeShowDaily(context, ref.read(appPrefsProvider),
          studiedToday: (today?.lessonsCompleted ?? 0) + (today?.cardsReviewed ?? 0) > 0);
    });
    WidgetsBinding.instance.addObserver(this);
    if (HomeWidgetService.supported) {
      if (!_handledLaunch) {
        _handledLaunch = true;
        HomeWidget.initiallyLaunchedFromHomeWidget().then(_openFromWidget, onError: (_) {}); // app đang tắt
      }
      _widgetClicks = HomeWidget.widgetClicked.listen(_openFromWidget, onError: (_) {}); // app đang chạy nền
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetClicks?.cancel();
    super.dispose();
  }

  // Quay lại app sau một lúc → có thể đã có thêm thẻ đến hạn.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      HomeWidgetService.refresh(ref.read(dbProvider));
    }
  }

  // Đường dẫn widget gửi về: flashwidget://study?topic=<id>&title=<tên>,
  // hoặc flashwidget://settings/widget khi widget đang tắt.
  void _openFromWidget(Uri? uri) {
    if (uri == null || !mounted) return;
    if (uri.host == 'settings') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WidgetSettingsScreen()));
      return;
    }
    final topicId = uri.queryParameters['topic'];
    if (topicId == null || topicId.isEmpty) return; // chạm khi không có thẻ: chỉ mở app
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(topicId: topicId, topicTitle: uri.queryParameters['title'] ?? ''),
      ),
    );
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
            padding: EdgeInsets.fromLTRB(20, 10, 20, 100 + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gợi ý đặt widget ra màn hình chính (tự ẩn nếu không phải Android / đã bấm).
                const AddHomeWidgetCard(),
                _buildHeader(context, user),
                const SizedBox(height: 25),
                _buildProgressSection(context),
                const SizedBox(height: 25),
                _buildSectionTitle(tr('Danh mục học tập'), context),
                const SizedBox(height: 15),
                _buildCategories(context),
                const SizedBox(height: 25),
                _buildSectionTitle(tr('Bài học gợi ý cho bạn'), context),
                const SizedBox(height: 15),
                _buildSuggestedLessons(context),
                const SizedBox(height: 25),
                _buildSectionTitle(tr('Thử thách hôm nay'), context),
                const SizedBox(height: 15),
                _buildChallengeSection(context),
                const SizedBox(height: 25),
                _buildLeaderboardBanner(context),
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final name = user?.fullName ?? '';
    return Row(
      children: [
        UserAvatar(
          size: 48,
          borderColors: borderColorsOf(user?.equippedBorderColors ?? const []),
          imageUrl: user?.equippedAvatarUrl ?? user?.avatarUrl,
          initials: initialsOf(name),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Xin chào,'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Chạm vào streak: sang tab Tiến độ
        GestureDetector(
          onTap: () => widget.onSwitchTab?.call(2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                const SizedBox(width: 4),
                Text(trf('{n} ngày', {'n': user?.streakDays ?? 0}),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
              ],
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.settings_outlined, color: textColor),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final goal = ref.watch(appPrefsProvider).dailyGoalLessons;
    // Số bài KHÁC NHAU hôm nay (học lại cùng một bài chỉ tính một lần, giống server)
    final done = ref.watch(todayLessonsDoneProvider).value ?? 0;
    final ratio = goal <= 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
    final lessons = ref.watch(homeLessonsProvider).value;
    final cont = lessons?.continueLesson;
    // Chưa có bài học dở thì gợi ý bắt đầu bài đầu tiên trong danh sách gợi ý.
    final next = cont ?? ((lessons?.recommended.isNotEmpty ?? false) ? lessons!.recommended.first : null);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(tr('Tiến độ hôm nay'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => widget.onSwitchTab?.call(2),
                child: Text('${trf('{done}/{goal} bài', {'done': done, 'goal': goal})} >',
                    style: const TextStyle(color: AppTheme.greyColor, fontWeight: FontWeight.bold)),
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
            onTap: () => next != null ? _openLesson(next) : widget.onSwitchTab?.call(1),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Icon(next == null || next.isVocabulary ? Icons.menu_book_rounded : Icons.description_rounded,
                        color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cont != null ? tr('Tiếp tục học') : tr('Bắt đầu học'),
                            style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(next?.title ?? tr('Chọn một chủ đề từ vựng'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Text(
                          next == null
                              ? tr('Mở tab Học để chọn bài')
                              : next.isVocabulary
                                  ? trf('{d}/{n} từ • {m} phút', {
                                      'd': (next.progress * next.itemCount).round(),
                                      'n': next.itemCount,
                                      'm': next.estimatedMinutes,
                                    })
                                  : trf('{p}% • {m} phút', {'p': (next.progress * 100).round(), 'm': next.estimatedMinutes}),
                          style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    radius: 20,
                    child: Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hai thẻ danh mục xếp dọc (icon trên, chữ dưới) nên không bao giờ tràn ngang trên màn hình hẹp.
  Widget _buildCategories(BuildContext context) {
    final counts = ref.watch(contentCountsProvider).value;
    final grammarCount = ref.watch(grammarCountProvider).value ?? 0;
    final words = counts?.words ?? 0;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildCategoryCard(
              context,
              tr('Từ vựng'),
              words > 0 ? trf('{w} từ • {t} chủ đề', {'w': words, 't': counts?.topics ?? 0}) : tr('Chủ đề từ vựng'),
              Icons.menu_book,
              const Color(0xFFE8F5E9),
              Colors.green,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopicScreen(initialIndex: 0))),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildCategoryCard(
              context,
              tr('Ngữ pháp'),
              grammarCount > 0 ? trf('{n} chủ điểm', {'n': grammarCount}) : tr('Các chủ điểm'),
              Icons.description,
              const Color(0xFFF3E5F5),
              Colors.purple,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopicScreen(initialIndex: 1))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, Color bgColor, Color iconColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedLessons(BuildContext context) {
    final lessons = ref.watch(homeLessonsProvider).value?.recommended ?? const <Lesson>[];
    if (lessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(tr('Bạn đã bắt đầu mọi bài học. Tuyệt vời!'), style: const TextStyle(color: AppTheme.greyColor)),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: lessons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 15),
        itemBuilder: (context, i) => _buildLessonCard(context, lessons[i]),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bg = lesson.coverColor != null
        ? Color(lesson.coverColor!)
        : (lesson.isVocabulary ? Colors.blue.shade100 : Colors.purple.shade100);
    return GestureDetector(
      onTap: () => _openLesson(lesson),
      child: Container(
        width: 200,
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: bg,
                  child: Center(
                    child: Icon(lesson.isVocabulary ? Icons.menu_book_rounded : Icons.description_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 40),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(lesson.level, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: lesson.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(lesson.progress * 100).round()}%',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 14, color: AppTheme.greyColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          lesson.isVocabulary ? trf('{n} từ', {'n': lesson.itemCount}) : tr('Ngữ pháp'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.greyColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time, size: 14, color: AppTheme.greyColor),
                      const SizedBox(width: 4),
                      Text(trf('{m} phút', {'m': lesson.estimatedMinutes}), style: const TextStyle(fontSize: 12, color: AppTheme.greyColor)),
                    ],
                  ),
                ],
              ),
            ),
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
      decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.amber,
            radius: 24,
            child: Icon(quest == null ? Icons.emoji_events : iconFor(quest.iconName), color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest?.title ?? tr('Đã hoàn thành mọi thử thách'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                  quest == null
                      ? tr('Quay lại vào ngày mai nhé!')
                      : trf('Tiến độ {c}/{t} • +{xp} XP', {'c': quest.current, 't': quest.target, 'xp': quest.xp}),
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () {
              if (widget.onSwitchTab != null) {
                widget.onSwitchTab!(3);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengeScreen()));
              }
            },
            child: Text(quest != null && quest.isCompleted ? tr('Nhận') : tr('Bắt đầu'),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
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
          gradient: const LinearGradient(colors: [Color(0xFFFFB703), Color(0xFFFB8500)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Top 10 Vinh Danh'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(tr('Xem vị trí của bạn trên bảng xếp hạng'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
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
    return Text(title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color));
  }
}
