import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../constants/app_durations.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/cart/presentation/cubits/cart_cubit.dart';
import '../../features/cart/presentation/cubits/cart_state.dart';
import 'route_names.dart';

/// Bottom navigation shell shared by the five main tabs.
///
/// Built by hand rather than with BottomNavigationBar: that widget has a
/// fixed height and clips its labels once the user raises the system text
/// size. Here each item lays out in a Column with no fixed height, so the
/// bar grows vertically instead of overflowing — icon and label both stay
/// readable at any text scale.
/// NOTE: the drawer is NOT declared here. Each tab builds its own
/// Scaffold inside this one, and Scaffold.of() resolves to the nearest
/// ancestor — so a drawer on the shell is invisible to a menu button
/// inside a page. Pages that show the menu declare the drawer themselves.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const List<_NavTab> _tabs = [
    _NavTab(path: RouteNames.home, icon: Icons.home_outlined, label: AppStrings.home),
    _NavTab(path: RouteNames.cart, icon: Icons.shopping_cart_outlined, label: AppStrings.cart),
    _NavTab(path: RouteNames.orderTracking, icon: Icons.local_shipping_outlined, label: AppStrings.orderTracking),
    _NavTab(path: RouteNames.about, icon: Icons.info_outline, label: AppStrings.aboutUs),
    _NavTab(path: RouteNames.suggestProduct, icon: Icons.add_shopping_cart_outlined, label: AppStrings.suggestProduct),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((tab) => tab.path == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWine,
          border: Border(top: BorderSide(color: AppColors.border, width: AppConstants.borderThin)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return Expanded(
                  child: _NavItem(
                    tab: _tabs[index],
                    isActive: index == currentIndex,
                    onTap: () => context.go(_tabs[index].path),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData icon;
  final String label;

  const _NavTab({required this.path, required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.gold : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXs,
            vertical: AppConstants.spacingXs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: AppDurations.fast,
                child: tab.path == RouteNames.cart
                    ? _CartIcon(color: color)
                    : Icon(tab.icon, size: AppConstants.iconMd, color: color),
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                tab.label,
                style: AppTextStyles.caption.copyWith(color: color),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Cart icon with a live item-count badge.
class _CartIcon extends StatelessWidget {
  final Color color;

  const _CartIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) => previous.totalCount != current.totalCount,
      builder: (context, state) {
        final count = state.totalCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.shopping_cart_outlined, size: AppConstants.iconMd, color: color),
            if (count > 0)
              Positioned(
                top: -4,
                left: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.caption.copyWith(color: AppColors.goldDark),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}