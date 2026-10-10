import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final Failure? failure;
  final Set<String> unavailableProductIds;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.failure,
    this.unavailableProductIds = const {},
  });

  bool get isEmpty => items.isEmpty;
  bool get hasUnavailableItems => unavailableProductIds.isNotEmpty;
  bool get isReadyForCheckout => !isEmpty && !hasUnavailableItems;

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// The cart holds [AppConstants.cartMaxPieces] pieces at most — the
  /// customer checks out or clears it before adding more.
  int get room => AppConstants.cartMaxPieces - totalCount;
  bool get isFull => room <= 0;

  /// Display totals only — checkout recomputes both server-side.
  double get moneyTotal => items.where((i) => !i.isPoints).fold(0, (sum, i) => sum + i.lineTotal);
  /// Supply shipping on money items — delivery is added at checkout by governorate.
  double get supplyShipping => items.where((i) => !i.isPoints).fold(0, (sum, i) => sum + i.lineShipping);
  int get pointsTotal => items.where((i) => i.isPoints).fold(0, (sum, i) => sum + i.lineTotal.round());

  bool get hasMoneyItems => items.any((i) => !i.isPoints);
  bool get hasPointsItems => items.any((i) => i.isPoints);

  /// Loyalty-store only — nothing to pay in money.
  bool get isPointsOnly => !isEmpty && !hasMoneyItems;

  bool canAffordPoints(int balance) => pointsTotal <= balance;

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    Failure? failure,
    Set<String>? unavailableProductIds,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
      unavailableProductIds: unavailableProductIds ?? this.unavailableProductIds,
    );
  }

  @override
  List<Object?> get props => [status, items, failure, unavailableProductIds];
}