import 'package:dio/dio.dart';

class FieldErrorDto {
  const FieldErrorDto(this.field, this.message);

  final String? field;
  final String message;

  factory FieldErrorDto.fromJson(Map<String, dynamic> j) =>
      FieldErrorDto(j['field'] as String?, (j['message'] ?? '') as String);
}

/// Server trả lỗi theo envelope `{success:false, code, message, data?, errors?}`.
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.errors = const [],
    this.data,
  });

  final int status;
  final String code;
  final String message;
  final List<FieldErrorDto> errors;

  /// Dữ liệu kèm theo lỗi, VD 409 VERSION_CONFLICT trả bản ghi hiện tại trên server.
  final dynamic data;

  bool get isVersionConflict => status == 409 && code == 'VERSION_CONFLICT';
  bool get isUnauthorized => status == 401;

  /// Câu tiếng Việt hiển thị cho người dùng.
  String get userMessage {
    if (code == 'VALIDATION_ERROR' && errors.isNotEmpty) {
      return errors.map((e) => e.message).join('\n');
    }
    if (_messages.containsKey(code)) return _messages[code]!;
    if (message.isNotEmpty) return message;
    if (status >= 500) return _messages['INTERNAL_ERROR']!;
    return 'Đã có lỗi xảy ra, vui lòng thử lại.';
  }

  @override
  String toString() => 'ApiException($status $code: $message)';

  static const Map<String, String> _messages = {
    'INVALID_CREDENTIALS': 'Email hoặc mật khẩu không đúng.',
    'ACCOUNT_LOCKED': 'Tài khoản của bạn đã bị khoá.',
    'EMAIL_ALREADY_EXISTS': 'Email này đã được đăng ký.',
    'INVALID_OTP': 'Mã OTP không đúng hoặc đã hết hạn.',
    'WRONG_PASSWORD': 'Mật khẩu hiện tại không đúng.',
    'INSUFFICIENT_XP': 'Bạn không đủ XP.',
    'ALREADY_OWNED': 'Bạn đã sở hữu vật phẩm này.',
    'ALREADY_CLAIMED': 'Phần thưởng này đã được nhận.',
    'RANK_REQUIREMENT_NOT_MET': 'Bạn chưa đạt thứ hạng yêu cầu.',
    'QUEST_NOT_COMPLETED': 'Nhiệm vụ chưa hoàn thành.',
    'VERSION_CONFLICT': 'Dữ liệu đã được cập nhật ở thiết bị khác.',
    'TOO_MANY_REQUESTS': 'Bạn thao tác quá nhanh, vui lòng thử lại sau ít phút.',
    'UNAUTHORIZED': 'Phiên đăng nhập đã hết hạn.',
    'FORBIDDEN': 'Bạn không có quyền thực hiện thao tác này.',
    'NOT_FOUND': 'Không tìm thấy dữ liệu.',
    'BUSINESS_RULE_VIOLATION': 'Thao tác không hợp lệ.',
    'INTERNAL_ERROR': 'Máy chủ đang gặp sự cố, vui lòng thử lại sau.',
  };
}

/// Không tới được server (mất mạng, timeout). Khác với [ApiException]: server đã trả lời.
/// Offline-first: lỗi này KHÔNG được coi là lý do để đăng xuất hay bỏ op trong sync_queue.
class NetworkException implements Exception {
  const NetworkException([this.cause]);

  final DioException? cause;

  String get userMessage => 'Không có kết nối mạng. Vui lòng kiểm tra lại.';

  @override
  String toString() => 'NetworkException(${cause?.type})';
}
