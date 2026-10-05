import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';

/// Chọn địa chỉ backend khi chạy trên máy thật (VD: http://192.168.1.5:8080, cùng Wi-Fi với máy chạy backend).
class ServerSettingsDialog {
  static Future<void> show(BuildContext context) async {
    final controller = TextEditingController(text: AppConfig.apiBaseUrl);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Địa chỉ máy chủ'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Điện thoại thật cần dùng IP của máy chạy backend (cùng Wi-Fi), ví dụ http://192.168.1.5:8080. Emulator Android dùng http://10.0.2.2:8080.'),
              style: const TextStyle(color: AppTheme.greyColor, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: AppConfig.defaultBaseUrl,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AppConfig.setApiBaseUrl(null);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(tr('Mặc định')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              await AppConfig.setApiBaseUrl(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(tr('Lưu'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
