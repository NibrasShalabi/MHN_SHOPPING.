import 'package:equatable/equatable.dart';

/// A message from the admin: a delay notice, an apology for a cancelled
/// order, or a broadcast to everyone affected by an issue.
///
/// Every message is dismissed on tap — the inbox is for things that need
/// the user's attention right now, not an archive. Once acknowledged it
/// leaves the list for good.
class AdminMessage extends Equatable {
  final String id;
  final String body;
  final DateTime sentAt;
  final String? relatedOrderId;

  const AdminMessage({
    required this.id,
    required this.body,
    required this.sentAt,
    this.relatedOrderId,
  });

  @override
  List<Object?> get props => [id, body, sentAt, relatedOrderId];
}