import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/remote/api_exception.dart';
import '../../data/repositories/user_repositories.dart';
import '../../models/reward_item_model.dart';
import '../../providers/providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common.dart';
import 'profile_screen.dart' show borderColorsOf;

/// Danh mục + kho đồ đọc từ SQLite (xem được offline). Mua chỉ online; trang bị / bỏ trang bị đi qua ITEM_EQUIP.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final Set<String> _buying = {};

  Future<void> _unlockItem(RewardItem item, RewardItem? online) async {
    if (online?.meetsRankRequirement == false) {
      showAppSnack(
          context,
          trf('Cần đạt Top {n} Bảng xếp hạng {board}!',
              {'n': item.requiredRank, 'board': item.rankBoard == 'STREAK' ? 'Streak' : 'XP'}),
          error: true);
      return;
    }
    if (online?.canAfford == false) {
      showAppSnack(context, tr('Không đủ XP!'), error: true);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Xác nhận mua'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(trf('Mua "{name}" với {xp} XP?', {'name': item.name, 'xp': item.xpCost})),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('Mua'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _buying.add(item.id));
    try {
      final state = await ref.read(shopRepositoryProvider).purchase(item);
      if (!mounted) return;
      if (state == PurchaseState.done) {
        showAppSnack(context, trf('Đã mua: {name}!', {'name': item.name}), icon: Icons.check_circle);
      } else {
        showAppSnack(context, tr('Đang xử lý giao dịch, sẽ hoàn tất khi có mạng trở lại.'));
      }
      ref.invalidate(shopOnlineStatusProvider);
    } on NetworkException {
      if (mounted) showAppSnack(context, tr('Cần kết nối mạng để mua.'), error: true);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _buying.remove(item.id));
    }
  }

  Future<void> _setEquipped(RewardItem item, bool equipped) async {
    await ref.read(shopRepositoryProvider).setEquipped(item, equipped);
    if (mounted) showAppSnack(context, equipped ? tr('Đã trang bị') : tr('Đã bỏ trang bị'), icon: Icons.check_circle);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shopItemsProvider);
    final onlineAsync = ref.watch(shopOnlineStatusProvider);
    final online = onlineAsync.value;
    final offline = !onlineAsync.isLoading && online == null;
    final user = ref.watch(profileProvider).value;
    final xp = user?.displayXp ?? 0;
    final equippedBorder = borderColorsOf(user?.equippedBorderColors ?? const []);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Cửa hàng XP'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(tr('Đang offline: cần kết nối mạng để mua. Bạn vẫn có thể trang bị đồ đã sở hữu.'),
                  style: const TextStyle(color: Colors.orange, fontSize: 13)),
            ),
          Expanded(
            child: items.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(message: trf('Không đọc được cửa hàng: {e}', {'e': e})),
              data: (list) => list.isEmpty
                  ? EmptyView(message: tr('Cửa hàng chưa có vật phẩm'), icon: Icons.storefront_outlined)
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(shopOnlineStatusProvider);
                        await ref.read(syncWorkerProvider).syncNow();
                      },
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, mainAxisExtent: 215),
                        itemCount: list.length,
                        itemBuilder: (context, index) =>
                            _buildItem(list[index], online?[list[index].id], offline, equippedBorder),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(RewardItem item, RewardItem? online, bool offline, List<Color> equippedBorder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Viền: xem trước chính viền đó; avatar: xem trước trong viền đang trang bị
          UserAvatar(
            size: 76,
            ringWidth: 4,
            borderColors: item.isBorder ? borderColorsOf(item.borderColors) : equippedBorder,
            imageUrl: item.isAvatar ? item.imageUrl : null,
          ),
          const SizedBox(height: 10),
          Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: _actionButton(item, online, offline)),
        ],
      ),
    );
  }

  Widget _actionButton(RewardItem item, RewardItem? online, bool offline) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
    if (item.isEquipped) {
      return OutlinedButton(
        onPressed: item.inventoryId == null ? null : () => _setEquipped(item, false),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green), shape: shape),
        child: Text(tr('Đang dùng'), style: const TextStyle(fontSize: 12)),
      );
    }
    if (item.isUnlocked) {
      return ElevatedButton(
        onPressed: item.inventoryId == null ? null : () => _setEquipped(item, true),
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: shape),
        child: Text(tr('Sử dụng'), style: const TextStyle(fontSize: 12, color: Colors.white)),
      );
    }
    if (_buying.contains(item.id)) {
      return const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)));
    }
    final locked = item.requiredRank > 0 && online?.meetsRankRequirement != true;
    final canAfford = online?.canAfford ?? true;
    return ElevatedButton.icon(
      onPressed: offline ? null : () => _unlockItem(item, online),
      icon: Icon(locked ? Icons.lock : Icons.stars, size: 14, color: Colors.white),
      label: Text(item.requiredRank > 0 ? 'Top ${item.requiredRank} + ${item.xpCost}' : '${item.xpCost}',
          maxLines: 1, style: const TextStyle(fontSize: 12, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: locked ? Colors.grey.shade400 : (canAfford ? Colors.amber : Colors.amber.shade200),
        shape: shape,
      ),
    );
  }
}
