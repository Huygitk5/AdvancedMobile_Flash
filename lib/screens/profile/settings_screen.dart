import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool sounds = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt', style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildSwitchTile(Icons.notifications_outlined, 'Thông báo', notifications, (val) => setState(() => notifications = val)),
                _buildDivider(),
                _buildSwitchTile(Icons.volume_up_outlined, 'Âm thanh', sounds, (val) => setState(() => sounds = val)),
                _buildDivider(),
                _buildSwitchTile(Icons.dark_mode_outlined, 'Chế độ tối', darkMode, (val) => setState(() => darkMode = val)),
                _buildDivider(),
                _buildListTile(Icons.language, 'Ngôn ngữ', trailingText: 'Tiếng Việt'),
                _buildDivider(),
                _buildListTile(Icons.lock_outline, 'Đổi mật khẩu'),
                _buildDivider(),
                _buildListTile(Icons.help_outline, 'Trợ giúp & Hỗ trợ'),
                _buildDivider(),
                _buildListTile(Icons.info_outline, 'Giới thiệu ứng dụng'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B))),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildListTile(IconData icon, String title, {String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.greyColor),
      title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
          if (trailingText != null) const SizedBox(width: 5),
          const Icon(Icons.chevron_right, color: AppTheme.greyColor, size: 20),
        ],
      ),
      onTap: () {
        // Phản hồi UI khi bấm vào
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chức năng $title đang được phát triển'), duration: const Duration(seconds: 1)),
        );
      },
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 50, color: Color(0xFFF4F6FA));
}