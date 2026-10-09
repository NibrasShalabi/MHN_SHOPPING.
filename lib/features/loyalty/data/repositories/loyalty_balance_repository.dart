import '../../domain/entities/loyalty_transaction.dart';

abstract class LoyaltyBalanceRepository {
  /// Live balance of the signed-in user; 0 while signed out.
  Stream<int> watchBalance();

  /// Latest points movements, newest first — read once per visit.
  Future<List<LoyaltyTransaction>> getHistory();
}
