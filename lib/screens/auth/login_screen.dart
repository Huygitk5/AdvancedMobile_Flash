import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/env.dart';
import '../../core/theme.dart';
import '../../data/remote/dto/auth_dto.dart';
import '../../providers/auth_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/app_snack.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  bool _isAdminLogin = false; // Tab đang chọn: Học viên / Quản trị viên

  /// `GoogleSignIn.initialize` chỉ được gọi một lần trong vòng đời app.
  static Future<void>? _googleInit;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = ref.read(appPrefsProvider).lastLoginEmail ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Màn đích (MainScreen / AdminMainScreen) do StartGate chọn theo `role` server trả.
  /// Tab đã chọn phải khớp `role`, nếu không thì huỷ phiên vừa cấp và báo lỗi.
  Future<void> _signIn(Future<AuthDto> Function(String deviceId) call) async {
    setState(() => _loading = true);
    try {
      final deviceId = await ref.read(secureStoreProvider).deviceId();
      final auth = await call(deviceId);
      final isAdmin = auth.user.role == 'ADMIN';
      if (isAdmin != _isAdminLogin) {
        try {
          await ref.read(authApiProvider).logout(auth.refreshToken);
        } catch (_) {
          // Bỏ qua lỗi mạng: token sẽ tự hết hạn ở server.
        }
        throw Exception(isAdmin
            ? 'Đây là tài khoản quản trị, vui lòng chọn tab "Quản trị viên".'
            : 'Tài khoản này không có quyền quản trị.');
      }
      await ref.read(authStateProvider.notifier).onAuthenticated(auth);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleLogin() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      showSnack(context, 'Vui lòng nhập email và mật khẩu.', color: Colors.red);
      return;
    }
    _signIn((deviceId) => ref.read(authApiProvider).login(email: email, password: password, deviceId: deviceId));
  }

  Future<void> _handleGoogleSignIn() async {
    if (Env.googleServerClientId.isEmpty) {
      showSnack(context, 'Đăng nhập Google chưa được cấu hình (GOOGLE_SERVER_CLIENT_ID).', color: Colors.red);
      return;
    }
    String? idToken;
    try {
      final google = GoogleSignIn.instance;
      await (_googleInit ??= google.initialize(serverClientId: Env.googleServerClientId));
      final account = await google.authenticate();
      idToken = account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        showSnack(context, 'Không đăng nhập được bằng Google.', color: Colors.red);
      }
      return;
    }
    if (idToken == null) {
      if (mounted) showSnack(context, 'Google không trả về idToken.', color: Colors.red);
      return;
    }
    await _signIn((deviceId) => ref.read(authApiProvider).google(idToken: idToken!, deviceId: deviceId));
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        // Là màn gốc (đã xem Welcome) thì không có nút back: bấm sẽ thoát app.
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Đăng nhập', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 10),
              const Text('Chào mừng trở lại! Hãy tiếp tục hành trình của bạn.', style: TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5)),
              const SizedBox(height: 30),

              // UI CHỌN QUYỀN (USER / ADMIN)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    _buildRoleTab('Học viên', selected: !_isAdminLogin, onTap: () => setState(() => _isAdminLogin = false)),
                    _buildRoleTab('Quản trị viên', selected: _isAdminLogin, onTap: () => setState(() => _isAdminLogin = true)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField('Email', Icons.email_outlined, _emailCtrl, hint: 'Nhập email của bạn', keyboard: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField('Mật khẩu', Icons.lock_outline, _passwordCtrl, isPassword: true),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                  child: const Text('Quên mật khẩu?', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
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
                  onPressed: _loading ? null : _handleLogin,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Hoặc', style: TextStyle(color: AppTheme.greyColor)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _loading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
                  label: const Text('Tiếp tục với Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? ', style: TextStyle(color: AppTheme.greyColor)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: const Text('Đăng ký ngay', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String label, {required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: _loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? AppTheme.primaryColor : AppTheme.greyColor)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {bool isPassword = false, String? hint, TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: isPassword && _obscurePassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.greyColor),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.greyColor),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF4F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
