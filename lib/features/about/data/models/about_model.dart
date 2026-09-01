import '../../domain/entities/about_entity.dart';

class AboutModel extends AboutEntity {
  const AboutModel() : super();

  // TODO: add fields here (and pass them to super() above) once this model needs data

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return const AboutModel();
  }

  Map<String, dynamic> toJson() => {};
}
