import '../../domain/entities/checkout_entity.dart';

class CheckoutModel extends CheckoutEntity {
  const CheckoutModel() : super();

  // TODO: add fields here (and pass them to super() above) once this model needs data

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return const CheckoutModel();
  }

  Map<String, dynamic> toJson() => {};
}
