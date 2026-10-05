import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../auth/google_sign_in_helper.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'server_settings_dialog.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _googleBusy = false;

  /// Đã qua Welcome thì lần sau (chưa đăng nhập) mở thẳng LoginScreen.
  void _markOnboarded() => ref.read(appPrefsProvider).setOnboardingCompleted(true);

  void _open(Widget screen) {
    _markOnboarded();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Giữ lâu vào logo để đổi địa chỉ máy chủ khi chạy trên điện thoại thật
                    GestureDetector(
                      onLongPress: () => ServerSettingsDialog.show(context, ref),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.flash_on, size: 96, color: Colors.amber),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Flash',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('Học tiếng Anh & Ngữ pháp\nhiệu quả, mọi lúc, mọi nơi'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: AppTheme.greyColor, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => _open(const LoginScreen()),
                        child: Text(tr('Đăng nhập'), style: const TextStyle(fontSize: 16, color: AppTheme.primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => _open(const RegisterScreen()),
                        child: Text(tr('Đăng ký'), style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(tr('Hoặc tiếp tục với'), style: const TextStyle(color: AppTheme.greyColor)),
                    const SizedBox(height: 14),
                    // Chỉ còn đăng nhập bằng Google
                    InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: _googleBusy
                          ? null
                          : () {
                              _markOnboarded();
                              signInWithGoogle(context, ref, (b) => setState(() => _googleBusy = b));
                            },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                        child: _googleBusy
                            ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
