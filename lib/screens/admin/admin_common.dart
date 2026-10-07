import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/remote/api_exception.dart';
import '../../widgets/common.dart';

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
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return AdminErrorView(error: snap.error!, onRetry: onRetry);
        return builder(snap.data as T);
      },
    );
  }
}

/// Lỗi của màn admin: offline thì nói rõ cần mạng.
class AdminErrorView extends StatelessWidget {
  const AdminErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = error is NetworkException;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(offline ? Icons.wifi_off : Icons.error_outline, size: 56, color: AppTheme.greyColor),
          const SizedBox(height: 12),
          Text(
            offline ? tr('Màn quản trị cần kết nối mạng.') : errorMessage(error),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.greyColor),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(tr('Thử lại'))),
        ]),
      ),
    );
  }
}

/// Chạy một thao tác ghi của admin: lỗi hiện snackbar đỏ, thành công hiện [success]. Trả true nếu thành công.
Future<bool> adminRun(BuildContext context, Future<void> Function() action, {String? success}) async {
  try {
    await action();
    if (context.mounted && success != null) showAppSnack(context, success, icon: Icons.check_circle);
    return true;
  } catch (e) {
    if (context.mounted) showAppSnack(context, errorMessage(e), error: true);
    return false;
  }
}

/// Hộp thoại xác nhận xoá. Trả về true nếu người dùng đồng ý.
Future<bool> confirmDelete(BuildContext context, String what) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(tr('Xác nhận xóa'), style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(trf('Bạn có chắc muốn xóa "{name}"?', {'name': what})),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(tr('Xóa'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  return result == true;
}

/// Khung dùng chung cho các form tạo / sửa của admin: tiêu đề, nội dung cuộn được và nút "Lưu" ở đáy.
class AdminFormShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget>? actions;

  const AdminFormShell(
      {super.key, required this.title, required this.children, required this.saving, required this.onSave, this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: actions,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: ListView(padding: const EdgeInsets.all(20), children: children)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(label: tr('Lưu'), loading: saving, onPressed: onSave),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration formDecoration(String label, {String? hint}) =>
    InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder());

Widget formGap([double h = 16]) => SizedBox(height: h);

InputDecoration adminInputDeco(BuildContext context, String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );

Widget adminSearchField(BuildContext context, {required String hint, required ValueChanged<String> onChanged}) {
  return TextField(
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
  );
}

Widget publishedBadge(bool published) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: published ? Colors.green.shade50 : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
    child: Text(published ? tr('Đang hiện') : tr('Đã ẩn'),
        style: TextStyle(color: published ? Colors.green : AppTheme.greyColor, fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

/// Nút "Xong" ở đáy các form full màn hình.
Widget adminDoneButton(BuildContext context, {required VoidCallback? onPressed, bool loading = false, String? text}) =>
    PrimaryButton(label: text ?? tr('Xong (Done)'), loading: loading, onPressed: onPressed);

int? parseIntOrNull(String s) => int.tryParse(s.trim());
