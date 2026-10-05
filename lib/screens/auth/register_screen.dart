import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/auth_repository.dart';
import '../../widgets/common.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  String? _validate() {
    if (_name.text.trim().isEmpty) return tr('Vui lòng nhập họ và tên');
    if (!isEmail(_email.text)) return tr('Email không hợp lệ');
    if (_password.text.length < 8) return tr('Mật khẩu phải có ít nhất 8 ký tự');
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
      final result = await AuthRepository.register(_name.text, _email.text, _password.text);
      if (!mounted) return;
      if (result.verificationRequired) {
        setState(() => _busy = false);
        // Tài khoản chỉ được kích hoạt sau khi nhập OTP gửi qua email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: _email.text.trim(), justRegistered: true)),
        );
      } else {
        goToHome();
      }
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
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.next),
              const SizedBox(height: 18),
              AppTextField(
                  label: tr('Nhập lại mật khẩu'),
                  icon: Icons.lock_outline,
                  controller: _confirm,
                  obscure: _obscure,
                  onSubmitted: (_) => _submit()),
              const SizedBox(height: 28),
              PrimaryButton(label: tr('Tạo tài khoản'), loading: _busy, onPressed: _submit),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
