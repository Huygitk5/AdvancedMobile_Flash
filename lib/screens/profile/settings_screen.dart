import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../splash/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool sounds = true;
  String currentLanguage = 'Tiếng Việt';

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false),
            // ĐÃ XÓA CHỮ CONST Ở ĐÂY
            child: Text('Đăng xuất', style: TextStyle(color: Theme.of(context).cardColor)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chọn Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Tiếng Việt'), onTap: () { setState(() => currentLanguage = 'Tiếng Việt'); Navigator.pop(context); _showNotification('Đã đổi ngôn ngữ!'); }),
            ListTile(title: const Text('English'), onTap: () { setState(() => currentLanguage = 'English'); Navigator.pop(context); _showNotification('Language changed!'); }),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đổi Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Mật khẩu cũ', filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Mật khẩu mới', filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Nhập lại mật khẩu mới', filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              Navigator.pop(context);
              _showNotification('Cập nhật mật khẩu thành công!');
            },
            // ĐÃ XÓA CHỮ CONST Ở ĐÂY
            child: Text('Xác nhận', style: TextStyle(color: Theme.of(context).cardColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đọc trạng thái Tối/Sáng thực tế của toàn App
    bool isDarkMode = themeNotifier.value == ThemeMode.dark;

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
                      _buildSwitchTile(Icons.notifications_outlined, 'Thông báo nhắc học', notifications, (val) {
                        setState(() => notifications = val);
                        _showNotification(val ? 'Đã bật thông báo' : 'Đã tắt thông báo');
                      }),
                      _buildDivider(),
                      _buildSwitchTile(Icons.volume_up_outlined, 'Âm thanh ứng dụng', sounds, (val) {
                        setState(() => sounds = val);
                        _showNotification(val ? 'Đã bật âm thanh' : 'Đã tắt âm thanh');
                      }),
                      _buildDivider(),

                      // Nối công tắc với biến toàn cục isDarkMode
                      _buildSwitchTile(Icons.dark_mode_outlined, 'Chế độ tối (Dark Mode)', isDarkMode, (val) {
                        setState(() {
                          themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                        });
                        _showNotification(val ? 'Đã bật chế độ tối' : 'Đã tắt chế độ tối');
                      }),

                      _buildDivider(),
                      _buildListTile(Icons.language, 'Ngôn ngữ', trailingText: currentLanguage, onTap: _showLanguageDialog),
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

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) => SwitchListTile(secondary: Icon(icon, color: AppTheme.primaryColor), title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)), value: value, onChanged: onChanged, activeColor: AppTheme.primaryColor);
  Widget _buildListTile(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) => ListTile(leading: Icon(icon, color: AppTheme.greyColor), title: Text(title, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (trailingText != null) Text(trailingText, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)), const SizedBox(width: 5), const Icon(Icons.chevron_right, color: AppTheme.greyColor, size: 20)]), onTap: onTap);
  Widget _buildDivider() => Divider(height: 1, indent: 50, color: Theme.of(context).scaffoldBackgroundColor);
}