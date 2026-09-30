import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/flashcard_model.dart';

class MockData {
  static List<Topic> vocabularyTopics = [
    Topic(id: 't1', title: 'Daily Life', totalWords: 25, progress: 0.6, iconPath: '☀️'),
    Topic(id: 't2', title: 'Travel', totalWords: 30, progress: 0.3, iconPath: '✈️'),
    Topic(id: 't3', title: 'Food & Drink', totalWords: 25, progress: 0.2, iconPath: '🍔'),
    Topic(id: 't4', title: 'Technology', totalWords: 30, progress: 0.1, iconPath: '💻'),
    Topic(id: 't5', title: 'Business', totalWords: 25, progress: 0.0, iconPath: '💼'),
  ];

  static List<Map<String, dynamic>> grammarTopics = [
    {
      'id': 'g1',
      'title': 'Present Simple',
      'progress': 1.0,
      'status': 'Đã học 100%',
      'icon': Icons.account_tree_outlined,
    },
    {
      'id': 'g2',
      'title': 'Present Continuous',
      'progress': 0.6,
      'status': 'Đang học 60%',
      'icon': Icons.access_alarm,
    },
    {
      'id': 'g3',
      'title': 'Past Simple',
      'progress': 0.0,
      'status': 'Chưa học 0%',
      'icon': Icons.history_edu,
    },
    {
      'id': 'g4',
      'title': 'Present Perfect',
      'progress': 0.0,
      'status': 'Chưa học 0%',
      'icon': Icons.verified_user_outlined,
    },
    {
      'id': 'g5',
      'title': 'Conditional',
      'progress': 0.0,
      'status': 'Chưa học 0%',
      'icon': Icons.alt_route,
    },
  ];

  static List<Flashcard> flashcards = [
    Flashcard(
      id: 'f1',
      word: 'beautiful',
      pronunciation: '/ˈbjuːtɪfl/',
      meaning: 'đẹp, xinh đẹp',
      example: 'She is a beautiful girl.',
      exampleTranslation: 'Cô ấy là một cô gái xinh đẹp.',
    ),
    Flashcard(
      id: 'f2',
      word: 'opportunity',
      pronunciation: '/ˌɒpəˈtjuːnəti/',
      meaning: 'cơ hội',
      example: 'This is a great opportunity for you.',
      exampleTranslation: 'Đây là một cơ hội tuyệt vời cho bạn.',
    ),
  ];
}