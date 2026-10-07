import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/widget/home_widget_service.dart';
import '../../providers/auth_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../splash/server_settings_dialog.dart';
import 'change_password_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final Future<bool> _canPinWidget = HomeWidgetService.canRequestPin();

  Future<void> _addHomeWidget() async {
    await ref.read(appPrefsProvider).setHomeWidgetPromptDone(true);
    final ok = await HomeWidgetService.requestPin(ref.read(dbProvider));
    if (!ok && mounted) showAppSnack(context, tr('Không thêm được widget'), error: true);
  }

  /// AppPrefs đọc đồng bộ; mỗi lần đổi gọi setState để vẽ lại. Cài đặt lưu trên máy và đồng bộ lên server (SETTINGS_UPDATE).
  Future<void> _update(Future<void> Function() change, String Function() message, {IconData? icon}) async {
    await change();
    if (!mounted) return;
    setState(() {});
    // Lấy câu thông báo SAU khi đổi (đổi ngôn ngữ thì báo bằng ngôn ngữ mới).
    showAppSnack(context, message(), icon: icon);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Xác nhận Đăng xuất'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(tr('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              // StartGate tự đóng các màn con và quay về Welcome / Login.
              ref.read(authStateProvider.notifier).logout();
            },
            child: Text(tr('Đăng xuất'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Đổi ngôn ngữ giao diện ngay lập tức, lưu trên máy và đồng bộ lên server.
  Future<void> _showLanguageDialog() async {
    final current = ref.read(appPrefsProvider).appLanguage;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Chọn Ngôn ngữ'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageTile(dialogContext, 'vi', 'Tiếng Việt', current),
            _languageTile(dialogContext, 'en', 'English', current),
          ],
        ),
      ),
    );
    if (selected == null || selected == current) return;
    await _update(() => ref.read(settingsRepositoryProvider).setLanguage(selected), () => tr('Đã đổi ngôn ngữ!'),
        icon: Icons.language);
  }

  Widget _languageTile(BuildContext context, String code, String name, String current) => ListTile(
        title: Text(name),
        trailing: current == code ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
        onTap: () => Navigator.pop(context, code),
      );

  Future<void> _pickReminderTime() async {
    final prefs = ref.read(appPrefsProvider);
    final parts = prefs.dailyReminderTime.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts.first) ?? 20, minute: int.tryParse(parts.last) ?? 0),
    );
    if (picked == null) return;
    final hhmm = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await _update(() => ref.read(settingsRepositoryProvider).setReminderTime(hhmm), () => trf('Sẽ nhắc học lúc {time}', {'time': hhmm}));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Cài đặt'), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
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
                      // _buildSwitchTile(Icons.notifications_outlined, tr('Thông báo nhắc học'), prefs.isNotificationEnabled,
                      //     (val) => _update(() => repo.setNotification(val), () => val ? tr('Đã bật thông báo') : tr('Đã tắt thông báo'))),
                      // _buildDivider(),
                      // _buildListTile(Icons.alarm, tr('Giờ nhắc học'), trailingText: prefs.dailyReminderTime, onTap: _pickReminderTime),
                      // _buildDivider(),
                      _buildSwitchTile(Icons.volume_up_outlined, tr('Âm thanh ứng dụng'), prefs.isSoundEnabled,
                          (val) => _update(() => repo.setSound(val), () => val ? tr('Đã bật âm thanh') : tr('Đã tắt âm thanh'))),
                      _buildDivider(),
                      // _buildSwitchTile(Icons.vibration, tr('Rung'), prefs.isVibrationEnabled,
                      //     (val) => _update(() => repo.setVibration(val), () => val ? tr('Đã bật rung') : tr('Đã tắt rung'))),
                      // _buildDivider(),
                      _buildSwitchTile(Icons.dark_mode_outlined, tr('Chế độ tối (Dark Mode)'), prefs.isDarkMode,
                          (val) => _update(() => repo.setDarkMode(val), () => val ? tr('Đã bật chế độ tối') : tr('Đã tắt chế độ tối'))),
                      _buildDivider(),
                      _buildListTile(Icons.language, tr('Ngôn ngữ'),
                          trailingText: AppLocale.displayName, onTap: _showLanguageDialog),
                      _buildDivider(),
                      _buildListTile(Icons.lock_outline, tr('Đổi mật khẩu'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                      // Chỉ Android + launcher hỗ trợ ghim widget.
                      FutureBuilder<bool>(
                        future: _canPinWidget,
                        builder: (context, snap) => snap.data != true
                            ? const SizedBox.shrink()
                            : Column(children: [
                                _buildDivider(),
                                _buildListTile(Icons.widgets_outlined, tr('Thêm widget ra màn hình chính'),
                                    onTap: _addHomeWidget),
                              ]),
                      ),
                      // _buildDivider(),
                      // _buildListTile(Icons.dns_outlined, tr('Địa chỉ máy chủ'),
                      //     trailingText: Uri.tryParse(AppConfig.apiBaseUrl)?.host ?? '', onTap: () async {
                      //   await ServerSettingsDialog.show(context, ref);
                      //   if (mounted) setState(() {});
                      // }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: Text(tr('Đăng xuất'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryColor,
      );

  Widget _buildListTile(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) => ListTile(
        leading: Icon(icon, color: AppTheme.greyColor),
        title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(trailingText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
              ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right, color: AppTheme.greyColor, size: 20),
          ],
        ),
        onTap: onTap,
      );

  Widget _buildDivider() => Divider(height: 1, indent: 50, color: Theme.of(context).scaffoldBackgroundColor);
}
