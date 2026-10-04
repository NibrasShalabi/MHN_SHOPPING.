// import '../../domain/entities/category.dart';
// import '../../domain/entities/product.dart';
// import '../../domain/entities/promo_banner.dart';
// import 'catalog_repository.dart';
//
// /// UI-phase implementation — returns static data with a fake delay.
// /// Swapped for FirebaseCatalogRepository (same interface) at logic phase;
// /// nothing in the Cubit or pages changes when that happens.
// class FakeCatalogRepository implements CatalogRepository {
//   @override
//   Future<List<PromoBanner>> getPromoBanners() async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     return const [
//       PromoBanner(id: 'b1', title: 'خصم يصل إلى 30%'),
//     ];
//   }
//
//   @override
//   Future<List<Category>> getCategories() async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     return const [
//       Category(id: 'hair', name: 'شعر'),
//       Category(id: 'skin', name: 'بشرة'),
//     ];
//   }
//
//   @override
//   Future<List<Product>> getFeaturedProducts() async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     return const [
//       Product(id: 'p1', categoryId: 'hair', name: 'سيروم شعر', price: 45000, isNew: true),
//       Product(id: 'p2', categoryId: 'skin', name: 'كريم ترطيب', price: 32000),
//     ];
//   }
// }