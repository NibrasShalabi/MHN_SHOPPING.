import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/presentation/cubits/cart_cubit.dart';
import '../../features/cart/presentation/cubits/cart_state.dart';
import '../../features/messages/presentation/cubits/messages_cubit.dart';
import '../../features/messages/presentation/cubits/messages_state.dart';
import '../constants/app_constants.dart';
import '../constants/app_durations.dart';
import '../theme/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';
import 'route_names.dart';
import '../widgets/app_bar_bottom_border.dart';
import '../widgets/custom/app_logo.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badged_icon.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const List<_NavTab> _tabs = [
    _NavTab(path: RouteNames.home, icon: Icons.home_outlined, label: AppStrings.home),
    _NavTab(path: RouteNames.cart, icon: Icons.shopping_cart_outlined, label: AppStrings.cart),
    _NavTab(path: RouteNames.orderTracking, icon: Icons.local_shipping_outlined, label: AppStrings.orderTracking),
    _NavTab(path: RouteNames.loyaltyStore, icon: Icons.star_outline, label: AppStrings.loyaltyStore),
    _NavTab(path: RouteNames.account, icon: Icons.person_outline, label: AppStrings.myAccount),
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

    return isWeb ? _buildWeb(context, currentIndex) : _buildMobile(context, currentIndex);
  }

  Widget _buildWeb(BuildContext context, int currentIndex) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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

  Widget _buildMobile(BuildContext context, int currentIndex) {
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
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingSm,
                ),
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

/// Desktop header: logo, the five sections with their names, messages with
/// the unread count, and "المزيد" holding the side-menu links — a site
/// header rather than an app's icon strip.
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
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.webContentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg, vertical: AppConstants.spacingSm),
                  child: Row(
                    children: [
                      const AppLogo(),
                      const SizedBox(width: AppConstants.spacingXl),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppConstants.spacingXs,
                          children: [
                            for (final (i, tab) in tabs.indexed)
                              _TopNavItem(tab: tab, isActive: i == currentIndex, onTap: () => context.go(tab.path)),
                          ],
                        ),
                      ),
                      const _MessagesAction(),
                      const _MoreMenu(),
                    ],
                  ),
                ),
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
    final color = isActive ? AppColors.goldLight : AppColors.textPrimary;
    final icon = switch (tab.path) {
      RouteNames.cart => const _CartIcon(),
      RouteNames.orderTracking => const _OrdersIcon(),
      _ => Icon(tab.icon, size: AppConstants.iconMd, color: isActive ? AppColors.goldLight : AppColors.iconPrimary),
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd, vertical: AppConstants.spacingSm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          color: isActive ? AppColors.ember.withValues(alpha: 0.55) : Colors.transparent,
          border: Border.all(color: isActive ? AppColors.gold : Colors.transparent, width: AppConstants.borderThin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: AppConstants.spacingSm),
            Text(tab.label, style: AppTextStyles.body.copyWith(color: color, fontWeight: isActive ? FontWeight.bold : null)),
          ],
        ),
      ),
    );
  }
}

class _MessagesAction extends StatelessWidget {
  const _MessagesAction();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MessagesCubit, MessagesState, int>(
      selector: (s) => s.unreadCount,
      builder: (context, count) => IconButton(
        tooltip: AppStrings.messagesTitle,
        onPressed: () => context.push(RouteNames.messages),
        icon: BadgedIcon(icon: Icons.inbox_outlined, count: count),
      ),
    );
  }
}

/// The side-menu links as a dropdown — on a desktop they belong in the header.
class _MoreMenu extends StatelessWidget {
  const _MoreMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: AppStrings.more,
      color: AppColors.surfaceElevated,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: const BorderSide(color: AppColors.gold, width: AppConstants.borderThin),
      ),
      onSelected: (path) => context.push(path),
      itemBuilder: (_) => [
        for (final e in AppDrawer.entries)
          if (e.path != RouteNames.messages)
            PopupMenuItem(
              value: e.path,
              child: Row(
                children: [
                  Icon(e.icon, size: AppConstants.iconSm + 2, color: AppColors.iconPrimary),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(e.label, style: AppTextStyles.body),
                ],
              ),
            ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm, vertical: AppConstants.spacingSm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.more, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
            const Icon(Icons.expand_more, color: AppColors.goldLight),
          ],
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
                    : tab.path == RouteNames.orderTracking
                    ? const _OrdersIcon()
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
            const Icon(Icons.shopping_cart_outlined, size: AppConstants.iconMd, color: AppColors.iconPrimary),
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
                  child: Text('$count', style: AppTextStyles.caption.copyWith(color: AppColors.goldDark)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OrdersIcon extends StatelessWidget {
  const _OrdersIcon();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MessagesCubit, MessagesState, int>(
      selector: (s) => s.orderUpdates,
      builder: (context, count) => BadgedIcon(icon: Icons.local_shipping_outlined, count: count),
    );
  }
}
