import 'package:equatable/equatable.dart';

/// A filter belonging to a category (e.g. "سيروم", "زيوت" under "شعر").
/// Fully dynamic — defined per category in Firestore, never hardcoded.
class ProductFilter extends Equatable {
  final String id;
  final String name;

  const ProductFilter({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}