import 'package:equatable/equatable.dart';

import 'dynamic_form_field.dart';

/// A supervised program inside the fitness section — body management,
/// yoga, pilates, nutrition.
///
/// They differ only in copy, fields and which coach they route to, so they
/// share one entity and one screen instead of four near-identical pages.
class HealthProgram extends Equatable {
  final String id;
  final String title;
  final String intro;
  final List<DynamicFormField> fields;

  /// Coach contact for this program, set by the admin. Kept per program
  /// because yoga and nutrition go to different specialists.
  final String coachWhatsappUrl;

  /// Options the user is shown after submitting (e.g. Pilates / Yoga from
  /// body management). Empty when the program has no follow-on.
  final List<String> suggestedPrograms;

  const HealthProgram({
    required this.id,
    required this.title,
    required this.intro,
    required this.fields,
    required this.coachWhatsappUrl,
    this.suggestedPrograms = const [],
  });

  @override
  List<Object?> get props => [id, title, intro, fields, coachWhatsappUrl, suggestedPrograms];
}