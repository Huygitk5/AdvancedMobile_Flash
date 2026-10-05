import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/app_snack.dart';

/// Bước 1: nhập email nhận OTP. Bước 2 (cùng màn): nhập OTP 6 số + mật khẩu mới.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _otpStep = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = ref.read(appPrefsProvider).lastLoginEmail ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sendOtp() {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      showSnack(context, 'Email không hợp lệ.', color: Colors.red);
      return;
    }
    _run(() async {
      // Luôn 200 kể cả email không tồn tại (không lộ tài khoản).
      await ref.read(authApiProvider).forgotPassword(email);
      if (!mounted) return;
      setState(() => _otpStep = true);
      showSnack(context, 'Nếu email tồn tại, mã OTP đã được gửi tới hộp thư của bạn.');
    });
  }

  void _resetPassword() {
    final otp = _otpCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      showSnack(context, 'Mã OTP gồm 6 chữ số.', color: Colors.red);
      return;
    }
    if (password.length < 8) {
      showSnack(context, 'Mật khẩu mới tối thiểu 8 ký tự.', color: Colors.red);
      return;
    }
    _run(() async {
      await ref.read(authApiProvider).resetPassword(email: _emailCtrl.text.trim(), otp: otp, newPassword: password);
      if (!mounted) return;
      showSnack(context, 'Đặt lại mật khẩu thành công. Hãy đăng nhập lại.', color: Colors.green);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => _otpStep ? setState(() => _otpStep = false) : Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_otpStep ? 'Đặt lại mật khẩu' : 'Quên mật khẩu?',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 10),
              Text(
                _otpStep
                    ? 'Nhập mã OTP 6 số đã gửi tới ${_emailCtrl.text.trim()} và mật khẩu mới.'
                    : 'Đừng lo lắng! Vui lòng nhập địa chỉ email liên kết với tài khoản của bạn để nhận mã khôi phục.',
                style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 40),
              if (!_otpStep) ...[
                _label('Email'),
                _field(_emailCtrl, 'Nhập email của bạn', Icons.email_outlined, keyboard: TextInputType.emailAddress),
              ] else ...[
                _label('Mã OTP'),
                _field(_otpCtrl, '6 chữ số', Icons.pin_outlined, keyboard: TextInputType.number, maxLength: 6),
                const SizedBox(height: 10),
                _label('Mật khẩu mới'),
                _field(_passwordCtrl, 'Tối thiểu 8 ký tự', Icons.lock_outline, obscure: true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: const Text('Gửi lại mã', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _loading ? null : (_otpStep ? _resetPassword : _sendOtp),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(_otpStep ? 'Đặt lại mật khẩu' : 'Gửi yêu cầu',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _field(TextEditingController c, String hint, IconData icon,
          {TextInputType? keyboard, bool obscure = false, int? maxLength}) =>
      TextField(
        controller: c,
        keyboardType: keyboard,
        obscureText: obscure,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          prefixIcon: Icon(icon, color: AppTheme.greyColor),
          filled: true,
          fillColor: const Color(0xFFF4F6FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      );
}
