import 'package:equatable/equatable.dart';

/// Input kinds a program form can ask for.
///
/// Matches what the admin dashboard is meant to offer when building a
/// form; adding a kind here is the only code change a new field type
/// needs — the renderer switches on it exhaustively.
enum FormFieldType { text, multiline, number, dropdown, boolean, multiChoice }

/// One question in a program form.
///
/// Forms are data, not layout: the admin defines fields, the app renders
/// whatever it's given. That's what keeps "change a form" from meaning
/// "ship a new build".
class DynamicFormField extends Equatable {
  final String id;
  final String label;
  final FormFieldType type;
  final bool isRequired;

  /// Choices for [FormFieldType.dropdown] and [FormFieldType.multiChoice].
  final List<String> options;

  /// Shown inside the input, e.g. a unit or an example.
  final String? hint;

  const DynamicFormField({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = true,
    this.options = const [],
    this.hint,
  });

  @override
  List<Object?> get props => [id, label, type, isRequired, options, hint];
}