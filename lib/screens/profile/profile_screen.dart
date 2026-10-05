import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/content_repository.dart';
import '../../data/game_repository.dart';
import '../../data/user_repository.dart';
import '../../models/flashcard_model.dart';
import '../../widgets/common.dart';
import 'saved_words_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Flashcard> _saved = const [];
  int _savedCount = 0;
  int? _rank;
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
        ContentRepository.bookmarks(size: 5),
        GameRepository.leaderboard('xp', limit: 1),
        AppState.I.refreshAll(),
      ]);
      if (!mounted) return;
      final saved = results[0] as PageResult<Flashcard>;
      setState(() {
        _saved = saved.items;
        _savedCount = saved.totalElements;
        _rank = (results[1] as dynamic).myRank as int?;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showEditSloganDialog() {
    final controller = TextEditingController(text: AppState.I.user?.slogan ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        var saving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(tr('Cập nhật Slogan'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: tr('Nhập câu châm ngôn của bạn...'),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: saving
                    ? null
                    : () async {
                        setDialogState(() => saving = true);
                        try {
                          await UserRepository.updateSlogan(controller.text);
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                        } catch (e) {
                          setDialogState(() => saving = false);
                          if (mounted) showAppSnack(this.context, errorMessage(e), error: true);
                        }
                      },
                child: Text(tr('Lưu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final app = AppState.I;
    final user = app.user;
    if (user == null) return const Scaffold(body: LoadingView());
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(tr('Hồ sơ cá nhân'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 100 + MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            size: 78,
                            ringWidth: 4,
                            borderColors: app.equippedBorderColors,
                            imageUrl: app.equippedAvatarUrl,
                            initials: initialsOf(user.fullName),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(user.fullName,
                                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                    if (_rank != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                                        child: Text(trf('Hạng {n}', {'n': _rank!}),
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: _showEditSloganDialog,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.slogan.isEmpty ? tr('Thêm câu châm ngôn') : user.slogan,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit, size: 14, color: AppTheme.primaryColor),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(user.level, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.stars, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${user.currentXp} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF7E6),
                            foregroundColor: Colors.orange,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          icon: const Icon(Icons.storefront),
                          label: Text(tr('Cửa hàng đổi thưởng'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                            if (mounted) _load();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      _buildStatTile(Icons.local_fire_department, Colors.orange, tr('Streak'), trf('{n} ngày', {'n': user.streakDays})),
                      const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                      _buildStatTile(Icons.menu_book, Colors.green, tr('Tổng số từ đã học'), '${user.totalWordsLearned}'),
                      const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                      _buildStatTile(Icons.task_alt, Colors.blue, tr('Số bài hoàn thành'), '${user.completedLessons}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSavedWords(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(IconData icon, Color iconColor, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  /// Danh sách từ đã lưu (xem trước 5 từ), bấm "Xem tất cả" để mở đầy đủ.
  Widget _buildSavedWords(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(trf('Từ đã lưu ({n})', {'n': _savedCount}), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (_savedCount > 0)
                TextButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedWordsScreen()));
                    if (mounted) _load();
                  },
                  child: Text(tr('Xem tất cả'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (_loading)
            const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
          else if (_saved.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(tr('Chưa có từ nào được lưu. Bấm biểu tượng dấu trang trên thẻ từ vựng để lưu.'),
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 13, height: 1.4)),
            )
          else
            for (final word in _saved)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(word.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(word.meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor, size: 22),
                      onPressed: () => SpeechService.speak(word.word),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
