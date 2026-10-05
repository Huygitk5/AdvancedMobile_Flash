import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../screens/flashcard/flashcard_screen.dart';
import '../screens/grammar/grammar_detail_screen.dart';

/// Mở một bài học gợi ý / đang học dở: từ vựng -> bộ thẻ của chủ đề, ngữ pháp -> bài ngữ pháp.
Future<void> openLesson(BuildContext context, Lesson lesson) {
  if (lesson.isVocabulary) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlashcardScreen(topicId: lesson.id, topicTitle: lesson.title)),
    );
  }
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => GrammarDetailScreen(grammarId: lesson.id, title: lesson.title)),
  );
}
