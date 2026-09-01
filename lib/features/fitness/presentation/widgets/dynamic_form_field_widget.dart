import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_dropdown.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../../domain/entities/dynamic_form_field.dart';

/// Renders one admin-defined field.
///
/// The switch over [FormFieldType] is exhaustive on purpose: adding a new
/// type to the enum makes this fail to compile until it's handled, rather
/// than silently rendering nothing in production.
class DynamicFormFieldWidget extends StatelessWidget {
  final DynamicFormField field;
  final dynamic value;
  final String? error;
  final bool enabled;
  final ValueChanged<dynamic> onChanged;

  const DynamicFormFieldWidget({
    super.key,
    required this.field,
    required this.value,
    required this.error,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(field: field),
          const SizedBox(height: AppConstants.spacingXs),
          _buildInput(),
          if (error != null) _InlineError(message: error!),
        ],
      ),
    );
  }

  Widget _buildInput() {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.multiline:
      case FormFieldType.number:
        return _TextInput(
          field: field,
          value: value as String?,
          hasError: error != null,
          enabled: enabled,
          onChanged: onChanged,
        );

      case FormFieldType.dropdown:
        return CustomDropdown<String>(
          label: field.label,
          value: value as String?,
          items: field.options,
          onChanged: enabled ? onChanged : null,
        );

      case FormFieldType.boolean:
        return _BooleanInput(
          value: value as bool?,
          enabled: enabled,
          onChanged: onChanged,
        );

      case FormFieldType.multiChoice:
        return _MultiChoiceInput(
          options: field.options,
          selected: (value as List<String>?) ?? const [],
          enabled: enabled,
          onChanged: onChanged,
        );
    }
  }
}

class _Label extends StatelessWidget {
  final DynamicFormField field;

  const _Label({required this.field});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            field.label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: AppConstants.spacingXs),
        Text(
          field.isRequired ? '*' : '(${AppStrings.optionalField})',
          style: AppTextStyles.caption.copyWith(
            color: field.isRequired ? AppColors.error : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

/// Text, multiline and number share one input; only the keyboard and line
/// count differ.
class _TextInput extends StatefulWidget {
  final DynamicFormField field;
  final String? value;
  final bool hasError;
  final bool enabled;
  final ValueChanged<dynamic> onChanged;

  const _TextInput({
    required this.field,
    required this.value,
    required this.hasError,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final TextEditingController _controller =
  TextEditingController(text: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      label: widget.field.label,
      hint: widget.field.hint,
      enabled: widget.enabled,
      maxLines: widget.field.type == FormFieldType.multiline ? 3 : 1,
      keyboardType: switch (widget.field.type) {
        FormFieldType.number => TextInputType.number,
        FormFieldType.multiline => TextInputType.multiline,
        _ => TextInputType.text,
      },
      onChanged: widget.onChanged,
    );
  }
}

class _BooleanInput extends StatelessWidget {
  final bool? value;
  final bool enabled;
  final ValueChanged<dynamic> onChanged;

  const _BooleanInput({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Choice(
            label: AppStrings.yes,
            isSelected: value == true,
            enabled: enabled,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _Choice(
            label: AppStrings.no,
            isSelected: value == false,
            enabled: enabled,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _MultiChoiceInput extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final bool enabled;
  final ValueChanged<dynamic> onChanged;

  const _MultiChoiceInput({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return _Choice(
          label: option,
          isSelected: isSelected,
          enabled: enabled,
          onTap: () {
            final next = [...selected];
            isSelected ? next.remove(option) : next.add(option);
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

/// Shared pill used by boolean and multi-choice. Sizes to its text so it
/// grows with the system font instead of clipping.
class _Choice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: AppConstants.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingXs, right: AppConstants.spacingSm),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
    );
  }
}