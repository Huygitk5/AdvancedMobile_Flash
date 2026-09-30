import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../main/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Đăng ký', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const SizedBox(height: 10),
              const Text('Tạo tài khoản để bắt đầu hành trình chinh phục tiếng Anh của bạn.', style: TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5)),
              const SizedBox(height: 30),

              _buildTextField('Họ và tên', Icons.person_outline, hint: 'Nhập tên của bạn'),
              const SizedBox(height: 20),
              _buildTextField('Email', Icons.email_outlined, hint: 'Nhập email'),
              const SizedBox(height: 20),
              _buildTextField('Mật khẩu', Icons.lock_outline, isPassword: true),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text('Tạo tài khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? ', style: TextStyle(color: AppTheme.greyColor)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Đăng nhập', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        TextField(
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