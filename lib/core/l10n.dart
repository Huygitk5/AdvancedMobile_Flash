import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n_en.dart';

/// Ngôn ngữ giao diện. Văn bản gốc trong code là tiếng Việt; khi chọn English thì tra bảng [enTranslations].
/// Nội dung học (giải thích ngữ pháp, nghĩa của từ) lấy từ server nên không đổi theo ngôn ngữ giao diện.
class AppLocale {
  AppLocale._();

  static const String _prefKey = 'app_language';
  static final ValueNotifier<String> language = ValueNotifier<String>('vi');

  static bool get isEnglish => language.value == 'en';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved == 'vi' || saved == 'en') language.value = saved!;
  }

  static Future<void> set(String code) async {
    if (code != 'vi' && code != 'en') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
    language.value = code;
  }

  static Locale get locale => Locale(language.value);

  static String get displayName => isEnglish ? 'English' : 'Tiếng Việt';
}

/// Dịch một chuỗi giao diện. [vi] là chuỗi tiếng Việt gốc, cũng là khoá tra bảng English.
String tr(String vi) {
  if (!AppLocale.isEnglish) return vi;
  return enTranslations[vi] ?? vi;
}

/// Dịch rồi thay các placeholder dạng {name}.
String trf(String vi, Map<String, Object> args) {
  var s = tr(vi);
  args.forEach((key, value) => s = s.replaceAll('{$key}', '$value'));
  return s;
}

/// Đánh dấu mọi widget cần dựng lại sau khi đổi ngôn ngữ (giữ nguyên ngăn xếp điều hướng và state).
void rebuildAllWidgets() {
  void rebuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(rebuild);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
}
