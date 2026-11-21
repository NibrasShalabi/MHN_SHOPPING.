import 'package:equatable/equatable.dart';

/// A third-party shop with its own storefront inside the app. Its
/// categories carry its id; customers order from it directly on WhatsApp.
class Supplier extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;

  /// The wide picture on the card; the fire gradient without it.
  final String? coverUrl;
  final String description;

  /// Digits with the country code, e.g. 963912345678.
  final String phone;
  final String address;
  final String mapsUrl;

  const Supplier({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverUrl,
    required this.description,
    this.phone = '',
    this.address = '',
    this.mapsUrl = '',
  });

  @override
  List<Object?> get props => [id, name, logoUrl, coverUrl, description, phone, address, mapsUrl];
}
