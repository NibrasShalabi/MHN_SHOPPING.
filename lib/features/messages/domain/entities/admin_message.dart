import 'package:equatable/equatable.dart';

enum AdminMessageType {
  supportReply('support_reply'),
  orderUpdate('order_update'),
  broadcast('broadcast');

  final String key;
  const AdminMessageType(this.key);

  static AdminMessageType fromKey(String? key) =>
      values.firstWhere((t) => t.key == key, orElse: () => broadcast);
}

class AdminMessage extends Equatable {
  final String id;
  final String body;
  final DateTime sentAt;
  final String? relatedOrderId;
  final String? title;
  final AdminMessageType type;

  const AdminMessage({
    required this.id,
    required this.body,
    required this.sentAt,
    this.relatedOrderId,
    this.title,
    this.type = AdminMessageType.broadcast,
  });

  bool get isBroadcast => type == AdminMessageType.broadcast;

  @override
  List<Object?> get props => [id, body, sentAt, relatedOrderId, title, type];
}
