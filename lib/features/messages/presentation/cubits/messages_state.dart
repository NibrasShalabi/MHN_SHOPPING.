import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_message.dart';

enum MessagesStatus { initial, loading, ready, failure }

class MessagesState extends Equatable {
  final MessagesStatus status;
  final List<AdminMessage> messages;
  final Failure? failure;

  const MessagesState({
    this.status = MessagesStatus.initial,
    this.messages = const [],
    this.failure,
  });

  /// Everything still in the inbox — the menu and the messages entry.
  int get unreadCount => messages.length;

  /// Only order updates addressed to this customer — the orders tab.
  /// Broadcasts never light it: a new account has no orders.
  int get orderUpdates => messages.where((m) => m.type == AdminMessageType.orderUpdate).length;

  MessagesState copyWith({
    MessagesStatus? status,
    List<AdminMessage>? messages,
    Failure? failure,
  }) => MessagesState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, messages, failure];
}