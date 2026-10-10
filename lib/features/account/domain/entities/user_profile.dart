import 'package:equatable/equatable.dart';

/// The customer's own details, as stored in users/{uid}.
class UserProfile extends Equatable {
  /// Profile edits are allowed once per this window — the security rules
  /// enforce the same 7 days.
  static const Duration editCooldown = Duration(days: 7);

  final String fullName;
  final String familyName;
  final String email;
  final String phone;
  final String secondaryPhone;
  final String governorate;
  final String area;
  final bool isFemale;
  final DateTime? profileUpdatedAt;

  const UserProfile({
    this.fullName = '',
    this.familyName = '',
    this.email = '',
    this.phone = '',
    this.secondaryPhone = '',
    this.governorate = '',
    this.area = '',
    this.isFemale = false,
    this.profileUpdatedAt,
  });

  /// [updatedAt] comes converted from the stored timestamp by the repository.
  factory UserProfile.fromMap(Map<String, dynamic> d, {DateTime? updatedAt}) => UserProfile(
        fullName: d['fullName'] as String? ?? '',
        familyName: d['familyName'] as String? ?? '',
        email: d['email'] as String? ?? '',
        phone: d['phone'] as String? ?? '',
        secondaryPhone: d['secondaryPhone'] as String? ?? '',
        governorate: d['governorate'] as String? ?? '',
        area: d['area'] as String? ?? '',
        isFemale: d['gender'] == 'female',
        profileUpdatedAt: updatedAt,
      );

  String get displayName => '$fullName $familyName'.trim();

  /// When the next edit is allowed, or null when it is allowed now.
  DateTime? nextEditAt(DateTime now) {
    final last = profileUpdatedAt;
    if (last == null) return null;
    final next = last.add(editCooldown);
    return now.isBefore(next) ? next : null;
  }

  UserProfile edited({
    required String fullName,
    required String familyName,
    required String phone,
    required String secondaryPhone,
    required String governorate,
    required String area,
    required DateTime at,
  }) =>
      UserProfile(
        fullName: fullName,
        familyName: familyName,
        email: email,
        phone: phone,
        secondaryPhone: secondaryPhone,
        governorate: governorate,
        area: area,
        isFemale: isFemale,
        profileUpdatedAt: at,
      );

  @override
  List<Object?> get props =>
      [fullName, familyName, email, phone, secondaryPhone, governorate, area, isFemale, profileUpdatedAt];
}
