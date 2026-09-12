import 'package:equatable/equatable.dart';

/// A third-party supplier with its own storefront inside the app.
///
/// Independent of [Category]/[Product] — a supplier is who sells, a
/// category is what's organized under them. Products reach a supplier
/// through [Category.supplierId], the same way they reach a filter
/// through [Category.filters].
class Supplier extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String description;

  const Supplier({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, logoUrl, description];
}