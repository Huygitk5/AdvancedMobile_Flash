import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/speech.dart';
import '../../core/theme.dart';
import '../../models/flashcard_model.dart';
import '../../models/reward_item_model.dart';
import '../../models/user_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common.dart';
import 'saved_words_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

/// Kho đồ của user (chỉ món đã sở hữu), đọc từ SQLite.
final _inventoryProvider = StreamProvider.autoDispose<List<RewardItem>>(
  (ref) => ref.watch(dbProvider).shopDao.watchInventoryWithItems(),
);

/// Viền mặc định của "Tân binh" khi chưa trang bị viền nào.
const defaultBorderColors = [Color(0xFFE2E8F0), Color(0xFFCBD5E1)];

/// ARGB -> Color, rỗng thì dùng viền mặc định.
List<Color> borderColorsOf(List<int> argb) =>
    argb.isEmpty ? defaultBorderColors : argb.map((c) => Color(c)).toList();

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditSloganDialog(UserModel user) {
    final controller = TextEditingController(text: user.slogan);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Cập nhật Slogan'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: tr('Nhập câu châm ngôn của bạn...'),
            filled: true,
            fillColor: Theme.of(dialogContext).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              Navigator.pop(dialogContext);
              // Ghi user_profile (is_dirty) + PROFILE_UPDATE {slogan, baseVersion, clientUpdatedAt};
              // xung đột phiên bản do SyncWorker xử lý.
              ref.read(profileRepositoryProvider).updateSlogan(controller.text.trim());
            },
            child: Text(tr('Lưu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider).value;
    if (user == null) return const Scaffold(body: LoadingView());
    final rank = ref.watch(leaderboardProvider('XP')).value?.me?.rank;
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
          onRefresh: () async {
            ref.invalidate(leaderboardProvider('XP'));
            await ref.read(syncWorkerProvider).syncNow();
          },
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
                            borderColors: borderColorsOf(user.equippedBorderColors),
                            imageUrl: user.equippedAvatarUrl ?? user.avatarUrl,
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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                    if (rank != null) ...[
                                      const SizedBox(width: 8),
                                      // Flexible + ellipsis: badge co lại trên màn hẹp / cỡ chữ lớn thay vì tràn
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                                          child: Text(
                                            rank <= 10 ? trf('Top {n} Point', {'n': rank}) : trf('Hạng #{n}', {'n': rank}),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(user.email,
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _showEditSloganDialog(user),
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
                                    Text(user.level,
                                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
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
                                            // XP để mua sắm = số server xác nhận + phần chờ đồng bộ
                                            Text('${user.displayXp} XP',
                                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
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
                          // Profile watch SQLite nên tự cập nhật XP / viền mới khi quay về.
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
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
                      _divider(),
                      _buildStatTile(Icons.menu_book, Colors.green, tr('Tổng số từ đã học'), '${user.totalWordsLearned}'),
                      _divider(),
                      _buildStatTile(Icons.task_alt, Colors.blue, tr('Số bài hoàn thành'), '${user.completedLessons}'),
                      _divider(),
                      _buildStatTile(Icons.emoji_events_outlined, Colors.amber, tr('Tổng XP tích luỹ'), '${user.totalLifetimeXp}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSavedWords(context),
                const SizedBox(height: 20),
                _buildInventory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 50, endIndent: 20, color: Theme.of(context).scaffoldBackgroundColor);

  Widget _buildStatTile(IconData icon, Color iconColor, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  /// Danh sách từ đã lưu (xem trước 5 từ), bấm "Xem tất cả" để mở đầy đủ.
  Widget _buildSavedWords(BuildContext context) {
    final savedAsync = ref.watch(bookmarkedCardsProvider);
    final saved = savedAsync.value ?? const <Flashcard>[];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                child: Text(trf('Từ đã lưu ({n})', {'n': saved.length}),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (saved.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedWordsScreen())),
                  child: Text(tr('Xem tất cả'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (savedAsync.isLoading && saved.isEmpty)
            const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
          else if (saved.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(tr('Chưa có từ nào được lưu. Bấm biểu tượng dấu trang trên thẻ từ vựng để lưu.'),
                  style: const TextStyle(color: AppTheme.greyColor, fontSize: 13, height: 1.4)),
            )
          else
            for (final word in saved.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(word.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(word.meaning,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
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

  /// Kho đồ: chạm để trang bị (ITEM_EQUIP), giống Shop.
  Widget _buildInventory() {
    final items = ref.watch(_inventoryProvider).value ?? const <RewardItem>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('Kho đồ'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final item = items[i];
                return GestureDetector(
                  onTap: item.isEquipped ? null : () => ref.read(shopRepositoryProvider).setEquipped(item, true),
                  child: Column(children: [
                    UserAvatar(
                      size: 54,
                      ringWidth: 3,
                      borderColors: borderColorsOf(item.borderColors),
                      imageUrl: item.isAvatar ? item.imageUrl : null,
                    ),
                    const SizedBox(height: 6),
                    Text(item.isEquipped ? tr('Đang dùng') : item.name,
                        style: TextStyle(fontSize: 11, color: item.isEquipped ? Colors.green : AppTheme.greyColor, fontWeight: FontWeight.bold)),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
