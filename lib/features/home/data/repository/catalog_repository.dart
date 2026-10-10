import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_page_result.dart';
import '../../domain/entities/product_query.dart';
import '../../domain/entities/promo_banner.dart';
import '../../../suppliers/domain/entities/supplier.dart';

abstract class CatalogRepository {
  Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false});
  Future<List<Supplier>> getSuppliers({bool forceRefresh = false});
  Future<Supplier> getSupplier(String supplierId, {bool forceRefresh = false});
  Future<List<Category>> getCategories({
    CatalogScope scope = CatalogScope.store,
    String? supplierId,
    bool forceRefresh = false,
  });
  Future<Category> getCategory(String categoryId, {bool forceRefresh = false});
  Future<Product> getProduct(String productId, {bool forceRefresh = false});

  /// Several products at once (missing ones are left out) — 30 per read.
  Future<List<Product>> getProductsByIds(List<String> productIds);
  Future<ProductPageResult> getProducts({
    required ProductQuery query,
    String? filterId,
    String? cursor,
    bool forceRefresh = false,
  });
}
