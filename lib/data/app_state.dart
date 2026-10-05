import 'package:flutter/material.dart';
import '../models/reward_item_model.dart';
import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/api_exception.dart';
import 'api/session_store.dart';

/// Trạng thái dùng chung cho cả app: người dùng đang đăng nhập và đồ đang trang bị.
/// Mọi con số XP / streak / từ đã học đều đến từ server (UserSnapshot), nên chỉ có một nguồn sự thật.
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState I = AppState._();

  UserModel? _user;
  List<InventoryItem> _inventory = const [];

  UserModel? get user => _user;
  UserModel get me => _user!;
  bool get isSignedIn => _user != null;
  List<InventoryItem> get inventory => _inventory;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Ghi đè các con số của user bằng UserSnapshot server trả kèm sau thao tác ghi.
  void applySnapshot(dynamic snapshot) {
    if (_user == null || snapshot is! Map) return;
    _user = _user!.applySnapshot(Map<String, dynamic>.from(snapshot));
    notifyListeners();
  }

  void updateUser(UserModel Function(UserModel current) change) {
    if (_user == null) return;
    _user = change(_user!);
    notifyListeners();
  }

  void setInventory(List<InventoryItem> items) {
    _inventory = items;
    notifyListeners();
  }

  /// Màu viền đang trang bị; mặc định là viền xám của "Tân binh".
  List<Color> get equippedBorderColors {
    for (final inv in _inventory) {
      if (inv.isEquipped && inv.item.isBorder && inv.item.borderColors.isNotEmpty) return inv.item.colors;
    }
    return const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)];
  }

  String? get equippedAvatarUrl {
    for (final inv in _inventory) {
      if (inv.isEquipped && inv.item.isAvatar && (inv.item.imageUrl ?? '').isNotEmpty) return inv.item.imageUrl;
    }
    return _user?.avatarUrl;
  }

  Future<void> refreshUser() async {
    final data = await ApiClient.I.get('/v1/users/me');
    if (data is Map) setUser(UserModel.fromJson(Map<String, dynamic>.from(data)));
  }

  Future<void> refreshInventory() async {
    final data = await ApiClient.I.get('/v1/shop/inventory');
    if (data is List) {
      setInventory(data.whereType<Map>().map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e))).toList());
    }
  }

  /// Tải lại hồ sơ + kho đồ sau khi mở app hoặc quay lại màn hình. Lỗi mạng thì giữ dữ liệu cũ.
  Future<void> refreshAll() async {
    try {
      await refreshUser();
      if (!me.isAdmin) await refreshInventory();
    } on NetworkException {
      // dùng dữ liệu đang có
    }
  }

  /// Xoá phiên và dữ liệu người dùng khỏi bộ nhớ. Mọi nút "Đăng xuất" đều đi qua đây.
  Future<void> signOut({bool callServer = true}) async {
    final refresh = SessionStore.refreshToken;
    if (callServer && refresh != null) {
      try {
        await ApiClient.I.post('/v1/auth/logout', body: {'refreshToken': refresh}, auth: false);
      } catch (_) {
        // vẫn đăng xuất cục bộ dù server không phản hồi
      }
    }
    await SessionStore.clear();
    _user = null;
    _inventory = const [];
    notifyListeners();
  }
}
