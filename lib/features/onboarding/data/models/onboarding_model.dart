import '../../domain/entities/onboarding_entity.dart';

class OnboardingModel extends OnboardingEntity {
  const OnboardingModel() : super();

  // TODO: add fields here (and pass them to super() above) once this model needs data

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return const OnboardingModel();
  }

  Map<String, dynamic> toJson() => {};
}
