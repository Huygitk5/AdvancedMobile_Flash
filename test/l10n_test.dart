import 'dart:io';
import 'package:flash/core/l10n.dart';
import 'package:flash/core/l10n_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppLocale.language.value = 'vi');

  test('mọi chuỗi trong tr()/trf() đều có bản dịch English', () {
    final pattern = RegExp(r"\btrf?\(\s*'((?:[^'\\]|\\.)*)'");
    final missing = <String>{};
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart') || entity.path.endsWith('l10n.dart')) continue;
      final source = entity.readAsStringSync();
      for (final m in pattern.allMatches(source)) {
        final key = m.group(1)!.replaceAll("\\'", "'").replaceAll('\\n', '\n');
        if (!RegExp(r'[A-Za-zÀ-ỹ]').hasMatch(key)) continue;
        if (!enTranslations.containsKey(key)) missing.add('${entity.path}: $key');
      }
    }
    expect(missing, isEmpty, reason: 'Thiếu bản dịch trong lib/core/l10n_en.dart');
  });

  test('bản dịch giữ đủ các placeholder {x} của chuỗi gốc', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    final broken = <String>[];
    enTranslations.forEach((vi, en) {
      final a = placeholder.allMatches(vi).map((m) => m.group(1)).toSet();
      final b = placeholder.allMatches(en).map((m) => m.group(1)).toSet();
      if (a.length != b.length || !a.containsAll(b)) broken.add(vi);
    });
    expect(broken, isEmpty);
  });

  test('đổi ngôn ngữ đổi chuỗi hiển thị, chuỗi lạ giữ nguyên', () {
    expect(tr('Trang chủ'), 'Trang chủ');
    AppLocale.language.value = 'en';
    expect(tr('Trang chủ'), 'Home');
    expect(tr('Học tập'), 'Learn');
    expect(tr('Chuỗi không có trong bảng'), 'Chuỗi không có trong bảng');
    expect(trf('{done}/{goal} bài', {'done': 3, 'goal': 5}), '3/5 lessons');
  });
}
