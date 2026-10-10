import 'package:equatable/equatable.dart';

/// A third-party shop with its own storefront inside the app. Its
/// categories carry its id; customers order from it directly on WhatsApp.
class Supplier extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String description;

  /// Digits with the country code, e.g. 963912345678.
  final String phone;
  final String address;
  final String mapsUrl;

  const Supplier({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.description,
    this.phone = '',
    this.address = '',
    this.mapsUrl = '',
  });

  @override
  List<Object?> get props => [id, name, logoUrl, description, phone, address, mapsUrl];
}
