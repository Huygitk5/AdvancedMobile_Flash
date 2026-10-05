import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/reward_item_model.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

/// Kho đồ của user (chỉ món đã sở hữu), đọc từ SQLite.
final _inventoryProvider = StreamProvider.autoDispose<List<RewardItem>>(
  (ref) => ref.watch(dbProvider).shopDao.watchInventoryWithItems(),
);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditNoteDialog(UserModel user) {
    final noteController = TextEditingController(text: user.slogan);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cập nhật Slogan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: noteController,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: 'Nhập câu châm ngôn của bạn...',
            filled: true,
            fillColor: const Color(0xFFF4F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              Navigator.pop(dialogContext);
              // Ghi user_profile (is_dirty) + PROFILE_UPDATE {slogan, baseVersion, clientUpdatedAt}.
              ref.read(profileRepositoryProvider).updateSlogan(noteController.text.trim());
            },
            child: Text('Lưu', style: TextStyle(color: Theme.of(dialogContext).cardColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final equippedBorderColors = user.equippedBorderColors.isEmpty
        ? const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)]
        : (user.equippedBorderColors.length == 1
            ? [Color(user.equippedBorderColors.first), Color(user.equippedBorderColors.first)]
            : user.equippedBorderColors.map((c) => Color(c)).toList());
    final avatarUrl = user.equippedAvatarUrl ?? user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final rank = ref.watch(leaderboardProvider('XP')).value?.me?.rank;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text('Hồ sơ cá nhân', style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          )
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: equippedBorderColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFFEEF2FF),
                            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                            child: hasAvatar ? null : const Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Lấy Tên từ UserModel
                                  Expanded(
                                    child: Text(user.fullName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  if (rank != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                                      child: Text(rank <= 10 ? 'Top $rank Point' : 'Hạng #$rank', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Lấy Email từ UserModel
                              Text(user.email, style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => _showEditNoteDialog(user),
                                child: Row(
                                  children: [
                                    Expanded(
                                      // Lấy Slogan từ UserModel
                                      child: Text(user.slogan, style: TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    Icon(Icons.edit, size: 14, color: AppTheme.primaryColor),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Lấy Level
                                  Text(user.level, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
                                  Icon(Icons.stars, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  // Lấy XP hiện tại để mua sắm
                                  Text('${user.displayXp} XP', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF7E6), foregroundColor: Colors.orange, elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        icon: Icon(Icons.storefront),
                        label: Text('Cửa hàng đổi thưởng', style: TextStyle(fontWeight: FontWeight.bold)),
                        // Profile watch SQLite nên tự cập nhật XP / viền mới khi quay về.
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen())),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    // Cập nhật động dữ liệu thống kê từ UserModel
                    _buildStatTile(Icons.local_fire_department, Colors.orange, 'Streak', '${user.streakDays} ngày'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.menu_book, Colors.green, 'Tổng số từ đã học', '${user.totalWordsLearned}'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.task_alt, Colors.blue, 'Số bài hoàn thành', '${user.completedLessons}'),
                    const Divider(height: 1, indent: 50, endIndent: 20, color: Color(0xFFF4F6FA)),
                    _buildStatTile(Icons.emoji_events_outlined, Colors.amber, 'Tổng XP tích luỹ', '${user.totalLifetimeXp}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInventory(),
              SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
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
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kho đồ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final item = items[i];
                final colors = item.borderColors.map((c) => Color(c)).toList();
                final grad = colors.isEmpty
                    ? const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)]
                    : (colors.length == 1 ? [colors.first, colors.first] : colors);
                final img = item.isAvatar && (item.imageUrl ?? '').isNotEmpty;
                return GestureDetector(
                  onTap: item.isEquipped ? null : () => ref.read(shopRepositoryProvider).setEquipped(item, true),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: grad)),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEEF2FF),
                        backgroundImage: img ? NetworkImage(item.imageUrl!) : null,
                        child: img ? null : Icon(item.isBorder ? Icons.lens_outlined : Icons.person, color: AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(item.isEquipped ? 'Đang dùng' : item.name,
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

  Widget _buildStatTile(IconData icon, Color iconColor, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(fontSize: 15, )),
      trailing: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, )),
    );
  }
}
