import 'package:flutter/material.dart';
import '../core/l10n.dart';
import '../core/theme.dart';

// Mọi màn hình đã import common.dart đều dùng được errorMessage(e) để hiện lỗi API / mạng
export 'app_snack.dart' show errorMessage;

/// Avatar có viền gradient. Viền nằm *ngoài* ảnh và ảnh được cắt tròn, nên ảnh không bao giờ tràn ra khỏi viền.
class UserAvatar extends StatelessWidget {
  /// Đường kính tổng (gồm cả viền).
  final double size;
  final List<Color> borderColors;
  final String? imageUrl;
  final String initials;
  final double ringWidth;

  const UserAvatar({
    super.key,
    this.size = 48,
    this.borderColors = const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
    this.imageUrl,
    this.initials = '',
    this.ringWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final colors = borderColors.length >= 2 ? borderColors : [borderColors.isEmpty ? const Color(0xFFE2E8F0) : borderColors.first, borderColors.isEmpty ? const Color(0xFFCBD5E1) : borderColors.first];
    final inner = size - ringWidth * 2;
    final hasImage = (imageUrl ?? '').isNotEmpty;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: ClipOval(
        child: Container(
          width: inner,
          height: inner,
          color: const Color(0xFFEEF2FF),
          alignment: Alignment.center,
          child: hasImage
              ? Image.network(
                  imageUrl!,
                  width: inner,
                  height: inner,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(inner),
                )
              : _fallback(inner),
        ),
      ),
    );
  }

  Widget _fallback(double inner) {
    if (initials.isNotEmpty) {
      return Text(initials,
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: inner * 0.42));
    }
    return Icon(Icons.person, color: AppTheme.primaryColor, size: inner * 0.62);
  }
}

String initialsOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
}

/// Thông báo lỗi kèm nút "Thử lại".
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.greyColor),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14, height: 1.4)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(tr('Thử lại'))),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyView({super.key, required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.greyColor),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

void showAppSnack(BuildContext context, String message, {bool error = false, IconData? icon}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10)],
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: error ? AppTheme.wrongColor : AppTheme.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
  );
}

/// Ô nhập dùng chung cho các màn đăng nhập / đăng ký / đổi mật khẩu.
class AppTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleObscure;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onToggleObscure,
    this.maxLength,
    this.onSubmitted,
    this.textInputAction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: Icon(icon, color: AppTheme.greyColor),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.greyColor),
                    onPressed: onToggleObscure,
                  ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF273449) : const Color(0xFFF4F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

/// Nút chính bo tròn, hiện vòng xoay khi đang xử lý.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
