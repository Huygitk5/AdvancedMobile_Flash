import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/api/api_exception.dart';
import '../../data/auth_repository.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';
import 'forgot_password_screen.dart';
import 'google_sign_in_helper.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _isAdminLogin = false; // Chọn đăng nhập học viên hay quản trị viên
  bool _busy = false;
  bool _googleBusy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!isEmail(email)) {
      showAppSnack(context, tr('Email không hợp lệ'), error: true);
      return;
    }
    if (password.isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập mật khẩu'), error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await AuthRepository.login(email, password);
      // Tab đã chọn phải khớp quyền của tài khoản
      if (_isAdminLogin != result.user.isAdmin) {
        await AppState.I.signOut();
        if (!mounted) return;
        showAppSnack(
          context,
          _isAdminLogin ? tr('Tài khoản này không có quyền quản trị') : tr('Đây là tài khoản quản trị, hãy chọn tab Quản trị viên'),
          error: true,
        );
        setState(() => _busy = false);
        return;
      }
      goToHome();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'EMAIL_NOT_VERIFIED') {
        setState(() => _busy = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)));
        return;
      }
      showAppSnack(context, e.userMessage, error: true);
      setState(() => _busy = false);
    } on NetworkException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.userMessage, error: true);
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tr('Đăng nhập'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 10),
              Text(tr('Chào mừng trở lại! Hãy tiếp tục hành trình của bạn.'),
                  textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5)),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(child: _roleTab(tr('Học viên'), !_isAdminLogin, () => setState(() => _isAdminLogin = false))),
                    Expanded(child: _roleTab(tr('Quản trị viên'), _isAdminLogin, () => setState(() => _isAdminLogin = true))),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              AppTextField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _email,
                hint: tr('Nhập email của bạn'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: tr('Mật khẩu'),
                icon: Icons.lock_outline,
                controller: _password,
                obscure: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                onSubmitted: (_) => _handleLogin(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen(initialEmail: _email.text.trim()))),
                  child: Text(tr('Quên mật khẩu?'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: tr('Đăng nhập'), loading: _busy, onPressed: _handleLogin),
              if (!_isAdminLogin) ...[
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(tr('Hoặc'), style: const TextStyle(color: AppTheme.greyColor)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 26),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _googleBusy ? null : () => signInWithGoogle(context, (b) => setState(() => _googleBusy = b)),
                  icon: _googleBusy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
                  label: Text(tr('Tiếp tục với Google'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${tr('Chưa có tài khoản?')} ', style: const TextStyle(color: AppTheme.greyColor)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: Text(tr('Đăng ký ngay'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTab(String label, bool selected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? (isDark ? const Color(0xFF1E293B) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? AppTheme.primaryColor : AppTheme.greyColor)),
        ),
      ),
    );
  }
}
