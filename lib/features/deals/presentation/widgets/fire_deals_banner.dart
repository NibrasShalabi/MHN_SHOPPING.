import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/entry_banner.dart';
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
    return EntryBanner(
      onTap: onTap,
      art: FireFlame(live: pulse.isLive, size: 84),
      backdrop: FireSparks(active: pulse.isLive),
      badge: pulse.hasNew ? const PulsingDot(label: AppStrings.dealsNewBadge) : null,
      tagIcon: Icons.local_fire_department_outlined,
      tag: AppStrings.dealsBannerTag,
      title: AppStrings.dealsTitle,
      body: pulse.isLive ? AppStrings.dealsCount(pulse.count) : AppStrings.dealsSubtitle,
      highlightBody: pulse.isLive,
      button: AppStrings.dealsButton,
    );
  }
}
