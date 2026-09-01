import 'package:equatable/equatable.dart';

import '../../../../core/model/gender.dart';

/// Domain entity representing the data required to register a new user.
/// Passed as a single object through Cubit → Repository → data source,
/// instead of threading 9+ loose parameters through every layer — adding
/// a field later means editing this class, not every method signature
/// that calls signup().
class SignupData extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String familyName;
  final String phone;
  final String? secondaryPhone;
  final String location;
  final String governorate;
  final String area;
  final Gender gender;

  const SignupData({
    required this.email,
    required this.password,
    required this.fullName,
    required this.familyName,
    required this.phone,
    this.secondaryPhone,
    required this.location,
    required this.governorate,
    required this.area,
    required this.gender,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    familyName,
    phone,
    secondaryPhone,
    location,
    governorate,
    area,
    gender,
  ];
}