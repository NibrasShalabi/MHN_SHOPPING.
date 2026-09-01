import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/model/gender.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/syrian_governorates.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_dropdown.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../../domain/entities/signup_data.dart';
import '../cubits/signup_cubit.dart';
import '../cubits/signup_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fullNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();

  String? _governorate;
  Gender? _gender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String?>{
      'fullName': Validators.required(_fullNameController.text),
      'familyName': Validators.required(_familyNameController.text),
      'email': Validators.email(_emailController.text),
      'password': Validators.password(_passwordController.text),
      'confirmPassword':
      Validators.confirmPassword(_confirmPasswordController.text, _passwordController.text),
      'phone': Validators.phone(_phoneController.text),
      'secondaryPhone': Validators.optionalPhone(_secondaryPhoneController.text),
      'location': Validators.required(_locationController.text),
      'area': Validators.required(_areaController.text),
      'governorate': _governorate == null ? AppStrings.selectGovernorate : null,
      'gender': _gender == null ? AppStrings.selectGender : null,
    };

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });

    return errors.values.every((e) => e == null);
  }

  void _submit(BuildContext context) {
    if (!_validate()) return;

    context.read<SignupCubit>().signup(
      SignupData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        familyName: _familyNameController.text.trim(),
        phone: _phoneController.text.trim(),
        secondaryPhone:
        _secondaryPhoneController.text.trim().isEmpty ? null : _secondaryPhoneController.text.trim(),
        location: _locationController.text.trim(),
        governorate: _governorate!,
        area: _areaController.text.trim(),
        gender: _gender!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state.status == SignupStatus.success) {
              context.go(RouteNames.home);
            } else if (state.status == SignupStatus.failure && state.failure != null) {
              AppSnackbar.error(context, state.failure!.message);
            }
          },
          builder: (context, state) {
            final isSubmitting = state.status == SignupStatus.submitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppStrings.signup, style: AppTextStyles.heading1, textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.spacingXl),

                  CustomTextField(
                    controller: _fullNameController,
                    label: AppStrings.fullName,
                    prefixIcon: Icons.person_outline,
                    errorText: _errors['fullName'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _familyNameController,
                    label: AppStrings.familyName,
                    prefixIcon: Icons.badge_outlined,
                    errorText: _errors['familyName'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    errorText: _errors['email'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    errorText: _errors['password'],
                    enabled: !isSubmitting,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    errorText: _errors['confirmPassword'],
                    enabled: !isSubmitting,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _phoneController,
                    label: AppStrings.phoneNumber,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    errorText: _errors['phone'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _secondaryPhoneController,
                    label: AppStrings.secondaryPhoneNumber,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    errorText: _errors['secondaryPhone'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _locationController,
                    label: AppStrings.location,
                    prefixIcon: Icons.location_on_outlined,
                    errorText: _errors['location'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomDropdown<String>(
                    label: AppStrings.governorate,
                    value: _governorate,
                    items: SyrianGovernorates.all,
                    onChanged: isSubmitting ? null : (value) => setState(() => _governorate = value),
                  ),
                  if (_errors['governorate'] != null) _InlineError(_errors['governorate']!),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _areaController,
                    label: AppStrings.area,
                    prefixIcon: Icons.map_outlined,
                    errorText: _errors['area'],
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomDropdown<Gender>(
                    label: AppStrings.gender,
                    value: _gender,
                    items: Gender.values,
                    itemLabel: (g) => g.label,
                    onChanged: isSubmitting ? null : (value) => setState(() => _gender = value),
                  ),
                  if (_errors['gender'] != null) _InlineError(_errors['gender']!),

                  const SizedBox(height: AppConstants.spacingXl),
                  CustomButton(
                    label: AppStrings.signup,
                    isLoading: isSubmitting,
                    onPressed: () => _submit(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingXs, right: AppConstants.spacingSm),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(message, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
      ),
    );
  }
}