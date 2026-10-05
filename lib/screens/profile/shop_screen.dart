import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/game_repository.dart';
import '../../models/reward_item_model.dart';
import '../../widgets/common.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ShopItem> _items = const [];
  bool _loading = true;
  String? _error;
  String? _busyId;

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
      final results = await Future.wait([GameRepository.shopItems(), AppState.I.refreshAll()]);
      if (!mounted) return;
      setState(() {
        _items = results[0] as List<ShopItem>;
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

  Future<void> _run(ShopItem item, Future<void> Function() action, String successMessage) async {
    if (_busyId != null) return;
    setState(() => _busyId = item.item.id);
    try {
      await action();
      await _load();
      if (mounted) showAppSnack(context, successMessage, icon: Icons.check_circle);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
    if (mounted) setState(() => _busyId = null);
  }

  Future<void> _purchase(ShopItem item) async {
    if (!item.meetsRank) {
      showAppSnack(context, trf('Cần đạt Top {n} Bảng xếp hạng!', {'n': item.item.requiredRank}), error: true);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Xác nhận mua'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(trf('Mua "{name}" với {xp} XP?', {'name': item.item.name, 'xp': item.item.xpCost})),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('Mua'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(item, () => GameRepository.purchase(item.item), trf('Đã mua: {name}!', {'name': item.item.name}));
  }

  @override
  Widget build(BuildContext context) {
    final xp = AppState.I.user?.currentXp ?? 0;
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
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? EmptyView(message: tr('Cửa hàng chưa có vật phẩm'), icon: Icons.storefront_outlined)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, mainAxisExtent: 215),
                        itemCount: _items.length,
                        itemBuilder: (context, index) => _buildItem(context, _items[index]),
                      ),
                    ),
    );
  }

  Widget _buildItem(BuildContext context, ShopItem shop) {
    final item = shop.item;
    final busy = _busyId == item.id;
    final colors = item.isBorder
        ? item.colors
        : (AppState.I.equippedBorderColors);
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
          UserAvatar(
            size: 76,
            ringWidth: 4,
            borderColors: colors,
            imageUrl: item.isAvatar ? item.imageUrl : null,
            initials: '',
          ),
          const SizedBox(height: 10),
          Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: _actionButton(context, shop, busy)),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, ShopItem shop, bool busy) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
    final spinner = const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
    if (shop.isEquipped) {
      return OutlinedButton(
        onPressed: busy || shop.inventoryId == null
            ? null
            : () => _run(shop, () => GameRepository.unequip(shop.inventoryId!), tr('Đã bỏ trang bị')),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green), shape: shape),
        child: busy ? spinner : Text(tr('Đang dùng'), style: const TextStyle(fontSize: 12)),
      );
    }
    if (shop.isUnlocked) {
      return ElevatedButton(
        onPressed: busy || shop.inventoryId == null
            ? null
            : () => _run(shop, () => GameRepository.equip(shop.inventoryId!), tr('Đã trang bị')),
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: shape),
        child: busy ? spinner : Text(tr('Sử dụng'), style: const TextStyle(fontSize: 12, color: Colors.white)),
      );
    }
    final ranked = shop.item.requiredRank > 0;
    return ElevatedButton.icon(
      onPressed: busy ? null : () => _purchase(shop),
      icon: Icon(!shop.meetsRank ? Icons.lock : Icons.stars, size: 14, color: Colors.white),
      label: busy
          ? spinner
          : Text(ranked ? 'Top ${shop.item.requiredRank} + ${shop.item.xpCost}' : '${shop.item.xpCost}',
              maxLines: 1, style: const TextStyle(fontSize: 12, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: !shop.meetsRank ? Colors.grey.shade400 : (shop.canAfford ? Colors.amber : Colors.amber.shade200),
        shape: shape,
      ),
    );
  }
}
