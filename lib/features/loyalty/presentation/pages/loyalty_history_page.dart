import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../data/repositories/loyalty_balance_repository.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../widgets/loyalty_balance_badge.dart';

/// Where every point came from and went — ratings, purchases, suggestions, gifts, refunds.
class LoyaltyHistoryPage extends StatefulWidget {
  const LoyaltyHistoryPage({super.key});

  @override
  State<LoyaltyHistoryPage> createState() => _LoyaltyHistoryPageState();
}

class _LoyaltyHistoryPageState extends State<LoyaltyHistoryPage> {
  late Future<List<LoyaltyTransaction>> _history = _load();

  Future<List<LoyaltyTransaction>> _load() => getIt<LoyaltyBalanceRepository>().getHistory();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        bottom: const AppBarBottomBorder(),
        title: Text(AppStrings.pointsHistory, style: AppTextStyles.heading2),
        actions: const [LoyaltyBalanceBadge(), SizedBox(width: AppConstants.spacingSm)],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _history = _load());
          await _history;
        },
        child: FutureBuilder<List<LoyaltyTransaction>>(
          future: _history,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const CustomLoadingIndicator();
            if (snap.hasError) {
              final e = snap.error;
              return _Centered(e is ServerException && e.message.isNotEmpty ? e.message : AppStrings.somethingWentWrong);
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) return const _Centered(AppStrings.noPointsHistory);
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: AppConstants.spacingLg),
              itemBuilder: (_, i) => _HistoryRow(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final LoyaltyTransaction item;

  const _HistoryRow({required this.item});

  static final DateFormat _date = DateFormat('d MMM yyyy · HH:mm', 'ar');

  @override
  Widget build(BuildContext context) {
    final color = item.isGain ? AppColors.success : AppColors.error;
    return Row(
      children: [
        CircleAvatar(
          radius: AppConstants.iconMd / 2 + AppConstants.spacingXs,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(item.isGain ? Icons.add : Icons.remove, color: color, size: AppConstants.iconSm),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.reason, style: AppTextStyles.body),
              const SizedBox(height: 2),
              Text(
                [_date.format(item.createdAt), ?item.orderId].join(' · '),
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Text(
          '${item.isGain ? '+' : ''}${item.points}',
          style: AppTextStyles.heading2.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  final String text;

  const _Centered(this.text);

  // Scrollable so pull-to-refresh still works on an empty or failed list.
  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: AppConstants.spacingXxl * 2),
          Center(child: Text(text, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
        ],
      );
}
