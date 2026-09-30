import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../main/main_screen.dart';

class CompletionScreen extends StatelessWidget {
  const CompletionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Cúp với hiệu ứng nền mây (có thể dùng Stack + Container hình bầu dục để tạo giả mây)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150, height: 100,
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(50)),
                  ),
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Bạn đã hoàn thành\nhết các bài học hôm nay!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.3),
              ),
              const SizedBox(height: 15),
              const Text(
                'Hãy tiếp tục duy trì thói quen\nđể đạt được mục tiêu nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.greyColor, fontSize: 15, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // Quay về trang chủ
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false, // Lệnh này giúp xóa sạch lịch sử điều hướng đằng trước
                    );
                  },
                  child: const Text('Quay về trang chủ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}