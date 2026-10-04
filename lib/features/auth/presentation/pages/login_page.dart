import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../cubits/login_cubit.dart';
import '../cubits/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.required(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) return;

    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              context.go(RouteNames.home);
            } else if (state.status == LoginStatus.failure && state.failure != null) {
              AppSnackbar.error(context, state.failure!.message);
            }
          },
          builder: (context, state) {
            final isSubmitting = state.status == LoginStatus.submitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.spacingXxl),
                  Text(AppStrings.login, style: AppTextStyles.heading1, textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.spacingXxl),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    errorText: _emailError,
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    errorText: _passwordError,
                    enabled: !isSubmitting,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: isSubmitting ? null : () => context.push(RouteNames.forgotPassword),
                      child: Text(AppStrings.forgotPassword, style: AppTextStyles.caption),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomButton(
                    label: AppStrings.login,
                    isLoading: isSubmitting,
                    onPressed: () => _submit(context),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  TextButton(
                    onPressed: isSubmitting ? null : () => context.push(RouteNames.signup),
                    child: Text('${AppStrings.noAccountYet} ${AppStrings.signup}', style: AppTextStyles.body),
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