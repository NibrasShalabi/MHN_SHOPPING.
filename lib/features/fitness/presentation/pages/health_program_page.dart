import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/surface_card.dart';
import '../cubits/health_program_cubit.dart';
import '../cubits/health_program_state.dart';
import '../widgets/dynamic_form_field_widget.dart';
import '../widgets/medical_notice_card.dart';

/// One screen for every supervised program.
///
/// Body management, yoga, pilates and nutrition differ only in copy,
/// fields and which coach they reach — so they share this page and are
/// distinguished by the program id in the route. A fifth program is a data
/// entry, not a new screen.
class HealthProgramPage extends StatefulWidget {
  const HealthProgramPage({super.key});

  @override
  State<HealthProgramPage> createState() => _HealthProgramPageState();
}

class _HealthProgramPageState extends State<HealthProgramPage> {
  @override
  void initState() {
    super.initState();
    context.read<HealthProgramCubit>().load();
  }

  Future<void> _openWhatsapp(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
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
        title: BlocBuilder<HealthProgramCubit, HealthProgramState>(
          buildWhen: (previous, current) => previous.program != current.program,
          builder: (context, state) =>
              Text(state.program?.title ?? '', style: AppTextStyles.heading2),
        ),
      ),
      body: BlocConsumer<HealthProgramCubit, HealthProgramState>(
        listenWhen: (previous, current) =>
        previous.status != current.status || previous.failure != current.failure,
        listener: (context, state) {
          if (state.failure != null) {
            AppSnackbar.error(context, state.failure!.message);
          }
        },
        builder: (context, state) {
          if (state.status == HealthProgramStatus.loading ||
              state.status == HealthProgramStatus.initial) {
            return const CustomLoadingIndicator();
          }

          final program = state.program;
          if (program == null) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          // After submitting, the form is replaced rather than kept around
          // — resubmitting the same health data serves no purpose, and the
          // next step is contacting the coach.
          if (state.status == HealthProgramStatus.submitted) {
            return _SubmittedView(
              onContactCoach: () => _openWhatsapp(program.coachWhatsappUrl),
            );
          }

          final isSubmitting = state.status == HealthProgramStatus.submitting;

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              SurfaceCard(
                child: Text(
                  program.intro,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              const MedicalNoticeCard(message: AppStrings.healthDataNotice),
              const SizedBox(height: AppConstants.spacingXl),

              ...program.fields.map(
                    (field) => DynamicFormFieldWidget(
                  key: ValueKey(field.id),
                  field: field,
                  value: state.answers[field.id],
                  error: state.errors[field.id],
                  enabled: !isSubmitting,
                  onChanged: (value) =>
                      context.read<HealthProgramCubit>().updateAnswer(field.id, value),
                ),
              ),

              const SizedBox(height: AppConstants.spacingMd),
              CustomButton(
                label: AppStrings.programSubmit,
                icon: Icons.send_outlined,
                width: double.infinity,
                isLoading: isSubmitting,
                onPressed: () => context.read<HealthProgramCubit>().submit(),
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],
          );
        },
      ),
    );
  }
}

class _SubmittedView extends StatelessWidget {
  final VoidCallback onContactCoach;

  const _SubmittedView({required this.onContactCoach});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                gradient: AppColors.emberGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
              ),
              child: const Icon(
                Icons.check,
                size: AppConstants.iconLg,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              AppStrings.programSubmitted,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              AppStrings.contactCoachBody,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            CustomButton(
              label: AppStrings.contactCoachTitle,
              icon: Icons.chat_outlined,
              width: double.infinity,
              onPressed: onContactCoach,
            ),
          ],
        ),
      ),
    );
  }
}