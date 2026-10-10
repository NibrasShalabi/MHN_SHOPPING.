import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';

abstract class OrdersRepository {
  /// Only returns orders inside the retention window — see
  /// [OrdersRetention]. Anything older is not shown to the user at all.
  Future<List<OrderEntity>> getOrders();

  /// Live list — payment rejections and status changes show up without a refresh.
  Stream<List<OrderEntity>> watchOrders();
}

/// How long an order stays visible to the user.
///
/// NOTE(logic-phase): the Firestore query must filter on createdAt within
/// this window, AND a scheduled Cloud Function should archive/delete older
/// order documents — otherwise the collection grows forever and the "no
/// orders older than this" rule only holds on the client.
class OrdersRetention {
  OrdersRetention._();

  static const Duration window = Duration(days: 25);

  static bool isVisible(DateTime createdAt) =>
      DateTime.now().difference(createdAt) <= window;
}
