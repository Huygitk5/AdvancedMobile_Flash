import 'package:flutter/material.dart';

import 'l10n_en.dart';

/// Ngôn ngữ giao diện. Văn bản gốc trong code là tiếng Việt; khi chọn English thì tra bảng [enTranslations].
/// Nội dung học (giải thích ngữ pháp, nghĩa của từ) lấy từ server nên không đổi theo ngôn ngữ giao diện.
///
/// Giá trị được lưu ở `AppPrefs.appLanguage` và đồng bộ lên server qua `SettingsRepository.setLanguage`;
/// lớp này chỉ giữ bản trong bộ nhớ để `tr()` đọc đồng bộ.
class AppLocale {
  AppLocale._();

  static final ValueNotifier<String> language = ValueNotifier<String>('vi');

  static bool get isEnglish => language.value == 'en';

  /// Gọi trong `main()` (đọc từ AppPrefs) và mỗi khi cài đặt ngôn ngữ đổi (kể cả do server đẩy về).
  static void apply(String code) {
    if (code != 'vi' && code != 'en') return;
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
