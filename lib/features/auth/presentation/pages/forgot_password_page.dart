import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../cubits/forgot_password_cubit.dart';
import '../cubits/forgot_password_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final emailError = Validators.email(_emailController.text);
    setState(() => _emailError = emailError);
    if (emailError != null) return;

    context.read<ForgotPasswordCubit>().sendResetEmail(_emailController.text.trim());
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
        child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state.status == ForgotPasswordStatus.failure && state.failure != null) {
              AppSnackbar.error(context, state.failure!.message);
            }
          },
          builder: (context, state) {
            final isSubmitting = state.status == ForgotPasswordStatus.submitting;
            final isSuccess = state.status == ForgotPasswordStatus.success;

            if (isSuccess) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mark_email_read_outlined, size: AppConstants.iconXl, color: AppColors.primary),
                    const SizedBox(height: AppConstants.spacingLg),
                    Text(AppStrings.checkYourEmail, style: AppTextStyles.heading2, textAlign: TextAlign.center),
                    const SizedBox(height: AppConstants.spacingSm),
                    Text(
                      '${AppStrings.resetLinkSentTo} ${_emailController.text.trim()}',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    CustomButton(label: AppStrings.backToLogin, onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.resetPasswordTitle, style: AppTextStyles.heading2, textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    AppStrings.resetPasswordSubtitle,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    errorText: _emailError,
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  CustomButton(
                    label: AppStrings.sendResetLink,
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