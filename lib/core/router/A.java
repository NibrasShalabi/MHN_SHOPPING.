import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/signup_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import 'route_names.dart';

// TODO(logic-phase): replace with the real AuthCubit/UserRepository lookup.
// This is the UI-phase placeholder — swap the implementation only, keep
// the same interface so nothing else in this file needs to change.
abstract class UserSessionGate {
  bool get isLoggedIn;
  bool get isFemale;
}

class FakeUserSessionGate implements UserSessionGate {
  @override
  bool get isLoggedIn => true;

  @override
  bool get isFemale => true;
}

/// NOTE: This redirect is a UX convenience layer only — it stops a female-
/// only screen from ever being pushed in the UI. It is NOT the security
/// boundary. The real boundary is the Firestore Security Rule + Cloud
/// Function check on `fitnessProfiles/{uid}` (see the security model —
/// gender is re-verified server-side on every read/write regardless of
/// what this guard allows through).
final List<String> _fitnessOnlyPaths = [
  RouteNames.fitnessHome,
  RouteNames.bodyManagement,
  RouteNames.yoga,
  RouteNames.pilates,
  RouteNames.nutrition,
  RouteNames.weightLossMeds,
];

GoRouter buildAppRouter({required UserSessionGate session}) {
  // TODO(logic-phase): replace with get_it lookup (getIt<AuthRepository>())
  // once the service locator is wired — a single shared instance either way.
  final AuthRepository authRepository = FakeAuthRepository();

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final path = state.matchedLocation;

      final isAuthRoute = path == RouteNames.login ||
          path == RouteNames.signup ||
          path == RouteNames.forgotPassword ||
          path == RouteNames.splash;

      if (!session.isLoggedIn && !isAuthRoute) {
        return RouteNames.login;
      }

      final isFitnessPath =
          _fitnessOnlyPaths.any((p) => path.startsWith(p.split('/:').first));
      if (isFitnessPath && !session.isFemale) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => BlocProvider(
          create: (_) => LoginCubit(authRepository),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => BlocProvider(
          create: (_) => SignupCubit(authRepository),
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => ForgotPasswordCubit(authRepository),
          child: const ForgotPasswordPage(),
        ),
      ),

      // Main shell — bottom nav tabs
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
          ),
          GoRoute(
            path: RouteNames.cart,
            builder: (context, state) => const _PlaceholderScreen(title: 'Cart'),
          ),
          GoRoute(
            path: RouteNames.orderTracking,
            builder: (context, state) => const _PlaceholderScreen(title: 'Order tracking'),
          ),
          GoRoute(
            path: RouteNames.about,
            builder: (context, state) => const _PlaceholderScreen(title: 'About us'),
          ),
          GoRoute(
            path: RouteNames.support,
            builder: (context, state) => const _PlaceholderScreen(title: 'Support / Feedback'),
          ),
        ],
      ),

      // Catalog
      GoRoute(
        path: RouteNames.category,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Category: ${state.pathParameters['categoryId']}',
        ),
      ),
      GoRoute(
        path: RouteNames.productDetails,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Product: ${state.pathParameters['productId']}',
        ),
      ),

      // Checkout / Orders
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const _PlaceholderScreen(title: 'Checkout'),
      ),
      GoRoute(
        path: RouteNames.orderDetails,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Order: ${state.pathParameters['orderId']}',
        ),
      ),

      // Loyalty
      GoRoute(
        path: RouteNames.loyaltyStore,
        builder: (context, state) => const _PlaceholderScreen(title: 'Loyalty store'),
      ),

      // Fitness (guarded above)
      GoRoute(
        path: RouteNames.fitnessHome,
        builder: (context, state) => const _PlaceholderScreen(title: 'Fitness'),
      ),
      GoRoute(
        path: RouteNames.bodyManagement,
        builder: (context, state) => const _PlaceholderScreen(title: 'Body management'),
      ),
      GoRoute(
        path: RouteNames.yoga,
        builder: (context, state) => const _PlaceholderScreen(title: 'Yoga'),
      ),
      GoRoute(
        path: RouteNames.pilates,
        builder: (context, state) => const _PlaceholderScreen(title: 'Pilates'),
      ),
      GoRoute(
        path: RouteNames.nutrition,
        builder: (context, state) => const _PlaceholderScreen(title: 'Nutrition'),
      ),
      GoRoute(
        path: RouteNames.weightLossMeds,
        builder: (context, state) => const _PlaceholderScreen(title: 'Weight loss meds'),
      ),

      // Suggest product
      GoRoute(
        path: RouteNames.suggestProduct,
        builder: (context, state) => const _PlaceholderScreen(title: 'Suggest a product'),
      ),

      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const _PlaceholderScreen(title: 'Notifications'),
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    // TODO(ui-phase): replace with the real BottomNavigationBar widget.
    return Scaffold(body: child);
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}