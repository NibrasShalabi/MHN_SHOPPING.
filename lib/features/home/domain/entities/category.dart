import 'package:equatable/equatable.dart';

import 'product_filter.dart';

/// Where a category is surfaced.
///
/// The store, the fitness section and the loyalty store all browse the
/// same way and share every widget; they differ only in entry point,
/// whether the products can be ordered, and what the price is denominated
/// in. A scope field keeps that as one system instead of three.
enum CatalogScope { store, fitness, loyalty }

class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final List<ProductFilter> filters;
  final CatalogScope scope;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.filters = const [],
    this.scope = CatalogScope.store,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, filters, scope];
}