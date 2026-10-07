import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Quên mật khẩu: bước 1 nhập email để nhận OTP, bước 2 (cùng màn) nhập OTP và mật khẩu mới.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Email đang gõ ở màn Đăng nhập; rỗng thì dùng email đăng nhập lần trước.
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _otpSent = false;
  bool _obscure = true;
  bool _busy = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail.isNotEmpty ? widget.initialEmail : (ref.read(appPrefsProvider).lastLoginEmail ?? '');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    _confirm.dispose();
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
    if (!isEmail(_email.text)) {
      showAppSnack(context, tr('Email không hợp lệ'), error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      // Luôn 200 kể cả email không tồn tại (không lộ tài khoản).
      await ref.read(authApiProvider).forgotPassword(_email.text.trim());
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _busy = false;
      });
      _startCountdown();
      showAppSnack(context, tr('Nếu email đã đăng ký, mã OTP sẽ được gửi tới hộp thư của bạn'), icon: Icons.mark_email_read_outlined);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_otp.text.trim())) {
      showAppSnack(context, tr('Vui lòng nhập đủ 6 chữ số'), error: true);
      return;
    }
    if (_password.text.length < 8) {
      showAppSnack(context, tr('Mật khẩu phải có ít nhất 8 ký tự'), error: true);
      return;
    }
    if (_password.text != _confirm.text) {
      showAppSnack(context, tr('Mật khẩu nhập lại không khớp'), error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authApiProvider)
          .resetPassword(email: _email.text.trim(), otp: _otp.text.trim(), newPassword: _password.text);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
        content: Text(tr('Đặt lại mật khẩu thành công, vui lòng đăng nhập lại')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          // Đang ở bước OTP thì quay lại bước nhập email (sửa email gõ nhầm).
          onPressed: () => _otpSent ? setState(() => _otpSent = false) : Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_otpSent ? tr('Đặt lại mật khẩu') : tr('Quên mật khẩu?'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 10),
              Text(
                _otpSent
                    ? trf('Nhập mã OTP 6 số đã gửi tới {email} và đặt mật khẩu mới.', {'email': _email.text.trim()})
                    : tr('Đừng lo lắng! Vui lòng nhập địa chỉ email liên kết với tài khoản của bạn để nhận mã khôi phục.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _email,
                hint: tr('Nhập email của bạn'),
                keyboardType: TextInputType.emailAddress,
                enabled: !_otpSent,
              ),
              if (_otpSent) ...[
                const SizedBox(height: 18),
                AppTextField(
                  label: tr('Mã OTP'),
                  icon: Icons.pin_outlined,
                  controller: _otp,
                  hint: tr('6 chữ số'),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: tr('Mật khẩu mới'),
                  icon: Icons.lock_outline,
                  controller: _password,
                  hint: tr('Ít nhất 8 ký tự'),
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                ),
                const SizedBox(height: 18),
                AppTextField(label: tr('Nhập lại mật khẩu mới'), icon: Icons.lock_outline, controller: _confirm, obscure: _obscure),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: _otpSent ? tr('Đặt lại mật khẩu') : tr('Gửi mã OTP'),
                loading: _busy,
                onPressed: _otpSent ? _reset : _sendOtp,
              ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                Center(
                  child: _countdown > 0
                      ? Text(trf('Gửi lại mã sau {s} giây', {'s': _countdown}), style: const TextStyle(color: AppTheme.greyColor))
                      : TextButton(
                          onPressed: _busy ? null : _sendOtp,
                          child: Text(tr('Gửi lại mã'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
