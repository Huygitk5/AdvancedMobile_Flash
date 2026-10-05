import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/remote/api_exception.dart';
import '../../widgets/app_snack.dart';

const cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

/// Màn admin chỉ chạy online: hiện loading / lỗi rõ ràng (kể cả offline) / dữ liệu, có nút thử lại.
class AdminAsync<T> extends StatelessWidget {
  const AdminAsync({super.key, required this.future, required this.onRetry, required this.builder});

  final Future<T>? future;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          final offline = snap.error is NetworkException;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(offline ? Icons.wifi_off : Icons.error_outline, size: 56, color: AppTheme.greyColor),
                const SizedBox(height: 12),
                Text(
                  offline ? 'Màn quản trị cần kết nối mạng.' : errorMessage(snap.error!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.greyColor),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
              ]),
            ),
          );
        }
        return builder(snap.data as T);
      },
    );
  }
}

/// Chạy một thao tác ghi của admin: lỗi hiện snackbar đỏ, thành công hiện [success]. Trả true nếu thành công.
Future<bool> adminRun(BuildContext context, Future<void> Function() action, {String? success}) async {
  try {
    await action();
    if (context.mounted && success != null) showSnack(context, success, color: Colors.green);
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}

Future<bool> confirmDelete(BuildContext context, String what) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Xoá $what?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ??
    false;

InputDecoration adminInputDeco(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );

/// Nút "Xong" ở đáy các form full màn hình.
Widget adminDoneButton(BuildContext context, {required VoidCallback? onPressed, bool loading = false, String text = 'Xong (Done)'}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(text, style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );

int? parseIntOrNull(String s) => int.tryParse(s.trim());
