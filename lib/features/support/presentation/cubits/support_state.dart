import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/support_message.dart';

enum SupportStatus { ready, submitting, sent, failure }

class SupportState extends Equatable {
  final SupportStatus status;
  final SupportTopic topic;
  final String body;
  final String? bodyError;
  final Failure? failure;

  const SupportState({
    this.status = SupportStatus.ready,
    this.topic = SupportTopic.complaint,
    this.body = '',
    this.bodyError,
    this.failure,
  });

  SupportState copyWith({
    SupportStatus? status,
    SupportTopic? topic,
    String? body,
    String? bodyError,
    bool clearBodyError = false,
    Failure? failure,
  }) {
    return SupportState(
      status: status ?? this.status,
      topic: topic ?? this.topic,
      body: body ?? this.body,
      bodyError: clearBodyError ? null : (bodyError ?? this.bodyError),
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, topic, body, bodyError, failure];
}