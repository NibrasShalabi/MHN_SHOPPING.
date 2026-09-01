import '../../domain/entities/loyalty_entity.dart';

class LoyaltyModel extends LoyaltyEntity {
  const LoyaltyModel() : super();

  // TODO: add fields here (and pass them to super() above) once this model needs data

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) {
    return const LoyaltyModel();
  }

  Map<String, dynamic> toJson() => {};
}
