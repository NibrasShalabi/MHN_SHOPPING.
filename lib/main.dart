import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'core/injection/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/theme/app_colors.dart';
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

  final session = FirebaseUserSessionGate();
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
  @override
  void initState() {
    super.initState();
    widget.session.loadGender();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        widget.session.loadGender();
      } else {
        widget.session.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
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
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: buildAppRouter(session: widget.session),
    );
  }
}