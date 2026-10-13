import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'core/injection/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/widgets/offline_banner.dart';
import 'features/loyalty/presentation/cubits/loyalty_balance_cubit.dart';
import 'features/messages/presentation/cubits/messages_cubit.dart';
import 'features/account/data/repositories/account_repository.dart';
import 'features/cart/data/repositories/cart_repository.dart';
import 'features/cart/presentation/cubits/cart_cubit.dart';
import 'features/home/data/repository/catalog_repository.dart';
import 'features/orders/data/repositories/orders_repository.dart';
import 'features/orders/presentation/cubits/orders_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService.init();
  await initializeDateFormatting('ar');
  di.setupInjector();

  final session = FirebaseUserSessionGate(GetIt.instance<AccountRepository>());
  runApp(MyApp(session: session));
}

class MyApp extends StatelessWidget {
  final FirebaseUserSessionGate session;
  const MyApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CartCubit(
            GetIt.instance<CartRepository>(),
            GetIt.instance<CatalogRepository>(),
          )..load(),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<MessagesCubit>()..watch(),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<LoyaltyBalanceCubit>()..watch(),
        ),
        BlocProvider(
          create: (_) => OrdersCubit(
            GetIt.instance<OrdersRepository>(),
          )..load(),
        ),
      ],
      child: _AppView(session: session),
    );
  }
}

class _AppView extends StatefulWidget {
  final FirebaseUserSessionGate session;
  const _AppView({required this.session});

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  // Built once: rebuilding it on every frame of this widget reset the
  // navigation stack and every route's providers.
  late final GoRouter _router = buildAppRouter(session: widget.session);

  @override
  void initState() {
    super.initState();
    String? lastUid = FirebaseAuth.instance.currentUser?.uid;
    widget.session.loadGender();

    // A different account must not inherit the previous one's profile or cart.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid == lastUid) return;
      lastUid = user?.uid;
      widget.session.clear();
      if (user != null) widget.session.loadGender();
      if (mounted) context.read<CartCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.gold,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        fontFamily: 'Tajawal',
        // Pull-to-refresh and any stray progress spinner in the brand colours.
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.gold,
          refreshBackgroundColor: AppColors.surfaceElevated,
        ),
      ),
      // The design has fixed-height cards and banners: the phone's font-size
      // setting would push text out of them, so the app keeps its own sizes.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Directionality(
          textDirection: TextDirection.rtl,
          // Android 15 draws apps edge to edge: without this, buttons at
          // the bottom of a page sit under the system navigation bar. One
          // place for every page; screens that already pad themselves see
          // no extra space (the inset is consumed here).
          child: ColoredBox(
            color: AppColors.surface,
            child: SafeArea(
              top: false,
              child: OfflineBanner(child: child ?? const SizedBox.shrink()),
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}