import 'package:flutter/material.dart';
import '../../core/theme.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text('Kết quả bài kiểm tra', style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Icon Cúp & Điểm số
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
                    const SizedBox(height: 10),
                    const Text('8/10', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                    const Text('Tuyệt vời!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 5),
                    const Text('Bạn đã hoàn thành bài kiểm tra.', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                    const SizedBox(height: 30),

                    // Box Thống kê
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Đúng', '8', Colors.green),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          _buildStatItem('Sai', '2', Colors.red),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          _buildStatItem('Thời gian', '4 phút 32 giây', const Color(0xFF1E293B), isTime: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Danh sách Câu sai
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F0), // Nền đỏ nhạt
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Câu sai', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text('2. The weather is very ______ today.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 10),
                          const Text('A. good', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
                            child: const Text('B. well', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 8),
                          const Text('C. bad', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                          const Text('D. nice', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  child: const Text('Xem chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, {bool isTime = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isTime ? 14 : 22)),
      ],
    );
  }
}