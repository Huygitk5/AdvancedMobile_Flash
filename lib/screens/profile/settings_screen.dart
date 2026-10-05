import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';
import '../../data/user_repository.dart';
import '../../widgets/common.dart';
import '../splash/server_settings_dialog.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              signOutAndGoToWelcome();
            },
            child: Text(tr('Đăng xuất'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Đổi ngôn ngữ giao diện ngay lập tức, lưu trên máy và đồng bộ lên server.
  Future<void> _showLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Chọn Ngôn ngữ'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageTile(dialogContext, 'vi', 'Tiếng Việt'),
            _languageTile(dialogContext, 'en', 'English'),
          ],
        ),
      ),
    );
    if (selected == null || selected == AppLocale.language.value) return;
    await AppLocale.set(selected);
    UserRepository.pushSettings(darkMode: themeNotifier.value == ThemeMode.dark);
    if (mounted) showAppSnack(context, tr('Đã đổi ngôn ngữ!'), icon: Icons.language);
  }

  Widget _languageTile(BuildContext context, String code, String name) {
    final current = AppLocale.language.value == code;
    return ListTile(
      title: Text(name),
      trailing: current ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
      onTap: () => Navigator.pop(context, code),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
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
                      _buildSwitchTile(Icons.volume_up_outlined, tr('Âm thanh ứng dụng'), AppSettings.soundEnabled, (val) async {
                        await AppSettings.setSoundEnabled(val);
                        UserRepository.pushSettings(darkMode: themeNotifier.value == ThemeMode.dark);
                        if (mounted) {
                          setState(() {});
                          showAppSnack(context, val ? tr('Đã bật âm thanh') : tr('Đã tắt âm thanh'));
                        }
                      }),
                      _buildDivider(),
                      _buildSwitchTile(Icons.dark_mode_outlined, tr('Chế độ tối (Dark Mode)'), isDarkMode, (val) async {
                        await AppSettings.setDarkMode(val);
                        UserRepository.pushSettings(darkMode: val);
                        if (mounted) {
                          setState(() {});
                          showAppSnack(context, val ? tr('Đã bật chế độ tối') : tr('Đã tắt chế độ tối'));
                        }
                      }),
                      _buildDivider(),
                      _buildListTile(Icons.language, tr('Ngôn ngữ'), trailingText: AppLocale.displayName, onTap: _showLanguageDialog),
                      _buildDivider(),
                      _buildListTile(Icons.lock_outline, tr('Đổi mật khẩu'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                      _buildDivider(),
                      _buildListTile(Icons.dns_outlined, tr('Địa chỉ máy chủ'), trailingText: Uri.tryParse(AppConfig.apiBaseUrl)?.host ?? '', onTap: () async {
                        await ServerSettingsDialog.show(context);
                        if (mounted) setState(() {});
                      }),
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

  Widget _buildSwitchTile(IconData icon, String title, bool value, Future<void> Function(bool) onChanged) => SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)),
        value: value,
        onChanged: (v) => onChanged(v),
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
