import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/remote/api_exception.dart';
import '../providers/feedback_providers.dart';
import 'common.dart';

const feedbackMaxLength = 1000;

extension FeedbackTypeUi on FeedbackType {
  String get label => switch (this) {
        FeedbackType.flashcard => tr('Flashcard'),
        FeedbackType.grammar => tr('Grammar'),
        FeedbackType.quiz => tr('Quiz'),
      };

  IconData get icon => switch (this) {
        FeedbackType.flashcard => Icons.style_outlined,
        FeedbackType.grammar => Icons.menu_book_outlined,
        FeedbackType.quiz => Icons.quiz_outlined,
      };
}

enum FeedbackAction { send, edit, delete }

/// Câu báo lỗi cho thao tác góp ý: mất mạng và "admin đã xem" có câu riêng, còn lại dùng [errorMessage].
String feedbackErrorMessage(Object e, FeedbackAction action) {
  if (e is NetworkException) {
    return switch (action) {
      FeedbackAction.send => tr('Cần kết nối mạng để gửi góp ý'),
      FeedbackAction.edit => tr('Cần kết nối mạng để sửa góp ý'),
      FeedbackAction.delete => tr('Cần kết nối mạng để xóa góp ý'),
    };
  }
  if (isFeedbackAlreadyViewed(e)) {
    return action == FeedbackAction.delete ? tr('Admin đã xem, không thể xóa') : tr('Admin đã xem, không thể sửa');
  }
  return errorMessage(e);
}

bool isFeedbackAlreadyViewed(Object e) => e is ApiException && e.code == 'FEEDBACK_ALREADY_VIEWED';

/// Hộp thoại gửi góp ý (hoặc sửa khi có [editing]). Trả true nếu đã gửi / lưu thành công.
Future<bool> showFeedbackDialog(
  BuildContext context,
  WidgetRef ref, {
  required FeedbackType type,
  required String itemId,
  required String targetLabel,
  FeedbackItem? editing,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FeedbackDialog(ref: ref, type: type, itemId: itemId, targetLabel: targetLabel, editing: editing),
  );
  return ok ?? false;
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog({
    required this.ref,
    required this.type,
    required this.itemId,
    required this.targetLabel,
    required this.editing,
  });

  final WidgetRef ref;
  final FeedbackType type;
  final String itemId;
  final String targetLabel;
  final FeedbackItem? editing;

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.editing?.content ?? '');
  bool _sending = false;
  String? _error;

  bool get _isEdit => widget.editing != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final api = widget.ref.read(feedbackApiProvider);
    try {
      if (_isEdit) {
        await api.update(widget.editing!.id, content);
      } else {
        await api.create(type: widget.type, itemId: widget.itemId, content: content);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = feedbackErrorMessage(e, _isEdit ? FeedbackAction.edit : FeedbackAction.send);
      setState(() {
        _sending = false;
        _error = msg;
      });
      showAppSnack(context, msg, error: true);
      return;
    }
    widget.ref.invalidate(feedbackSummaryProvider);
    if (!mounted) return;
    showAppSnack(context, _isEdit ? tr('Đã cập nhật góp ý') : tr('Đã gửi góp ý, cảm ơn bạn!'), icon: Icons.check_circle);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: !_sending,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_isEdit ? tr('Sửa góp ý') : tr('Gửi góp ý'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(widget.type.icon, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.targetLabel.isEmpty ? widget.type.label : '${widget.type.label}: ${widget.targetLabel}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                enabled: !_sending,
                autofocus: true,
                minLines: 4,
                maxLines: 8,
                maxLength: feedbackMaxLength,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: tr('Nhập nội dung góp ý...'),
                  hintStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_error!, style: const TextStyle(color: AppTheme.wrongColor, fontSize: 13)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : () => Navigator.pop(context, false),
            child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor)),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _sending || value.text.trim().isEmpty ? null : _submit,
              child: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(_isEdit ? tr('Lưu') : tr('Gửi'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút "Gửi góp ý" dùng chung cho flashcard / grammar / quiz. Có [label] thì vẽ nút chữ thay vì icon.
class FeedbackIconButton extends ConsumerWidget {
  const FeedbackIconButton({
    super.key,
    required this.type,
    required this.itemId,
    required this.targetLabel,
    this.label,
  });

  final FeedbackType type;
  final String itemId;
  final String targetLabel;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open() => showFeedbackDialog(context, ref, type: type, itemId: itemId, targetLabel: targetLabel);
    if (label != null) {
      return OutlinedButton.icon(onPressed: open, icon: const Icon(Icons.feedback_outlined), label: Text(label!));
    }
    return IconButton(
      tooltip: tr('Gửi góp ý'),
      icon: const Icon(Icons.feedback_outlined),
      visualDensity: VisualDensity.compact,
      onPressed: open,
    );
  }
}
