import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

/// Register all dependencies here (repositories, data sources, cubits...)
/// Call init() from main.dart before runApp.
Future<void> init() async {
  // sl.registerFactory(() => ExampleCubit(sl()));
  // sl.registerLazySingleton<ExampleRepository>(() => ExampleRepositoryImpl(sl()));
}
