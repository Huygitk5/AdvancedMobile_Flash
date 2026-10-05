import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../data/remote/api_exception.dart';

/// Câu hiển thị cho lỗi bất kỳ (ApiException / NetworkException / khác).
String errorMessage(Object e) {
  if (e is ApiException) return e.userMessage;
  if (e is NetworkException) return e.userMessage;
  // Lỗi kiểm tra dữ liệu ở client: `throw Exception('...')`.
  final s = e.toString();
  if (e is Exception && s.startsWith('Exception: ')) return s.substring('Exception: '.length);
  return tr('Đã có lỗi xảy ra, vui lòng thử lại.');
}

void showSnack(BuildContext context, String message, {Color? color}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
}

void showError(BuildContext context, Object e) => showSnack(context, errorMessage(e), color: Colors.red);
