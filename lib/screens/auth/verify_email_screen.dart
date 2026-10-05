import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'google_sign_in_helper.dart';

/// Nhập mã OTP 6 số gửi qua email để kích hoạt tài khoản mới (hoặc tài khoản chưa xác thực khi đăng nhập).
/// Đúng mã thì server cấp token luôn: vào thẳng app.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final bool justRegistered;

  const VerifyEmailScreen({super.key, required this.email, this.justRegistered = false});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _resendSeconds = 60;

  final _otp = TextEditingController();
  bool _busy = false;
  int _countdown = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    final code = _otp.text.trim();
    if (code.length != 6) {
      showAppSnack(context, tr('Vui lòng nhập đủ 6 chữ số'), error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final auth = await ref.read(authApiProvider).verifyEmail(
            email: widget.email,
            otp: code,
            deviceId: await ref.read(secureStoreProvider).deviceId(),
          );
      if (!mounted) return;
      await completeSignIn(context, ref, auth);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authApiProvider).resendVerification(widget.email);
      if (!mounted) return;
      _startCountdown();
      showAppSnack(context, tr('Đã gửi lại mã OTP tới email của bạn'), icon: Icons.mark_email_read_outlined);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_unread_outlined, size: 48, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 22),
              Text(tr('Xác thực email'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 12),
              Text(
                trf('Chúng tôi đã gửi mã OTP gồm 6 chữ số tới {email}. Nhập mã để kích hoạt tài khoản.', {'email': widget.email}),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 12),
                onChanged: (v) {
                  if (v.length == 6 && !_busy) _verify();
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: tr('Xác nhận'), loading: _busy, onPressed: _verify),
              const SizedBox(height: 16),
              Center(
                child: _countdown > 0
                    ? Text(trf('Gửi lại mã sau {s} giây', {'s': _countdown}), style: const TextStyle(color: AppTheme.greyColor))
                    : TextButton(
                        onPressed: _resend,
                        child: Text(tr('Gửi lại mã'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
