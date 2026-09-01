import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/custom/custom_text_field.dart';
import '../../../../core/widgets/surface_card.dart';
import '../cubits/rate_app_cubit.dart';
import '../cubits/rate_app_state.dart';
import '../widgets/review_carousel.dart';
import '../widgets/star_rating_input.dart';

/// Rating and customer reviews on one screen.
///
/// They belong together: the reviews are what a user reads before deciding
/// to leave one, and rating is a once-per-account action that doesn't fill
/// a screen on its own.
class RateAppPage extends StatefulWidget {
  const RateAppPage({super.key});

  @override
  State<RateAppPage> createState() => _RateAppPageState();
}

class _RateAppPageState extends State<RateAppPage> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RateAppCubit>().load();
  }

  @override
  void dispose() {
    _commentController.dispose();
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
        title: Text(AppStrings.rateApp, style: AppTextStyles.heading2),
      ),
      body: BlocConsumer<RateAppCubit, RateAppState>(
        listener: (context, state) {
          if (state.status == RateAppStatus.submitted) {
            _commentController.clear();
            AppSnackbar.success(context, AppStrings.ratingSubmitted);
          } else if (state.failure != null) {
            AppSnackbar.error(context, state.failure!.message);
          }
        },
        builder: (context, state) {
          if (state.status == RateAppStatus.loading) {
            return const CustomLoadingIndicator();
          }

          final cubit = context.read<RateAppCubit>();
          final isSubmitting = state.status == RateAppStatus.submitting;

          return ListView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            children: [
              // The form disappears once rated — rating is once per
              // account, so leaving an inert form on screen would only
              // invite a tap that can't succeed.
              if (state.hasRated)
                const _AlreadyRatedCard()
              else
                _RatingForm(
                  state: state,
                  controller: _commentController,
                  isSubmitting: isSubmitting,
                  onStars: cubit.setStars,
                  onComment: cubit.updateComment,
                  // TODO(logic-phase): image_picker, then upload to R2 and
                  // pass the resulting URL rather than a local path.
                  onAttach: () => cubit.attachImage(''),
                  onSubmit: cubit.submit,
                ),

              const SizedBox(height: AppConstants.spacingXl),
              Row(
                children: [
                  Container(
                    width: 3,
                    height: AppConstants.spacingLg,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(AppStrings.customerReviews, style: AppTextStyles.heading2),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              ReviewCarousel(reviews: state.reviews),
              const SizedBox(height: AppConstants.spacingLg),
            ],
          );
        },
      ),
    );
  }
}

class _RatingForm extends StatelessWidget {
  final RateAppState state;
  final TextEditingController controller;
  final bool isSubmitting;
  final ValueChanged<int> onStars;
  final ValueChanged<String> onComment;
  final VoidCallback onAttach;
  final VoidCallback onSubmit;

  const _RatingForm({
    required this.state,
    required this.controller,
    required this.isSubmitting,
    required this.onStars,
    required this.onComment,
    required this.onAttach,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.rateAppIntro,
            style: AppTextStyles.heading2.copyWith(color: AppColors.textOnPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            AppStrings.rateAppOnce,
            style: AppTextStyles.caption.copyWith(color: AppColors.accentLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          StarRatingInput(
            value: state.stars,
            enabled: !isSubmitting,
            onChanged: onStars,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          CustomTextField(
            controller: controller,
            label: AppStrings.reviewOptional,
            maxLines: 3,
            enabled: !isSubmitting,
            onChanged: onComment,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          CustomButton(
            label: state.imagePath == null ? AppStrings.addPhoto : AppStrings.addPhoto,
            icon: Icons.photo_camera_outlined,
            isOutlined: true,
            width: double.infinity,
            onPressed: isSubmitting ? null : onAttach,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          CustomButton(
            label: AppStrings.submitRating,
            icon: Icons.send_outlined,
            width: double.infinity,
            isLoading: isSubmitting,
            onPressed: state.canSubmit ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}

class _AlreadyRatedCard extends StatelessWidget {
  const _AlreadyRatedCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      borderColor: AppColors.gold,
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: AppConstants.iconLg,
            color: AppColors.gold,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              AppStrings.alreadyRated,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}