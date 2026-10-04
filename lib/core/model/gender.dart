import '../constants/app_strings.dart';

enum Gender { male, female }

extension GenderLabel on Gender {
  String get label => switch (this) {
    Gender.male => AppStrings.male,
    Gender.female => AppStrings.female,
  };
}