import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';

/// Hộp thoại nhập một đoạn văn bản (slogan, ghi chú thẻ...). Controller do State sở hữu và
/// dispose cùng widget, nên không bị giải phóng khi animation đóng hộp thoại còn đang chạy.
Future<void> showTextEditDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required String initialText,
  required void Function(String text) onSave,
  VoidCallback? onDelete,
  int? maxLength,
  int maxLines = 1,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _TextEditDialog(
      title: title,
      hint: hint,
      initialText: initialText,
      onSave: onSave,
      onDelete: onDelete,
      maxLength: maxLength,
      maxLines: maxLines,
    ),
  );
}

class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({
    required this.title,
    required this.hint,
    required this.initialText,
    required this.onSave,
    required this.onDelete,
    required this.maxLength,
    required this.maxLines,
  });

  final String title;
  final String hint;
  final String initialText;
  final void Function(String text) onSave;
  final VoidCallback? onDelete;
  final int? maxLength;
  final int maxLines;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _controller,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
      actions: [
        if (widget.onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete!();
            },
            child: Text(tr('Xóa'), style: const TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () {
            final text = _controller.text;
            Navigator.pop(context);
            widget.onSave(text);
          },
          child: Text(tr('Lưu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
