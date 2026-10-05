import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/remote/api_exception.dart';
import '../../data/repositories/user_repositories.dart';
import '../../models/reward_item_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/app_snack.dart';

/// Danh mục + kho đồ đọc từ SQLite (xem được offline). Mua chỉ online; trang bị đi qua ITEM_EQUIP.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final Set<String> _buying = {};

  Future<void> _unlockItem(RewardItem item, RewardItem? online) async {
    if (online?.meetsRankRequirement == false) {
      showSnack(context, 'Cần đạt Top ${item.requiredRank} Bảng xếp hạng ${item.rankBoard == 'STREAK' ? 'Streak' : 'XP'}!', color: Colors.red);
      return;
    }
    if (online?.canAfford == false) {
      showSnack(context, 'Không đủ XP!', color: Colors.red);
      return;
    }
    setState(() => _buying.add(item.id));
    try {
      final state = await ref.read(shopRepositoryProvider).purchase(item);
      if (!mounted) return;
      if (state == PurchaseState.done) {
        showSnack(context, 'Đã mua: ${item.name}!', color: Colors.green);
      } else {
        showSnack(context, 'Đang xử lý giao dịch, sẽ hoàn tất khi có mạng trở lại.');
      }
      ref.invalidate(shopOnlineStatusProvider);
    } on NetworkException {
      if (mounted) showSnack(context, 'Cần kết nối mạng để mua.', color: Colors.red);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _buying.remove(item.id));
    }
  }

  void _equipItem(RewardItem item) => ref.read(shopRepositoryProvider).setEquipped(item, true);

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shopItemsProvider);
    final onlineAsync = ref.watch(shopOnlineStatusProvider);
    final online = onlineAsync.value;
    final offline = !onlineAsync.isLoading && online == null;
    final xp = ref.watch(profileProvider).value?.displayXp ?? 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cửa hàng XP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('$xp', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text('Đang offline: cần kết nối mạng để mua. Bạn vẫn có thể trang bị đồ đã sở hữu.',
                  style: TextStyle(color: Colors.orange, fontSize: 13)),
            ),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Không đọc được cửa hàng: $e')),
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Cửa hàng chưa có vật phẩm.', style: TextStyle(color: AppTheme.greyColor)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                      itemCount: list.length,
                      itemBuilder: (context, index) => _buildItem(list[index], online?[list[index].id], offline),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(RewardItem item, RewardItem? online, bool offline) {
    final colors = item.borderColors.map((hex) => Color(hex)).toList();
    final gradientColors = colors.isEmpty
        ? const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)]
        : (colors.length == 1 ? [colors.first, colors.first] : colors);
    final hasImage = item.isAvatar && (item.imageUrl ?? '').isNotEmpty;
    final locked = item.requiredRank > 0 && online?.meetsRankRequirement != true;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFEEF2FF),
                backgroundImage: hasImage ? NetworkImage(item.imageUrl!) : null,
                child: hasImage ? null : Icon(item.isBorder ? Icons.lens_outlined : Icons.person, size: 35, color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 15),

          if (item.isEquipped)
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text('Đang dùng', style: TextStyle(fontSize: 12)),
            )
          else if (item.isUnlocked)
            ElevatedButton(
              onPressed: () => _equipItem(item),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: Text('Sử dụng', style: TextStyle(fontSize: 12, color: Theme.of(context).cardColor)),
            )
          else if (_buying.contains(item.id))
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
          else
            ElevatedButton.icon(
              onPressed: offline ? null : () => _unlockItem(item, online),
              icon: Icon(locked ? Icons.lock : Icons.stars, size: 14, color: Theme.of(context).cardColor),
              label: Text(item.requiredRank > 0 ? 'Top ${item.requiredRank} + ${item.xpCost}' : '${item.xpCost}', style: TextStyle(fontSize: 12, color: Theme.of(context).cardColor)),
              style: ElevatedButton.styleFrom(backgroundColor: locked ? Colors.grey.shade400 : Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            ),
        ],
      ),
    );
  }
}
