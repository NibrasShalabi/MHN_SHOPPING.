import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/support_message.dart';
import '../cubits/support_cubit.dart';
import '../cubits/support_state.dart';

/// One inbox for complaints, suggestions and bug reports.
///
/// They were three separate screens in the plan, collecting exactly the
/// same thing. A topic selector does the same job with a third of the UI
/// and gives the admin something to sort by.
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        bottom: const AppBarBottomBorder(),
        title: Text(AppStrings.support, style: AppTextStyles.heading2),
      ),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state.status == SupportStatus.sent) {
            _bodyController.clear();
            AppSnackbar.success(context, AppStrings.supportSent);
          } else if (state.status == SupportStatus.failure && state.failure != null) {
            AppSnackbar.error(context, state.failure!.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SupportCubit>();
          final isSubmitting = state.status == SupportStatus.submitting;

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              const _Hero(),
              const SizedBox(height: AppConstants.spacingXl),

              Text(
                AppStrings.supportTypeLabel,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                children: SupportTopic.values
                    .map(
                      (topic) => _TopicPill(
                    label: topic.label,
                    isSelected: topic == state.topic,
                    enabled: !isSubmitting,
                    onTap: () => cubit.selectTopic(topic),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              CustomTextField(
                controller: _bodyController,
                label: AppStrings.supportMessageLabel,
                hint: AppStrings.supportMessageHint,
                maxLines: 6,
                enabled: !isSubmitting,
                errorText: state.bodyError,
                onChanged: cubit.updateBody,
              ),
              const SizedBox(height: AppConstants.spacingLg),

              CustomButton(
                label: AppStrings.supportSend,
                icon: Icons.send_outlined,
                width: double.infinity,
                isLoading: isSubmitting,
                onPressed: cubit.send,
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: AppConstants.iconLg,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            AppStrings.supportIntro,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textOnPrimary,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _TopicPill({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: enabled ? onTap : null,
      borderColor: isSelected ? AppColors.gold : null,
      gradient: isSelected ? AppColors.emberGradient : null,
      radius: AppConstants.radiusLg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
        ),
      ),
    );
  }
}