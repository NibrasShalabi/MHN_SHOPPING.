import '../../domain/entities/user_profile.dart';

abstract class AccountRepository {
  /// The signed-in customer's profile — read once per session, then served
  /// from memory to every feature that needs her name or area.
  Future<UserProfile> profile({bool refresh = false});

  /// Saves the editable fields. Refused (by the rules too) within
  /// [UserProfile.editCooldown] of the last edit.
  Future<UserProfile> updateProfile(UserProfile profile);

  Future<void> changePassword({required String current, required String next});

  Future<void> signOut();

  /// Drops the cached profile (another account signed in).
  void clear();
}
