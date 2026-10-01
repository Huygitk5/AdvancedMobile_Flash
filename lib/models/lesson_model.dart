import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final String title;
  final String type;
  final String level;
  final double progress;
  final String itemCounts;
  final String estimatedTime;
  final Color imageBg;

  Lesson({
    required this.id, required this.title, required this.type, required this.level,
    required this.progress, required this.itemCounts,
    required this.estimatedTime, required this.imageBg
  });
}