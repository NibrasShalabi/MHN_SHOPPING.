import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../orders/domain/entities/admin_message.dart';

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