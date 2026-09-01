import 'package:equatable/equatable.dart';

/// Standard clothing sizes, smallest to largest.
///
/// A fixed enum rather than free text: sizes have to sort correctly and
/// match across products, which arbitrary strings from the dashboard
/// wouldn't.
enum ClothingSize { xs, s, m, l, xl, xxl }

extension ClothingSizeLabel on ClothingSize {
  String get label => switch (this) {
    ClothingSize.xs => 'XS',
    ClothingSize.s => 'S',
    ClothingSize.m => 'M',
    ClothingSize.l => 'L',
    ClothingSize.xl => 'XL',
    ClothingSize.xxl => 'XXL',
  };
}

/// A colour the admin marked as available for one product.
///
/// Carries its own hex value so the swatch shows the actual colour rather
/// than a name the user has to imagine.
class ProductColor extends Equatable {
  final String name;

  /// 0xAARRGGBB.
  final int value;

  const ProductColor({required this.name, required this.value});

  @override
  List<Object?> get props => [name, value];
}

/// One row of a product's size chart.
///
/// Measurements are free text because they differ by garment — a shirt
/// lists chest and length, trousers list waist and inseam. Forcing fixed
/// columns would mean empty cells on most products.
class SizeGuideRow extends Equatable {
  final String size;
  final Map<String, String> measurements;

  const SizeGuideRow({required this.size, required this.measurements});

  @override
  List<Object?> get props => [size, measurements];
}