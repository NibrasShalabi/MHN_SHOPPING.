import '../../domain/entities/suggest_product_entity.dart';

class SuggestProductModel extends SuggestProductEntity {
  const SuggestProductModel() : super();

  // TODO: add fields here (and pass them to super() above) once this model needs data

  factory SuggestProductModel.fromJson(Map<String, dynamic> json) {
    return const SuggestProductModel();
  }

  Map<String, dynamic> toJson() => {};
}
