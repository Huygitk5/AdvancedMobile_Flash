import '../../core/l10n.dart';

class FieldError {
  final String field;
  final String message;
  const FieldError(this.field, this.message);
}

/// Lỗi nghiệp vụ do server trả về (envelope success = false).
class ApiException implements Exception {
  final int status;
  final String code;
  final String message;
  final List<FieldError> errors;

  /// Dữ liệu kèm theo lỗi (VD: bản mới nhất của server khi 409 VERSION_CONFLICT).
  final dynamic data;

  const ApiException(this.status, this.code, this.message, {this.errors = const [], this.data});

  /// Câu hiển thị cho người dùng: ưu tiên lỗi theo từng trường, sau đó tới mã lỗi đã dịch, cuối cùng là message của server.
  String get userMessage {
    if (errors.isNotEmpty) return errors.first.message;
    final mapped = _codeMessages[code];
    if (mapped != null) return tr(mapped);
    return message.isNotEmpty ? message : tr('Có lỗi xảy ra, vui lòng thử lại');
  }

  bool get isUnauthorized => status == 401;

  @override
  String toString() => 'ApiException($status, $code, $message)';

  static const Map<String, String> _codeMessages = {
    'INVALID_CREDENTIALS': 'Email hoặc mật khẩu không đúng',
    'ACCOUNT_LOCKED': 'Tài khoản đã bị khóa',
    'EMAIL_ALREADY_EXISTS': 'Email đã được sử dụng',
    'EMAIL_NOT_VERIFIED': 'Email chưa được xác thực',
    'INVALID_OTP': 'Mã OTP không đúng hoặc đã hết hạn',
    'WRONG_PASSWORD': 'Mật khẩu hiện tại không đúng',
    'INSUFFICIENT_XP': 'Bạn chưa đủ XP',
    'ALREADY_OWNED': 'Bạn đã sở hữu vật phẩm này',
    'RANK_REQUIREMENT_NOT_MET': 'Bạn chưa đạt thứ hạng yêu cầu',
    'QUEST_NOT_COMPLETED': 'Nhiệm vụ chưa hoàn thành',
    'TOO_MANY_REQUESTS': 'Bạn thao tác quá nhanh, vui lòng thử lại sau',
  };
}

/// Không kết nối được tới server (mất mạng, sai địa chỉ, quá thời gian chờ).
class NetworkException implements Exception {
  final String detail;
  const NetworkException([this.detail = '']);

  String get userMessage => tr('Không kết nối được máy chủ. Hãy kiểm tra mạng và địa chỉ máy chủ.');

  @override
  String toString() => 'NetworkException($detail)';
}

/// Câu hiển thị cho mọi loại lỗi bắt được ở UI.
String errorMessage(Object error) {
  if (error is ApiException) return error.userMessage;
  if (error is NetworkException) return error.userMessage;
  return tr('Có lỗi xảy ra, vui lòng thử lại');
}
