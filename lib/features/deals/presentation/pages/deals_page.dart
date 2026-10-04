import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../cubits/deals_cubit.dart';
import '../cubits/deals_state.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DealsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              AppStrings.dealsTitle,
              style: AppTextStyles.heading2.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
      body: BlocBuilder<DealsCubit, DealsState>(
        builder: (context, state) {
          if (state.status == DealsStatus.loading ||
              state.status == DealsStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(AppStrings.dealsEmpty, style: AppTextStyles.heading2),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    AppStrings.dealsEmptySub,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: state.items.length,
            itemBuilder: (context, index) => _DealTile(
              item: state.items[index],
              onTap: () => context.push(
                RouteNames.productPath(state.items[index].product.id),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DealTile extends StatelessWidget {
  final DealItem item;
  final VoidCallback onTap;

  const _DealTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discountedPrice = item.promotion.getDiscountedPrice(item.product.price);
    final savings = item.product.price - discountedPrice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.error.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            // صورة المنتج
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(AppConstants.radiusMd),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.surfaceDark,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textDisabled,
                      ),
                    ),
                    Positioned(
                      top: AppConstants.spacingXs,
                      right: AppConstants.spacingXs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          '${item.promotion.discountPercentage.toStringAsFixed(0)}%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // معلومات المنتج
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: AppTextStyles.body.copyWith(color: AppColors.gold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '\$${discountedPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.heading2.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      '${AppStrings.dealsSaving} \$${savings.toStringAsFixed(2)}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.success),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    _CountdownTimer(
                      endTime: item.promotion.endTime,
                      onExpired: () => context.read<DealsCubit>().load(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback? onExpired;
  const _CountdownTimer({required this.endTime, this.onExpired});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _remaining = widget.endTime.isAfter(now)
          ? widget.endTime.difference(now)
          : Duration.zero;
    });
    if (_remaining > Duration.zero) {
      Future.delayed(const Duration(seconds: 1), _tick);
    } else {
      widget.onExpired?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        const Icon(Icons.timer_outlined, color: AppColors.error, size: 14),
        const SizedBox(width: 4),
        Text(
          '$h:$m:$s',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}