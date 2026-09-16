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
import '../widgets/app_bar_bottom_border.dart';
import '../widgets/custom/app_logo.dart';
import '../widgets/app_drawer.dart';

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
    _NavTab(path: RouteNames.home, icon: Icons.home_outlined, ),
    _NavTab(path: RouteNames.cart, icon: Icons.shopping_cart_outlined, ),
    _NavTab(path: RouteNames.orderTracking, icon: Icons.local_shipping_outlined, ),
    _NavTab(path: RouteNames.loyaltyStore, icon: Icons.star_outline, ),
    _NavTab(path: RouteNames.suggestProduct, icon: Icons.add_shopping_cart_outlined, ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((tab) => tab.path == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final isWeb = AppConstants.isWideScreen(context);

    if (isWeb) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        // Only HomePage's AppBar had the menu button before; now that
        // every tab's own AppBar disappears on web, the drawer moves up
        // to the shell so it stays reachable from any tab, not just home.
        endDrawer: const AppDrawer(),
        body: Column(
          children: [
            _TopNavBar(tabs: _tabs, currentIndex: currentIndex),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppConstants.webContentMaxWidth),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.surfaceWine),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBarBottomBorder(),
            SafeArea(
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
          ],
        ),
      ),
    );
  }
}

/// Top nav bar for wide screens — same [_NavTab] list as the mobile bottom
/// bar, laid out as a horizontal row instead of five stacked columns.
class _TopNavBar extends StatelessWidget {
  final List<_NavTab> tabs;
  final int currentIndex;

  const _TopNavBar({required this.tabs, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceWine,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: [
                  const AppLogo(),
                  const SizedBox(width: AppConstants.spacingXl),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(tabs.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMd,
                          ),
                          child: _TopNavItem(
                            tab: tabs[index],
                            isActive: index == currentIndex,
                            onTap: () => context.go(tabs[index].path),
                          ),
                        );
                      }),
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.iconPrimary),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),
            ),
            const AppBarBottomBorder(),
          ],
        ),
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _TopNavItem({required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSm,
          vertical: AppConstants.spacingSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tab.path == RouteNames.cart
                ? const _CartIcon()
                : Icon(tab.icon, size: AppConstants.iconMd, color: AppColors.iconPrimary),
            const SizedBox(width: AppConstants.spacingXs),
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData icon;

  const _NavTab({required this.path, required this.icon,});
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                    ? const _CartIcon()
                    : Icon(tab.icon, size: AppConstants.iconMd, color: AppColors.iconPrimary),
              ),
              const SizedBox(height: AppConstants.spacingXs),
            ],
          ),
        ),
      ),
    );
  }
}


/// Cart icon with a live item-count badge.
class _CartIcon extends StatelessWidget {
  const _CartIcon();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) => previous.totalCount != current.totalCount,
      builder: (context, state) {
        final count = state.totalCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: AppConstants.iconMd,
              color: AppColors.iconPrimary,
            ),
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
