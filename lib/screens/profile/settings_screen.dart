import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/auth_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/app_snack.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// AppPrefs đọc đồng bộ; mỗi lần đổi gọi setState để vẽ lại.
  void _update(Future<void> Function() change, String message) async {
    await change();
    if (!mounted) return;
    setState(() {});
    showSnack(context, message);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              // StartGate tự đóng các màn con và quay về Welcome / Login.
              ref.read(authStateProvider.notifier).logout();
            },
            child: Text('Đăng xuất', style: TextStyle(color: Theme.of(dialogContext).cardColor)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final repo = ref.read(settingsRepositoryProvider);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chọn Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tiếng Việt'),
              onTap: () {
                Navigator.pop(dialogContext);
                _update(() => repo.setLanguage('vi'), 'Đã đổi ngôn ngữ!');
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.pop(dialogContext);
                _update(() => repo.setLanguage('en'), 'Language changed!');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final prefs = ref.read(appPrefsProvider);
    final parts = prefs.dailyReminderTime.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts.first) ?? 20, minute: int.tryParse(parts.last) ?? 0),
    );
    if (picked == null) return;
    final hhmm = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    _update(() => ref.read(settingsRepositoryProvider).setReminderTime(hhmm), 'Sẽ nhắc học lúc $hhmm');
  }

  void _showPasswordDialog() {
    showDialog(context: context, builder: (_) => const _ChangePasswordDialog());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider);
    final repo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Cài đặt', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              children: [
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      _buildSwitchTile(Icons.notifications_outlined, 'Thông báo nhắc học', prefs.isNotificationEnabled,
                          (val) => _update(() => repo.setNotification(val), val ? 'Đã bật thông báo' : 'Đã tắt thông báo')),
                      _buildDivider(),
                      _buildListTile(Icons.alarm, 'Giờ nhắc học', trailingText: prefs.dailyReminderTime, onTap: _pickReminderTime),
                      _buildDivider(),
                      _buildSwitchTile(Icons.volume_up_outlined, 'Âm thanh ứng dụng', prefs.isSoundEnabled,
                          (val) => _update(() => repo.setSound(val), val ? 'Đã bật âm thanh' : 'Đã tắt âm thanh')),
                      _buildDivider(),
                      _buildSwitchTile(Icons.vibration, 'Rung', prefs.isVibrationEnabled,
                          (val) => _update(() => repo.setVibration(val), val ? 'Đã bật rung' : 'Đã tắt rung')),
                      _buildDivider(),
                      _buildSwitchTile(Icons.dark_mode_outlined, 'Chế độ tối (Dark Mode)', prefs.isDarkMode,
                          (val) => _update(() => repo.setDarkMode(val), val ? 'Đã bật chế độ tối' : 'Đã tắt chế độ tối')),
                      _buildDivider(),
                      _buildListTile(Icons.language, 'Ngôn ngữ',
                          trailingText: prefs.appLanguage == 'en' ? 'English' : 'Tiếng Việt', onTap: _showLanguageDialog),
                      _buildDivider(),
                      _buildListTile(Icons.lock_outline, 'Đổi mật khẩu', onTap: _showPasswordDialog),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primaryColor);
  Widget _buildListTile(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) => ListTile(leading: Icon(icon, color: AppTheme.greyColor), title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (trailingText != null) Text(trailingText, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)), const SizedBox(width: 5), const Icon(Icons.chevron_right, color: AppTheme.greyColor, size: 20)]), onTap: onTap);
  Widget _buildDivider() => Divider(height: 1, indent: 50, color: Theme.of(context).scaffoldBackgroundColor);
}

/// Đổi mật khẩu là thao tác online: server trả cặp token mới, lưu ngay.
class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_next.text.length < 8) return setState(() => _error = 'Mật khẩu mới tối thiểu 8 ký tự.');
    if (_next.text != _confirm.text) return setState(() => _error = 'Mật khẩu nhập lại không khớp.');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(settingsRepositoryProvider).changePassword(
            currentPassword: _current.text.isEmpty ? null : _current.text,
            newPassword: _next.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, 'Cập nhật mật khẩu thành công!', color: Colors.green);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Đổi Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _current, obscureText: true, decoration: _deco('Mật khẩu cũ')),
            const SizedBox(height: 10),
            TextField(controller: _next, obscureText: true, decoration: _deco('Mật khẩu mới')),
            const SizedBox(height: 10),
            TextField(controller: _confirm, obscureText: true, decoration: _deco('Nhập lại mật khẩu mới')),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Xác nhận', style: TextStyle(color: Theme.of(context).cardColor)),
        ),
      ],
    );
  }
}
