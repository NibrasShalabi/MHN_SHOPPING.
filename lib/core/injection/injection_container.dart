import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/deals/data/repositories/live_promotions.dart';

import '../../features/account/data/repositories/account_repository.dart';
import '../../features/account/data/repositories/firebase_account_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/firebase_auth_repository.dart';
import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/data/repositories/firebase_cart_repository.dart';
import '../../features/cart/data/repositories/firebase_shared_cart_repository.dart';
import '../../features/cart/data/repositories/shared_cart_repository.dart';
import '../../features/checkout/data/repositories/firebase_checkout_service.dart';
import '../../features/deals/data/repositories/currency_converter_repository.dart';
import '../../features/deals/data/repositories/firebase_promotion_repository.dart';
import '../../features/deals/data/repositories/promotion_repository.dart';
import '../../features/fitness/data/repository/firebase_fitness_repository.dart';
import '../../features/fitness/data/repository/fitness_repository.dart';
import '../../features/home/data/repository/firebase_catalog_repository.dart';
import '../../features/home/data/repository/catalog_cache.dart';
import '../../features/home/data/repository/catalog_repository.dart';
import '../../features/loyalty/data/repositories/firebase_loyalty_balance_repository.dart';
import '../../features/loyalty/data/repositories/loyalty_balance_repository.dart';
import '../../features/loyalty/presentation/cubits/loyalty_balance_cubit.dart';
import '../../features/messages/data/repositories/firebase_messages_repository.dart';
import '../../features/messages/data/repositories/messages_repository.dart';
import '../../features/messages/presentation/cubits/messages_cubit.dart';
import '../../features/orders/data/repositories/firebase_orders_repository.dart';
import '../../features/orders/data/repositories/orders_repository.dart';
import '../../features/suggest_product/data/repositories/firebase_suggest_product_repository.dart';
import '../../features/suggest_product/data/repositories/suggest_product_repository.dart';
import '../../features/support/data/repositories/firebase_support_repository.dart';
import '../../features/support/data/repositories/support_repository.dart';

final getIt = GetIt.instance;

void setupInjector() {
  // نقطة وصول واحدة للـ Firestore — databaseId مضبوط هنا فقط
  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );
  final auth = FirebaseAuth.instance;

  getIt.registerLazySingleton<CatalogCache>(() => CatalogCache());

  getIt.registerLazySingleton<CatalogRepository>(
    () => FirebaseCatalogRepository(db, getIt<CatalogCache>(), getIt<LivePromotions>()),
  );

  getIt.registerLazySingleton<OrdersRepository>(
    () => FirebaseOrdersRepository(db, auth),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => FirebaseCartRepository(db, auth),
  );

  getIt.registerLazySingleton<PromotionRepository>(
    () => FirebasePromotionRepository(db),
  );
  getIt.registerLazySingleton(() => LivePromotions(getIt<PromotionRepository>()));

  getIt.registerLazySingleton<CurrencyConverterRepository>(
    () => LocalCurrencyConverterRepository(),
  );

  getIt.registerLazySingleton<AccountRepository>(() => FirebaseAccountRepository(db, auth));

  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(auth, db),
  );

  getIt.registerLazySingleton(
    () => CheckoutService(db, auth, FirebaseStorage.instance, getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<FitnessRepository>(
    () => FirebaseFitnessRepository(db, auth, getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<SupportRepository>(
    () => FirebaseSupportRepository(db, auth, getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<SharedCartRepository>(
    () => FirebaseSharedCartRepository(db, auth),
  );
  // Messages
  getIt.registerLazySingleton<MessagesRepository>(
        () => FirebaseMessagesRepository(db, auth),
  );

  getIt.registerFactory(
        () => MessagesCubit(getIt<MessagesRepository>()),
  );
  // Loyalty balance
  getIt.registerLazySingleton<LoyaltyBalanceRepository>(
    () => FirebaseLoyaltyBalanceRepository(db, auth),
  );
  getIt.registerFactory(() => LoyaltyBalanceCubit(getIt<LoyaltyBalanceRepository>()));

  getIt.registerLazySingleton<SuggestProductRepository>(
    () => FirebaseSuggestProductRepository(db, auth, getIt<AccountRepository>()),
  );
}
