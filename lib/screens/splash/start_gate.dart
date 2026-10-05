import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/api/api_exception.dart';
import '../../data/api/session_store.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';
import 'server_settings_dialog.dart';
import 'welcome_screen.dart';

/// Màn đầu tiên: có phiên đăng nhập thì tải hồ sơ rồi vào thẳng màn hình chính, không thì sang màn Chào mừng.
class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _boot();
    });
  }

  Future<void> _boot() async {
    if (!SessionStore.hasSession) {
      _toWelcome();
      return;
    }
    setState(() => _error = null);
    try {
      await AppState.I.refreshUser();
      if (!AppState.I.me.isAdmin) await AppState.I.refreshInventory();
      if (!mounted) return;
      goToHome();
    } on ApiException {
      // Phiên không còn hợp lệ (đã bị thu hồi, tài khoản bị khóa...)
      await AppState.I.signOut(callServer: false);
      _toWelcome();
    } on NetworkException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    }
  }

  void _toWelcome() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: ErrorView(message: _error!, onRetry: _boot)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await ServerSettingsDialog.show(context);
                        _boot();
                      },
                      child: Text(tr('Đổi địa chỉ máy chủ')),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AppState.I.signOut(callServer: false);
                        _toWelcome();
                      },
                      child: Text(tr('Đăng nhập lại')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.flash_on, size: 60, color: Colors.amber),
            ),
            const SizedBox(height: 20),
            const Text('Flash',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
