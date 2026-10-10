import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/pulsing_dot.dart';
import '../../data/repositories/live_promotions.dart';
import '../cubits/deals_pulse_cubit.dart';
import 'fire_flame.dart';
import 'fire_sparks.dart';

/// Home entry to fire deals. While deals are live the flame breathes and
/// embers rise; a "جديد" pill appears when a deal started after the
/// customer last opened the section. Uses the app's single live-deals
/// listener — no extra reads.
class FireDealsBanner extends StatelessWidget {
  final VoidCallback onTap;

  const FireDealsBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DealsPulseCubit(GetIt.instance<LivePromotions>()),
      child: BlocBuilder<DealsPulseCubit, DealsPulse>(
        builder: (context, pulse) => _Banner(
          pulse: pulse,
          onTap: () {
            context.read<DealsPulseCubit>().markSeen();
            onTap();
          },
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final DealsPulse pulse;
  final VoidCallback onTap;

  const _Banner({required this.pulse, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radiusLg);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppColors.fireGradient,
                borderRadius: radius,
                border: Border.all(color: AppColors.gold, width: AppConstants.borderThick),
                boxShadow: [
                  if (pulse.isLive)
                    BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  children: [
                    Positioned.fill(child: FireSparks(active: pulse.isLive)),
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      child: Row(
                        children: [
                          FireFlame(live: pulse.isLive),
                          const SizedBox(width: AppConstants.spacingMd),
                          Expanded(child: _Texts(pulse: pulse)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (pulse.hasNew)
          const PositionedDirectional(
            top: -AppConstants.spacingSm,
            end: AppConstants.spacingMd,
            child: PulsingDot(label: AppStrings.dealsNewBadge),
          ),
      ],
    );
  }
}

class _Texts extends StatelessWidget {
  final DealsPulse pulse;

  const _Texts({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dealsTitle,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textHeading,
            fontFamily: 'ArefRuqaa',
            fontWeight: FontWeight.bold,
            fontSize: (AppTextStyles.heading2.fontSize ?? 18) + 4,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          pulse.isLive ? AppStrings.dealsCount(pulse.count) : AppStrings.dealsSubtitle,
          style: AppTextStyles.caption.copyWith(
            color: pulse.isLive ? AppColors.goldLight : AppColors.accentLight,
            fontWeight: pulse.isLive ? FontWeight.bold : null,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.dealsButton, style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary)),
            const SizedBox(width: AppConstants.spacingXs),
            const Icon(Icons.chevron_left, size: AppConstants.iconSm, color: AppColors.goldLight),
          ],
        ),
      ],
    );
  }
}
