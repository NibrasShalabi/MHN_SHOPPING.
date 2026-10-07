abstract class LoyaltyBalanceRepository {
  /// Live balance of the signed-in user; 0 while signed out.
  Stream<int> watchBalance();
}
