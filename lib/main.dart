import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'features/cart/data/repositories/cart_repository.dart';
import 'features/cart/presentation/cubits/cart_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Arabic date formatting data — loaded once, before anything renders.
  await initializeDateFormatting('ar');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The cart lives above the router: the nav-bar badge, the product page
    // and the cart screen all read the same instance, so they can never
    // disagree about what's in the cart.
    // TODO(logic-phase): resolve the repository through get_it instead.
    return BlocProvider(
      create: (_) => CartCubit(FakeCartRepository())..load(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

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
      // The app is Arabic-only (no flutter_localizations/.arb — see
      // AppStrings), so RTL is forced here rather than derived from a
      // Locale. It has to go through `builder`, not around MaterialApp:
      // MaterialApp inserts its own Directionality internally, which would
      // override anything wrapped outside it.
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: buildAppRouter(session: FakeUserSessionGate()),
    );
  }
}