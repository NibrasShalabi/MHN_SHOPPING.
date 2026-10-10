import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/syrian_governorates.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_dropdown.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../domain/entities/user_profile.dart';
import '../cubits/account_cubit.dart';

/// Editable details. Email and gender are fixed at sign-up; the rest can
/// change once every [UserProfile.editCooldown].
class ProfileForm extends StatefulWidget {
  final UserProfile profile;

  const ProfileForm({super.key, required this.profile});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final _fullName = TextEditingController(text: widget.profile.fullName);
  late final _familyName = TextEditingController(text: widget.profile.familyName);
  late final _phone = TextEditingController(text: widget.profile.phone);
  late final _secondaryPhone = TextEditingController(text: widget.profile.secondaryPhone);
  late final _area = TextEditingController(text: widget.profile.area);
  late String? _governorate = widget.profile.governorate.isEmpty ? null : widget.profile.governorate;
  Map<String, String?> _errors = const {};

  List<TextEditingController> get _controllers => [_fullName, _familyName, _phone, _secondaryPhone, _area];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final errors = {
      'fullName': Validators.required(_fullName.text),
      'familyName': Validators.required(_familyName.text),
      'phone': Validators.phone(_phone.text),
      'secondaryPhone': Validators.optionalPhone(_secondaryPhone.text),
      'governorate': Validators.required(_governorate),
      'area': Validators.required(_area.text),
    };
    setState(() => _errors = errors);
    if (errors.values.any((e) => e != null)) return;

    final failure = await context.read<AccountCubit>().save(widget.profile.edited(
          fullName: _fullName.text.trim(),
          familyName: _familyName.text.trim(),
          phone: _phone.text.trim(),
          secondaryPhone: _secondaryPhone.text.trim(),
          governorate: _governorate!,
          area: _area.text.trim(),
          at: DateTime.now(),
        ));
    if (!mounted) return;
    failure == null ? AppSnackbar.success(context, AppStrings.profileSaved) : AppSnackbar.error(context, failure.message);
  }

  @override
  Widget build(BuildContext context) {
    final next = widget.profile.nextEditAt(DateTime.now());
    final locked = next != null;
    final busy = context.select((AccountCubit c) => c.state.busy);
    final enabled = !locked && !busy;

    Widget field(String key, TextEditingController c, String label, IconData icon, {TextInputType? type}) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          child: CustomTextField(
            controller: c,
            label: label,
            prefixIcon: icon,
            keyboardType: type,
            errorText: _errors[key],
            enabled: enabled,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.profileDetails, style: AppTextStyles.heading2),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          locked ? AppStrings.profileEditTooSoon(next) : AppStrings.profileEditRule,
          style: AppTextStyles.caption.copyWith(color: locked ? AppColors.warning : AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        field('fullName', _fullName, AppStrings.fullName, Icons.person_outline),
        field('familyName', _familyName, AppStrings.familyName, Icons.badge_outlined),
        field('phone', _phone, AppStrings.phoneNumber, Icons.phone_outlined, type: TextInputType.phone),
        field('secondaryPhone', _secondaryPhone, AppStrings.secondaryPhoneNumber, Icons.phone_outlined,
            type: TextInputType.phone),
        CustomDropdown<String>(
          label: AppStrings.governorate,
          value: _governorate,
          items: SyrianGovernorates.all,
          onChanged: enabled ? (v) => setState(() => _governorate = v) : null,
        ),
        if (_errors['governorate'] case final e?) InlineError(e),
        const SizedBox(height: AppConstants.spacingMd),
        field('area', _area, AppStrings.area, Icons.map_outlined),
        if (!locked)
          CustomButton(
            label: AppStrings.saveChanges,
            icon: Icons.check,
            width: double.infinity,
            isLoading: busy,
            onPressed: _save,
          ),
      ],
    );
  }
}

