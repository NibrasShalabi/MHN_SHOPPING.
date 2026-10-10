import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../cubits/account_cubit.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  Map<String, String?> _errors = const {};

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final errors = {
      'current': Validators.required(_current.text),
      'next': _next.text == _current.text ? AppStrings.samePassword : Validators.password(_next.text),
      'confirm': Validators.confirmPassword(_confirm.text, _next.text),
    };
    setState(() => _errors = errors);
    if (errors.values.any((e) => e != null)) return;

    final failure = await context.read<AccountCubit>().changePassword(_current.text, _next.text);
    if (!mounted) return;
    if (failure != null) return AppSnackbar.error(context, failure.message);
    AppSnackbar.success(context, AppStrings.passwordChanged);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AccountCubit c) => c.state.busy);
    Widget field(String key, TextEditingController c, String label) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          child: CustomTextField(
            controller: c,
            label: label,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            errorText: _errors[key],
            enabled: !busy,
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field('current', _current, AppStrings.currentPassword),
          field('next', _next, AppStrings.newPassword),
          field('confirm', _confirm, AppStrings.confirmNewPassword),
          CustomButton(label: AppStrings.changePassword, isLoading: busy, onPressed: _submit),
        ],
      ),
    );
  }
}
