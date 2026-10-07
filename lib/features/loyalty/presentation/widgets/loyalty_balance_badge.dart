import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom/loyalty_points_badge.dart';
import '../cubits/loyalty_balance_cubit.dart';

/// The points pill wired to the live balance — home app bar and loyalty store.
class LoyaltyBalanceBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const LoyaltyBalanceBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => BlocBuilder<LoyaltyBalanceCubit, int>(
        builder: (context, points) => LoyaltyPointsBadge(points: points, onTap: onTap),
      );
}
