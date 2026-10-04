import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../quiz/quiz_screen.dart';

class GrammarDetailScreen extends StatelessWidget {
  final String title;

  const GrammarDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập linh động theo Tên bài ngữ pháp
    String structure = title.contains('Continuous') ? 'S + am/is/are + V-ing' : 'S + V(s/es) + O';
    String explanation = title.contains('Continuous')
        ? 'Dùng để diễn tả một hành động đang xảy ra tại thời điểm nói hoặc xung quanh thời điểm nói.'
        : 'Dùng để diễn tả một thói quen, một sự thật hiển nhiên hoặc một lịch trình cố định.';

    List<Map<String, String>> examples = title.contains('Continuous')
        ? [
      {'en': 'I am studying English.', 'vi': 'Tôi đang học tiếng Anh.'},
      {'en': 'She is working now.', 'vi': 'Cô ấy đang làm việc bây giờ.'},
    ]
        : [
      {'en': 'I play football every weekend.', 'vi': 'Tôi chơi bóng đá mỗi cuối tuần.'},
      {'en': 'The sun rises in the East.', 'vi': 'Mặt trời mọc ở hướng Đông.'},
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,  size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Text('1/5', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
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
                    Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    const SizedBox(height: 20),
                    Text(
                      explanation,
                      style: TextStyle(fontSize: 16, height: 1.5, ),
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
                      child: Center(
                        child: Text(
                          structure,
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
                    ...examples.map((ex) => _buildExampleItem(ex['en']!, ex['vi']!)).toList(),
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
                  child: Text('Tiếp theo (Kiểm tra)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
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
            child: CircleAvatar(radius: 3, backgroundColor: const Color(0xFF1E293B)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(en, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, )),
                const SizedBox(height: 4),
                Text(vi, style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}