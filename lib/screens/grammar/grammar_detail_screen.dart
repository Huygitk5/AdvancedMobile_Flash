import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../quiz/quiz_screen.dart'; // Chuyển sang màn bài tập

class GrammarDetailScreen extends StatelessWidget {
  final String title;

  const GrammarDetailScreen({Key? key, required this.title}) : super(key: key);

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
        title: Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tiến độ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.2,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primaryColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('1/5', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Present Continuous', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    const SizedBox(height: 5),
                    const Text('(Hiện tại tiếp diễn)', style: TextStyle(fontSize: 16, color: AppTheme.greyColor)),
                    const SizedBox(height: 20),
                    const Text(
                      'Dùng để diễn tả hành động đang xảy ra ở hiện tại, hành động sắp xảy ra hoặc một hành động tạm thời.',
                      style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 25),

                    // Cấu trúc
                    Row(
                      children: const [
                        Icon(Icons.grid_view_rounded, color: AppTheme.greyColor, size: 20),
                        SizedBox(width: 8),
                        Text('Cấu trúc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          'S + am/is/are + V-ing',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Ví dụ
                    Row(
                      children: const [
                        Icon(Icons.play_circle_outline, color: AppTheme.greyColor, size: 20),
                        SizedBox(width: 8),
                        Text('Ví dụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildExampleItem('I am studying English.', 'Tôi đang học tiếng Anh.'),
                    _buildExampleItem('She is working now.', 'Cô ấy đang làm việc bây giờ.'),
                    _buildExampleItem('They are playing football.', 'Họ đang chơi bóng đá.'),
                  ],
                ),
              ),
            ),

            // Nút Tiếp theo
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
                  },
                  child: const Text('Tiếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleItem(String en, String vi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 10.0),
            child: CircleAvatar(radius: 3, backgroundColor: Color(0xFF1E293B)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(en, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(vi, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}