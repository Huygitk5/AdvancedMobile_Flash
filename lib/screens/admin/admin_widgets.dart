import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// Khung dùng chung cho các form tạo / sửa của admin: tiêu đề, nội dung cuộn được và nút "Lưu" ở đáy.
class AdminFormShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool saving;
  final VoidCallback onSave;

  const AdminFormShell({super.key, required this.title, required this.children, required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: children,
              ),
            ),
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

InputDecoration formDecoration(String label, {String? hint}) => InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder());

Widget formGap([double h = 16]) => SizedBox(height: h);

/// Hộp thoại xác nhận xoá. Trả về true nếu người dùng đồng ý.
Future<bool> confirmDelete(BuildContext context, String what) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(tr('Xác nhận xóa'), style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(trf('Bạn có chắc muốn xóa "{name}"?', {'name': what})),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
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

const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
