import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/lesson_navigation.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/content_repository.dart';
import '../../data/progress_repository.dart';
import '../../models/lesson_model.dart';
import '../../widgets/common.dart';
import '../challenge/challenge_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/settings_screen.dart';
import '../vocabulary/topic_screen.dart';

class _HomeData {
  final HomeSummary summary;
  final int totalWords;
  final int topicCount;
  final int grammarCount;

  const _HomeData(this.summary, this.totalWords, this.topicCount, this.grammarCount);
}

class HomeScreen extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeData? _data;
  String? _error;
  bool _loading = true;

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
      final results = await Future.wait([
        ProgressRepository.home(),
        ContentRepository.topics(size: 100),
        ContentRepository.grammarLessons(size: 1),
        AppState.I.refreshAll(),
      ]);
      final summary = results[0] as HomeSummary;
      final topics = results[1] as PageResult;
      final grammar = results[2] as PageResult;
      final words = topics.items.fold<int>(0, (sum, t) => sum + (t.totalWords as int));
      if (!mounted) return;
      setState(() {
        _data = _HomeData(summary, words, topics.totalElements, grammar.totalElements);
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 100 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 22),
                if (_loading && _data == null)
                  const Padding(padding: EdgeInsets.only(top: 80), child: LoadingView())
                else if (_data == null)
                  Padding(padding: const EdgeInsets.only(top: 60), child: ErrorView(message: _error ?? '', onRetry: _load))
                else ...[
                  _buildProgressSection(context, _data!.summary),
                  const SizedBox(height: 25),
                  _buildSectionTitle(tr('Danh mục học tập'), context),
                  const SizedBox(height: 15),
                  _buildCategories(context, _data!),
                  if (_data!.summary.recommended.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    _buildSectionTitle(tr('Bài học gợi ý cho bạn'), context),
                    const SizedBox(height: 15),
                    _buildSuggestedLessons(context, _data!.summary.recommended),
                  ],
                  const SizedBox(height: 25),
                  _buildSectionTitle(tr('Thử thách hôm nay'), context),
                  const SizedBox(height: 15),
                  _buildChallengeSection(context, _data!.summary),
                  const SizedBox(height: 25),
                  _buildLeaderboardBanner(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final app = AppState.I;
    final user = app.user;
    final name = user?.fullName ?? '';
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Row(
      children: [
        UserAvatar(
          size: 48,
          borderColors: app.equippedBorderColors,
          imageUrl: app.equippedAvatarUrl,
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
        _buildStreakChip(user?.streakDays ?? 0),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.settings_outlined, color: textColor),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
    );
  }

  Widget _buildStreakChip(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
          const SizedBox(width: 4),
          Text(trf('{n} ngày', {'n': days}), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, HomeSummary summary) {
    final goal = summary.todayGoal <= 0 ? 1 : summary.todayGoal;
    final ratio = (summary.todayDone / goal).clamp(0.0, 1.0);
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final next = summary.continueLesson ?? (summary.recommended.isNotEmpty ? summary.recommended.first : null);
    final isContinue = summary.continueLesson != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(tr('Tiến độ hôm nay'),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              ),
              const SizedBox(width: 8),
              Text(trf('{done}/{goal} bài', {'done': summary.todayDone, 'goal': summary.todayGoal}),
                  style: const TextStyle(color: AppTheme.greyColor, fontWeight: FontWeight.bold)),
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
          if (next != null) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => openLesson(context, next),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                      child: Icon(next.isVocabulary ? Icons.menu_book_rounded : Icons.description_rounded, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isContinue ? tr('Tiếp tục học') : tr('Bắt đầu học'),
                              style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(next.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text(
                            trf('{p}% • {m} phút', {'p': (next.progress * 100).round(), 'm': next.estimatedMinutes}),
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
        ],
      ),
    );
  }

  /// Hai thẻ danh mục xếp dọc (icon trên, chữ dưới) nên không bao giờ tràn ngang trên màn hình hẹp.
  Widget _buildCategories(BuildContext context, _HomeData data) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildCategoryCard(
              context,
              tr('Từ vựng'),
              trf('{w} từ • {t} chủ đề', {'w': data.totalWords, 't': data.topicCount}),
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
              trf('{n} chủ điểm', {'n': data.grammarCount}),
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
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
            const SizedBox(height: 2),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedLessons(BuildContext context, List<Lesson> lessons) {
    return SizedBox(
      height: 215,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lessons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 15),
        itemBuilder: (context, i) => _buildLessonCard(context, lessons[i]),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bg = lesson.coverColor ?? (lesson.isVocabulary ? Colors.blue.shade100 : Colors.purple.shade100);
    return GestureDetector(
      onTap: () => openLesson(context, lesson),
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
                  height: 90,
                  width: double.infinity,
                  color: bg.withValues(alpha: bg.a == 1 ? 1 : 0.6),
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
                          lesson.isVocabulary ? trf('{n} từ', {'n': lesson.itemCount}) : trf('{n} ví dụ', {'n': lesson.itemCount}),
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

  Widget _buildChallengeSection(BuildContext context, HomeSummary summary) {
    final quest = summary.todayChallenge;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF0F5FF), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.amber, radius: 24, child: Icon(Icons.emoji_events, color: Colors.white, size: 28)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest?.title ?? tr('Hoàn thành bài kiểm tra'),
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                  quest != null ? '${quest.current}/${quest.target} • +${quest.xp} XP' : tr('Kiểm tra kiến thức sau bài học'),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengeScreen()));
              }
            },
            child: Text(tr('Bắt đầu'), style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
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
