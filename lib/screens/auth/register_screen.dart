import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/auth_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/app_snack.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = await ref.read(authApiProvider).register(
            fullName: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            deviceId: await ref.read(secureStoreProvider).deviceId(),
          );
      await ref.read(authStateProvider.notifier).onAuthenticated(auth);
      // Đăng ký xong vào thẳng app (StartGate hiện MainScreen).
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đăng ký', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                const SizedBox(height: 10),
                const Text('Tạo tài khoản để bắt đầu hành trình chinh phục tiếng Anh của bạn.', style: TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5)),
                const SizedBox(height: 30),

                _buildTextField('Họ và tên', Icons.person_outline, _nameCtrl, hint: 'Nhập tên của bạn',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : (v.trim().length > 100 ? 'Tối đa 100 ký tự' : null)),
                const SizedBox(height: 20),
                _buildTextField('Email', Icons.email_outlined, _emailCtrl, hint: 'Nhập email', keyboard: TextInputType.emailAddress,
                    validator: (v) => _emailRegex.hasMatch((v ?? '').trim()) ? null : 'Email không hợp lệ'),
                const SizedBox(height: 20),
                _buildTextField('Mật khẩu', Icons.lock_outline, _passwordCtrl, isPassword: true, hint: 'Tối thiểu 8 ký tự',
                    validator: (v) => (v ?? '').length < 8 ? 'Mật khẩu tối thiểu 8 ký tự' : ((v ?? '').length > 72 ? 'Tối đa 72 ký tự' : null)),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('Tạo tài khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                  ),
                ),
                const SizedBox(height: 30),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text('Đã có tài khoản? ', style: TextStyle(color: AppTheme.greyColor)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Đăng nhập', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {bool isPassword = false, String? hint, TextInputType? keyboard, FormFieldValidator<String>? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
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
