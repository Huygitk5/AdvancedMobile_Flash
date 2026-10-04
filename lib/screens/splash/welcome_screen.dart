import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../main/main_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Cập nhật Logo Tia sét
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50, // Nền vàng nhạt cho hợp với tia sét
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flash_on, // Icon tia sét
                  size: 100,
                  color: Colors.amber, // Màu vàng cam
                ),
              ),
              const SizedBox(height: 40),

              // Cập nhật Tiêu đề thành "Flash"
              Text(
                'Flash',
                style: TextStyle(
                  fontSize: 36, // Chữ to hơn một chút
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.5, // Tạo khoảng cách chữ cho đẹp hơn
                ),
              ),
              const SizedBox(height: 12),

              // Mô tả
              Text(
                'Học tiếng Anh & Ngữ pháp\nhiệu quả, mọi lúc, mọi nơi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.greyColor,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // Nút Đăng nhập
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text('Đăng nhập', style: TextStyle(fontSize: 16, color: AppTheme.primaryColor)),
                ),
              ),
              const SizedBox(height: 30),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text('Đăng ký', style: TextStyle(fontSize: 16, color: Theme.of(context).cardColor)),
                ),
              ),
              const SizedBox(height: 16),

              // Đăng nhập MXH
              Text('Hoặc tiếp tục với', style: TextStyle(color: AppTheme.greyColor)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.g_mobiledata, Colors.red),
                  const SizedBox(width: 20),
                  _buildSocialIcon(Icons.facebook, Colors.blue),
                  const SizedBox(width: 20),
                  _buildSocialIcon(Icons.apple, Colors.black),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}