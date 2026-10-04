import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/quiz_model.dart';
import '../../models/quiz_result_model.dart';
import '../../models/quiz_review_model.dart'; // Thêm import này
import '../../data/mock_data.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  DateTime startTime = DateTime.now();

  // Dữ liệu câu hỏi giờ đã có thêm explanation
  final List<QuizQuestion> questions = [
    QuizQuestion(id: 'q1', topicId: 't1', questionText: 'She ______ her homework now.', options: ['is doing', 'does', 'did', 'was doing'], correctAnswerIndex: 0, explanation: 'Câu ở thì hiện tại tiếp diễn, nên dùng "is doing".'),
    QuizQuestion(id: 'q2', topicId: 't1', questionText: 'The weather is very ______ today.', options: ['good', 'well', 'bad', 'nice'], correctAnswerIndex: 3, explanation: 'Sau "is" (thời tiết) ta dùng tính từ, nên đáp án đúng là "nice".'),
    QuizQuestion(id: 'q5', topicId: 't1', questionText: 'I ______ to the store yesterday.', options: ['went', 'go', 'goes', 'going'], correctAnswerIndex: 0, explanation: 'Câu ở thì quá khứ đơn, dấu hiệu "yesterday" nên dùng "went".'),
  ];

  final List<String> optionLetters = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(questions.length, null);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    int correctAnswers = 0;
    int wrongAnswers = 0;
    List<String> wrongQuestionIds = [];

    // Khởi tạo mảng Review động
    List<QuizReviewItem> reviewData = [];

    for (int i = 0; i < questions.length; i++) {
      int userSelected = selectedAnswers[i] ?? -1;

      if (userSelected == questions[i].correctAnswerIndex) {
        correctAnswers++;
      } else {
        wrongAnswers++;
        wrongQuestionIds.add(questions[i].id);
      }

      // Tạo object Review cho từng câu dựa trên lựa chọn của user
      reviewData.add(QuizReviewItem(
        id: questions[i].id,
        question: questions[i].questionText,
        options: questions[i].options,
        correctIndex: questions[i].correctAnswerIndex,
        userIndex: userSelected,
        explanation: questions[i].explanation,
      ));
    }

    int timeTaken = DateTime.now().difference(startTime).inSeconds;

    QuizResult result = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: MockData.currentUser.id,
      topicId: questions.first.topicId,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      timeTakenSeconds: timeTaken,
      wrongQuestionIds: wrongQuestionIds,
    );

    // Truyền thẳng dữ liệu sang màn hình Kết quả
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizResultScreen(result: result, reviewData: reviewData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    QuizQuestion currentQuestion = questions[currentQuestionIndex];
    int? currentSelection = selectedAnswers[currentQuestionIndex];
    bool isLastQuestion = currentQuestionIndex == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,  size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Bài kiểm tra', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / questions.length,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primaryColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${currentQuestionIndex + 1}/${questions.length}', style: TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chọn đáp án đúng nhất.', style: TextStyle(fontSize: 16, color: AppTheme.greyColor)),
                    const SizedBox(height: 20),
                    Text(currentQuestion.questionText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, )),
                    const SizedBox(height: 30),

                    ...List.generate(currentQuestion.options.length, (index) {
                      bool isSelected = currentSelection == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAnswers[currentQuestionIndex] = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                                child: Text(optionLetters[index], style: TextStyle(color: isSelected ? Colors.white : AppTheme.greyColor, fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  currentQuestion.options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppTheme.primaryColor : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24)
                            ],
                          ),
                        ),
                      );
                    }),
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
                    backgroundColor: currentSelection != null ? AppTheme.primaryColor : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: currentSelection != null ? 2 : 0,
                  ),
                  onPressed: currentSelection == null ? null : _nextQuestion,
                  child: Text(isLastQuestion ? 'Nộp bài' : 'Tiếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}