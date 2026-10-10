import '../../domain/entities/signup_data.dart';

/// Contract for authentication — cubits and pages depend only on this;
/// [FirebaseAuthRepository] implements it.
abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> signup(SignupData data);

  Future<void> sendPasswordResetEmail(String email);
}
