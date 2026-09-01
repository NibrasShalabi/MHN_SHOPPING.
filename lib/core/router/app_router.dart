import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/presentation/pages/about_page.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/login_cubit.dart';
import '../../features/auth/presentation/cubits/signup_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/cart/data/repositories/shared_cart_repository.dart';
import '../../features/cart/presentation/cubits/cart_cubit.dart';
import '../../features/cart/presentation/cubits/shared_cart_cubit.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/shared_cart_page.dart';
import '../../features/fitness/data/repository/fitness_repository.dart';
import '../../features/fitness/presentation/cubits/catalog_categories_cubit.dart';
import '../../features/fitness/presentation/cubits/fitness_hub_cubit.dart';
import '../../features/fitness/presentation/cubits/health_program_cubit.dart';
import '../../features/fitness/presentation/pages/fitness_hub_page.dart';
import '../../features/fitness/presentation/pages/health_program_page.dart';
import '../../features/fitness/presentation/pages/supplements_page.dart';
import '../../features/home/data/repository/catalog_cache.dart';
import '../../features/home/data/repository/catalog_repository.dart';
import '../../features/home/domain/entities/category.dart';
import '../../features/home/presentation/cubits/category_cubit.dart';
import '../../features/home/presentation/cubits/home_cubit.dart';
import '../../features/home/presentation/cubits/product_details_cubit.dart';
import '../../features/home/presentation/pages/category_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/product_details_page.dart';
import '../../features/home/presentation/widgets/loyalty_store_page.dart';
import '../../features/orders/data/repositories/orders_repository.dart';
import '../../features/orders/presentation/cubits/orders_cubit.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/suggest_product/data/repositories/suggest_product_repository.dart';
import '../../features/suggest_product/presentation/cubits/suggest_product_cubit.dart';
import '../../features/suggest_product/presentation/pages/suggest_product_page.dart';
import '../../features/support/data/repositories/support_repository.dart';
import '../../features/support/presentation/cubits/rate_app_cubit.dart';
import '../../features/support/presentation/cubits/support_cubit.dart';
import '../../features/support/presentation/pages/rate_app_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../services/seen_products_store.dart';
import 'main_shell.dart';
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

/// Everything under /fitness is female-only.
///
/// Matching on the prefix rather than listing each route means a program
/// added later is covered automatically — a list would have to be kept in
/// sync, and the failure mode of forgetting is an unguarded health screen.
///
/// NOTE: this redirect is UX only. The real boundary is the Firestore rule
/// and Cloud Function check on the fitness collections, which re-verify
/// gender on every read and write. A client that bypasses the router still
/// gets nothing.
const String _fitnessPathPrefix = RouteNames.fitnessHome;

GoRouter buildAppRouter({required UserSessionGate session}) {
  // One cache instance shared by every screen — that's the whole point:
  // reopening a category or flipping back to a filter costs zero reads.
  final CatalogCache catalogCache = CatalogCache();

  // TODO(logic-phase): resolve all of these through get_it instead of
  // constructing them here.
  final CatalogRepository catalogRepository = FakeCatalogRepository(catalogCache);
  final AuthRepository authRepository = FakeAuthRepository();
  final OrdersRepository ordersRepository = FakeOrdersRepository();
  final FitnessRepository fitnessRepository = FakeFitnessRepository();
  final SupportRepository supportRepository = FakeSupportRepository();
  final SharedCartRepository sharedCartRepository = FakeSharedCartRepository();

  // TODO(logic-phase): swap for a SharedPreferences-backed implementation
  // so seen-state survives app restarts.
  final SeenProductsStore seenProductsStore = InMemorySeenProductsStore();

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

      if (path.startsWith(_fitnessPathPrefix) && !session.isFemale) {
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

      // Bottom-nav tabs.
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => BlocProvider(
              create: (_) => HomeCubit(catalogRepository),
              child: HomePage(showFitnessSection: session.isFemale),
            ),
          ),
          GoRoute(
            path: RouteNames.cart,
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: RouteNames.orderTracking,
            builder: (context, state) => BlocProvider(
              create: (_) => OrdersCubit(ordersRepository),
              child: const OrdersPage(),
            ),
          ),
          GoRoute(
            path: RouteNames.about,
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: RouteNames.suggestProduct,
            builder: (context, state) => BlocProvider(
              create: (_) => SuggestProductCubit(FakeSuggestProductRepository()),
              child: const SuggestProductPage(),
            ),
          ),

        ],
      ),

      // Catalog.
      GoRoute(
        path: RouteNames.category,
        builder: (context, state) => BlocProvider(
          create: (_) => CategoryCubit(
            catalogRepository,
            categoryId: state.pathParameters['categoryId']!,
          ),
          child: CategoryPage(seenProductsStore: seenProductsStore),
        ),
      ),
      GoRoute(
        path: RouteNames.productDetails,
        builder: (context, state) => BlocProvider(
          create: (_) => ProductDetailsCubit(
            catalogRepository,
            productId: state.pathParameters['productId']!,
          ),
          child: const ProductDetailsPage(),
        ),
      ),

      // Orders.
      GoRoute(
        path: RouteNames.orderDetails,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Order: ${state.pathParameters['orderId']}',
        ),
      ),

      // Loyalty.
      GoRoute(
        path: RouteNames.loyaltyStore,
        builder: (context, state) => BlocProvider(
          // Runs on CategoryCubit like any other category — the loyalty
          // shelf is one category whose products are priced in points.
          create: (_) => CategoryCubit(catalogRepository, categoryId: 'loyalty'),
          child: const LoyaltyStorePage(),
        ),
      ),

      // Fitness — female-only, guarded by the redirect above.
      GoRoute(
        path: RouteNames.fitnessHome,
        builder: (context, state) => BlocProvider(
          create: (_) => FitnessHubCubit(fitnessRepository),
          child: const FitnessHubPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.healthProgram,
        builder: (context, state) => BlocProvider(
          create: (_) => HealthProgramCubit(
            fitnessRepository,
            programId: state.pathParameters['programId']!,
          ),
          child: const HealthProgramPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.supplements,
        builder: (context, state) => BlocProvider(
          create: (_) => CatalogCategoriesCubit(
            catalogRepository,
            scope: CatalogScope.fitness,
          ),
          child: const SupplementsPage(),
        ),
      ),

      // Reached from the drawer, not the bottom bar.
      GoRoute(
        path: RouteNames.support,
        builder: (context, state) => BlocProvider(
          create: (_) => SupportCubit(supportRepository),
          child: const SupportPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.rateApp,
        builder: (context, state) => BlocProvider(
          create: (_) => RateAppCubit(supportRepository),
          child: const RateAppPage(),
        ),
      ),

      // Notifications.
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const _PlaceholderScreen(title: 'Notifications'),
      ),
      GoRoute(
        path: RouteNames.sharedCart,
        builder: (context, state) => BlocProvider(
          create: (_) => SharedCartCubit(
            sharedCartRepository,
            cartCubit: context.read<CartCubit>(),
            cartId: state.pathParameters['cartId']!,
          ),
          child: const SharedCartPage(),
        ),
      ),
    ],
  );
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