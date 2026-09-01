import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final Failure? failure;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.failure,
  });

  bool get isEmpty => items.isEmpty;

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Display total only — checkout recomputes it server-side.
  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    Failure? failure,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, items, failure];
}