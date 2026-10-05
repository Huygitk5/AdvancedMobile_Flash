import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// UUID v4 sinh tại client: id của review log, note, quiz attempt, op_id...
/// (client tự sinh id khi offline nên không đụng độ, xem DATA_ARCHITECTURE.md).
String newId() => _uuid.v4();
