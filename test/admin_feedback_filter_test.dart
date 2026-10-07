import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash/screens/admin/admin_feedback_screen.dart';

void main() {
  test('feedbackDateBounds: null range -> no bounds', () {
    final b = feedbackDateBounds(null);
    expect(b.from, isNull);
    expect(b.to, isNull);
  });

  test('feedbackDateBounds: covers whole first and last day', () {
    final b = feedbackDateBounds(DateTimeRange(start: DateTime(2026, 3, 5, 14, 30), end: DateTime(2026, 3, 9, 8)));
    expect(b.from, DateTime(2026, 3, 5));
    expect(b.to, DateTime(2026, 3, 9, 23, 59, 59, 999));
  });

  test('FeedbackViewFilter maps to isViewed', () {
    expect(FeedbackViewFilter.all.isViewed, isNull);
    expect(FeedbackViewFilter.unviewed.isViewed, isFalse);
    expect(FeedbackViewFilter.viewed.isViewed, isTrue);
  });
}
