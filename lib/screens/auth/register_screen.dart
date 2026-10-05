import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'google_sign_in_helper.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Cùng ràng buộc với `RegisterRequest` của server.
  String? _validate() {
    final name = _name.text.trim();
    if (name.isEmpty) return tr('Vui lòng nhập họ và tên');
    if (name.length > 100) return tr('Họ và tên tối đa 100 ký tự');
    if (!isEmail(_email.text)) return tr('Email không hợp lệ');
    if (_password.text.length < 8) return tr('Mật khẩu phải có ít nhất 8 ký tự');
    if (_password.text.length > 72) return tr('Mật khẩu tối đa 72 ký tự');
    if (_password.text != _confirm.text) return tr('Mật khẩu nhập lại không khớp');
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      showAppSnack(context, problem, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final email = _email.text.trim();
      final auth = await ref.read(authApiProvider).register(
            fullName: _name.text.trim(),
            email: email,
            password: _password.text,
            deviceId: await ref.read(secureStoreProvider).deviceId(),
          );
      if (!mounted) return;
      if (auth.verificationRequired) {
        setState(() => _busy = false);
        // Tài khoản chỉ được kích hoạt sau khi nhập OTP gửi qua email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email, justRegistered: true)),
        );
        return;
      }
      // Server tắt xác thực email: vào thẳng app (StartGate hiện MainScreen).
      await completeSignIn(context, ref, auth);
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
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
              Text(tr('Đăng ký'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 10),
              Text(tr('Tạo tài khoản để bắt đầu hành trình chinh phục tiếng Anh của bạn.'),
                  textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5)),
              const SizedBox(height: 28),
              AppTextField(
                  label: tr('Họ và tên'),
                  icon: Icons.person_outline,
                  controller: _name,
                  hint: tr('Nhập tên của bạn'),
                  maxLength: 100,
                  textInputAction: TextInputAction.next),
              const SizedBox(height: 18),
              AppTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  controller: _email,
                  hint: tr('Nhập email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next),
              const SizedBox(height: 18),
              AppTextField(
                  label: tr('Mật khẩu'),
                  icon: Icons.lock_outline,
                  controller: _password,
                  hint: tr('Ít nhất 8 ký tự'),
                  obscure: _obscure,
                  maxLength: 72,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.next),
              const SizedBox(height: 18),
              AppTextField(
                  label: tr('Nhập lại mật khẩu'),
                  icon: Icons.lock_outline,
                  controller: _confirm,
                  obscure: _obscure,
                  maxLength: 72,
                  onSubmitted: (_) => _submit()),
              const SizedBox(height: 28),
              PrimaryButton(label: tr('Tạo tài khoản'), loading: _busy, onPressed: _submit),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('${tr('Đã có tài khoản?')} ', style: const TextStyle(color: AppTheme.greyColor)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(tr('Đăng nhập'), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
