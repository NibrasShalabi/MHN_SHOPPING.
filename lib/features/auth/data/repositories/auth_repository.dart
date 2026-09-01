import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/signup_data.dart';

/// Contract for authentication — the UI/Cubit layer depends only on this
/// interface. During the UI-only phase we inject [FakeAuthRepository];
/// once Firebase is wired, [FirebaseAuthRepository] implements the exact
/// same interface and gets swapped in via the service locator — nothing
/// in the Cubits or pages changes.
abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> signup(SignupData data);

  Future<void> sendPasswordResetEmail(String email);
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.trim().isEmpty || password.isEmpty) {
      throw const ValidationException(message: AppStrings.fillAllFields);
    }
    // Fake success — any non-empty credentials "work" during the UI phase.
  }

  @override
  Future<void> signup(SignupData data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Fake success.
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.trim().isEmpty) {
      throw const ValidationException(message: AppStrings.enterYourEmail);
    }
    // Fake success.
  }
}