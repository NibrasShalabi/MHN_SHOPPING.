import 'package:equatable/equatable.dart';

import 'product_filter.dart';

/// Where a category is surfaced.
///
/// The store, the fitness section and the loyalty store all browse the
/// same way and share every widget; they differ only in entry point,
/// whether the products can be ordered, and what the price is denominated
/// in. A scope field keeps that as one system instead of three.
///
/// [supplier] is one bucket shared by every supplier — [Category.supplierId]
/// narrows it to a specific one, the same way [filterId] narrows a
/// category to one shelf within it.
enum CatalogScope { store, fitness, loyalty, supplier }

class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final List<ProductFilter> filters;
  final CatalogScope scope;

  /// Set only when [scope] is [CatalogScope.supplier] — which supplier
  /// this category belongs to.
  final String? supplierId;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.filters = const [],
    this.scope = CatalogScope.store,
    this.supplierId,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, filters, scope, supplierId];
}