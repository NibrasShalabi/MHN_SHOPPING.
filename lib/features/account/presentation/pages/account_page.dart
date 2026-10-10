import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_bottom_sheet.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/surface_card.dart';
import '../cubits/account_cubit.dart';
import '../cubits/account_state.dart';
import '../widgets/change_password_form.dart';
import '../widgets/profile_form.dart';

/// "حسابي": the customer's details, password, and sign-out.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final failure = await context.read<AccountCubit>().signOut();
    if (!context.mounted) return;
    if (failure != null) return AppSnackbar.error(context, failure.message);
    context.go(RouteNames.login);
  }

  void _changePassword(BuildContext context) => showCustomBottomSheet(
        context,
        title: AppStrings.changePassword,
        child: BlocProvider.value(value: context.read<AccountCubit>(), child: const ChangePasswordForm()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        bottom: const AppBarBottomBorder(),
        title: Text(AppStrings.myAccount, style: AppTextStyles.heading2),
      ),
      body: BlocBuilder<AccountCubit, AccountState>(
        buildWhen: (a, b) => a.status != b.status || a.profile != b.profile,
        builder: (context, state) => switch (state.status) {
          AccountStatus.loading => const CustomLoadingIndicator(),
          AccountStatus.error =>
            ErrorRetry(failure: state.failure, onRetry: () => context.read<AccountCubit>().load(refresh: true)),
          AccountStatus.ready => ListView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                _Header(name: state.profile.displayName, email: state.profile.email),
                const SizedBox(height: AppConstants.spacingLg),
                ProfileForm(profile: state.profile),
                const SizedBox(height: AppConstants.spacingLg),
                CustomButton(
                  label: AppStrings.changePassword,
                  icon: Icons.lock_outline,
                  isOutlined: true,
                  width: double.infinity,
                  onPressed: () => _changePassword(context),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                CustomButton(
                  label: AppStrings.logout,
                  icon: Icons.logout,
                  color: AppColors.error,
                  width: double.infinity,
                  onPressed: () => _signOut(context),
                ),
              ],
            ),
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String email;

  const _Header({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      gradient: AppColors.emberDarkGradient,
      borderColor: AppColors.gold,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.surfaceDark,
            child: Text(name.isEmpty ? '?' : name.characters.first,
                style: AppTextStyles.heading2.copyWith(color: AppColors.goldLight)),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.heading2.copyWith(color: AppColors.textOnPrimary)),
                const SizedBox(height: AppConstants.spacingXs),
                Text(email, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
