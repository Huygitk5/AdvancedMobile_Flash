import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/user_repository.dart';
import '../../widgets/common.dart';

/// Đổi mật khẩu: nhập mật khẩu cũ + mật khẩu mới, rồi xác nhận bằng mã OTP gửi tới email của tài khoản.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _otp = TextEditingController();
  bool _obscure = true;
  bool _otpSent = false;
  bool _sending = false;
  bool _busy = false;
  int _countdown = 0;
  Timer? _timer;

  bool get _hasPassword => AppState.I.user?.hasPassword ?? true;

  @override
  void dispose() {
    _timer?.cancel();
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  Future<void> _sendOtp() async {
    setState(() => _sending = true);
    try {
      await UserRepository.requestChangePasswordOtp();
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _sending = false;
      });
      _startCountdown();
      showAppSnack(context, trf('Đã gửi mã OTP tới {email}', {'email': AppState.I.user?.email ?? ''}), icon: Icons.mark_email_read_outlined);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _sending = false);
    }
  }

  Future<void> _submit() async {
    if (_hasPassword && _current.text.isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập mật khẩu hiện tại'), error: true);
      return;
    }
    if (_new.text.length < 8) {
      showAppSnack(context, tr('Mật khẩu phải có ít nhất 8 ký tự'), error: true);
      return;
    }
    if (_new.text != _confirm.text) {
      showAppSnack(context, tr('Mật khẩu nhập lại không khớp'), error: true);
      return;
    }
    if (_otp.text.trim().length != 6) {
      showAppSnack(context, tr('Hãy bấm "Gửi mã" và nhập mã OTP gồm 6 chữ số'), error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await UserRepository.changePassword(
        currentPassword: _hasPassword ? _current.text : null,
        newPassword: _new.text,
        otp: _otp.text,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(tr('Cập nhật mật khẩu thành công!'))));
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Đổi Mật khẩu'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tr('Để bảo vệ tài khoản, mã OTP xác nhận sẽ được gửi tới email của bạn.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              if (_hasPassword) ...[
                AppTextField(
                  label: tr('Mật khẩu cũ'),
                  icon: Icons.lock_outline,
                  controller: _current,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                ),
                const SizedBox(height: 18),
              ],
              AppTextField(label: tr('Mật khẩu mới'), icon: Icons.lock_reset, controller: _new, hint: tr('Ít nhất 8 ký tự'), obscure: _obscure),
              const SizedBox(height: 18),
              AppTextField(label: tr('Nhập lại mật khẩu mới'), icon: Icons.lock_reset, controller: _confirm, obscure: _obscure),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: tr('Mã OTP'),
                      icon: Icons.pin_outlined,
                      controller: _otp,
                      hint: tr('6 chữ số'),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: (_sending || _countdown > 0) ? null : _sendOtp,
                      child: _sending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_countdown > 0 ? '${_countdown}s' : (_otpSent ? tr('Gửi lại') : tr('Gửi mã')),
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: tr('Xác nhận'), loading: _busy, onPressed: _submit),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  // Quên mật khẩu cũ: dùng luồng quên mật khẩu bằng OTP
                  signOutAndGoToWelcome();
                },
                child: Text(tr('Quên mật khẩu cũ? Đăng xuất và dùng "Quên mật khẩu"'), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
