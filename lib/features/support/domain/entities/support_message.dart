import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_strings.dart';

/// What the user is writing about.
///
/// Complaints, suggestions and bugs all land in the same inbox and need
/// the same fields — the type is what lets the admin triage them, which is
/// cheaper than three screens that collect identical information.
enum SupportTopic { complaint, suggestion, bug, other }

extension SupportTopicLabel on SupportTopic {
  String get label => switch (this) {
    SupportTopic.complaint => AppStrings.supportTypeComplaint,
    SupportTopic.suggestion => AppStrings.supportTypeSuggestion,
    SupportTopic.bug => AppStrings.supportTypeBug,
    SupportTopic.other => AppStrings.supportTypeOther,
  };
}

class SupportMessage extends Equatable {
  final SupportTopic topic;
  final String body;

  const SupportMessage({required this.topic, required this.body});

  @override
  List<Object?> get props => [topic, body];
}