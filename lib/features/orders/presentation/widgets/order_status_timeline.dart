import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_durations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_status.dart';

/// Vertical progress rail: completed steps get a filled gold marker, the
/// current one is highlighted, later steps stay muted.
///
/// Cancelled/delayed orders don't sit anywhere on this rail — they're
/// shown as an interruption banner instead, so the timeline never claims
/// progress that isn't happening.
class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatusX.timeline;
    final currentIndex = steps.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isDone = currentIndex >= 0 && index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: AppDurations.normal,
                    width: AppConstants.timelineDotSize,
                    height: AppConstants.timelineDotSize,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.gold : AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone ? AppColors.gold : AppColors.border,
                        width: AppConstants.borderThick,
                      ),
                    ),
                    child: isDone
                        ? Icon(
                      isCurrent ? Icons.circle : Icons.check,
                      size: AppConstants.iconSm - 4,
                      color: AppColors.surfaceDark,
                    )
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: isDone && index < currentIndex
                            ? AppColors.gold
                            : AppColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppConstants.spacingLg,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: AppDurations.fast,
                    style: isCurrent
                        ? AppTextStyles.body.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w500,
                    )
                        : AppTextStyles.body.copyWith(
                      color: isDone
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                    child: Text(steps[index].label),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}