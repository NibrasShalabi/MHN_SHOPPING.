import '../../features/loyalty/presentation/pages/loyalty_history_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/domain/entities/product.dart';
import '../../features/home/domain/entities/product_query.dart';
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
import '../../features/checkout/data/repositories/firebase_checkout_service.dart';
import '../../features/checkout/presentation/cubits/checkout_cubit.dart';
import '../../features/checkout/presentation/pages/order_confirmation_page.dart';
import '../../features/deals/data/repositories/promotion_repository.dart';
import '../../features/deals/presentation/cubits/deals_cubit.dart';
import '../../features/deals/presentation/pages/deals_page.dart';
import '../../features/fitness/data/repository/fitness_repository.dart';
import '../../features/fitness/presentation/cubits/catalog_categories_cubit.dart';
import '../../features/fitness/presentation/cubits/fitness_hub_cubit.dart';
import '../../features/fitness/presentation/cubits/health_program_cubit.dart';
import '../../features/fitness/presentation/pages/fitness_hub_page.dart';
import '../../features/fitness/presentation/pages/health_program_page.dart';
import '../../features/fitness/presentation/pages/supplements_page.dart';
import '../../features/home/data/repository/catalog_repository.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/currency/presentation/pages/currency_page.dart';
import '../../features/home/domain/entities/category.dart';
import '../../features/home/presentation/cubits/category_cubit.dart';
import '../../features/home/presentation/cubits/home_cubit.dart';
import '../../features/home/presentation/cubits/product_details_cubit.dart';
import '../../features/home/presentation/pages/category_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/product_details_page.dart';
import '../../features/home/presentation/widgets/loyalty_store_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
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
import '../../features/suppliers/domain/entities/supplier.dart';
import '../../features/suppliers/presentation/cubits/suppliers_cubit.dart';
import '../../features/suppliers/presentation/pages/supplier_detail_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_list_page.dart';
import '../injection/injection_container.dart';
import '../services/seen_products_store.dart';
import '../widgets/custom/custom_loading_indicator.dart';
import 'main_shell.dart';
import 'route_names.dart';

abstract class UserSessionGate {
  bool get isLoggedIn;
  bool get isFemale;
}

/// Firebase implementation — يقرأ الـ gender من Firestore مرة واحدة
/// ويخزنه في الـ cache لتجنب reads متكررة
class FirebaseUserSessionGate implements UserSessionGate {
  bool? _isFemale;

  @override
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  bool get isFemale => _isFemale ?? false;

  /// يُستدعى بعد login/signup وعند فتح التطبيق
  Future<void> loadGender() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { _isFemale = null; return; }
    try {
      final doc = await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'default',
      ).collection('users').doc(uid).get();
      _isFemale = (doc.data()?['gender'] as String?) == 'female';
    } catch (_) {
      _isFemale = false;
    }
  }

  /// يُستدعى عند logout
  void clear() => _isFemale = null;
}

/// كل ما تحت /fitness للإناث فقط
const String _fitnessPathPrefix = RouteNames.fitnessHome;

GoRouter buildAppRouter({required UserSessionGate session}) {
  final SeenProductsStore seenProductsStore = PrefsSeenProductsStore();

  // ===== Repositories من getIt (Firebase) =====
  final CatalogRepository catalogRepository = getIt<CatalogRepository>();
  final PromotionRepository promotionRepository = getIt<PromotionRepository>();
  final AuthRepository authRepository = getIt<AuthRepository>();
  final OrdersRepository ordersRepository = getIt<OrdersRepository>();

  // ===== Repositories لسا Fake (لاحقاً) =====
  final FitnessRepository fitnessRepository = getIt<FitnessRepository>();
  final SupportRepository supportRepository = getIt<SupportRepository>();
  final SharedCartRepository sharedCartRepository = getIt<SharedCartRepository>();

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final path = state.matchedLocation;

      final isAuthRoute = path == RouteNames.login ||
          path == RouteNames.signup ||
          path == RouteNames.forgotPassword ||
          path == RouteNames.splash;

      if (!session.isLoggedIn && !isAuthRoute) return RouteNames.login;
      if (path.startsWith(_fitnessPathPrefix) && !session.isFemale) return RouteNames.home;

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

      // Bottom-nav tabs
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => BlocProvider(
              create: (_) => HomeCubit(catalogRepository, promotionRepository),
              child: HomePage(showFitnessSection: session.isFemale),
            ),
          ),
          GoRoute(
            path: RouteNames.cart,
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: RouteNames.orderTracking,
            builder: (context, state) => const OrdersPage(),
          ),
          GoRoute(
            path: RouteNames.loyaltyStore,
            builder: (context, state) => BlocProvider(
              create: (_) => CategoryCubit(catalogRepository, query: const ProductQuery.pricing(PricingKind.points)),
              child: const LoyaltyStorePage(),
            ),
          ),
          GoRoute(
            path: RouteNames.suggestProduct,
            builder: (context, state) => BlocProvider(
              create: (_) => SuggestProductCubit(getIt<SuggestProductRepository>()),
              child: const SuggestProductPage(),
            ),
          ),
        ],
      ),

      // Catalog
      GoRoute(
        path: RouteNames.category,
        builder: (context, state) => BlocProvider(
          create: (_) => CategoryCubit(
            catalogRepository,
            query: ProductQuery.category(state.pathParameters['categoryId']!),
          ),
          child: CategoryPage(seenProductsStore: seenProductsStore),
        ),
      ),
      GoRoute(
        path: RouteNames.productDetails,
        builder: (context, state) => BlocProvider(
          create: (_) => ProductDetailsCubit(
            catalogRepository,
            promotionRepository,
            productId: state.pathParameters['productId']!,
          ),
          child: const ProductDetailsPage(),
        ),
      ),

      // Orders
      GoRoute(
        path: RouteNames.orderDetails,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Order: ${state.pathParameters['orderId']}',
        ),
      ),

      // Suppliers
      GoRoute(
        path: RouteNames.suppliers,
        builder: (context, state) => BlocProvider(
          create: (_) => SuppliersCubit(catalogRepository),
          child: const SuppliersListPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.supplierDetails,
        builder: (context, state) {
          final supplierId = state.pathParameters['supplierId']!;
          return FutureBuilder<Supplier>(
            future: catalogRepository.getSupplier(supplierId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(body: CustomLoadingIndicator());
              }
              return BlocProvider(
                create: (_) => CatalogCategoriesCubit(
                  catalogRepository,
                  scope: CatalogScope.supplier,
                  supplierId: supplierId,
                ),
                child: SupplierDetailPage(supplier: snapshot.data!),
              );
            },
          );
        },
      ),

      // Fitness — إناث فقط، محمية بالـ redirect أعلى
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

      // Drawer routes
      GoRoute(
        path: RouteNames.about,
        builder: (context, state) => const AboutPage(),
      ),
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

      // Deals + Checkout + Currency
      GoRoute(
        path: RouteNames.deals,
        builder: (context, state) => BlocProvider(
          create: (_) => DealsCubit(catalogRepository, promotionRepository),
          child: const DealsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => BlocProvider(
          create: (_) => CheckoutCubit(getIt<CheckoutService>()),
          child: const CheckoutPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.orderConfirmation,
        builder: (context, state) => OrderConfirmationPage(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: RouteNames.currency,
        builder: (context, state) => const CurrencyPage(),
      ),
      GoRoute(
        path: RouteNames.loyaltyHistory,
        builder: (context, state) => const LoyaltyHistoryPage(),
      ),
      GoRoute(
        path: RouteNames.messages,
        builder: (context, state) => const MessagesPage(),
      ),
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