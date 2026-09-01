import 'package:equatable/equatable.dart';

import 'product.dart';

/// One page of products plus the cursor needed to fetch the next one.
///
/// [nextCursor] is deliberately opaque (a String) so the domain layer never
/// learns what a Firestore DocumentSnapshot is — the Firestore repository
/// encodes the last document id here, and the fake one encodes an offset.
class ProductPageResult extends Equatable {
  final List<Product> products;
  final String? nextCursor;

  const ProductPageResult({required this.products, this.nextCursor});

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [products, nextCursor];
}