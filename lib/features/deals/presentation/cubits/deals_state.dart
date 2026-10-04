import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/product.dart';
import '../../domain/entities/promotion.dart';

enum DealsStatus { initial, loading, success, failure }

class DealItem extends Equatable {
  final Product product;
  final Promotion promotion;
  const DealItem({required this.product, required this.promotion});

  @override
  List<Object?> get props => [product, promotion];
}

class DealsState extends Equatable {
  final DealsStatus status;
  final List<DealItem> items;
  final Failure? failure;

  const DealsState({
    this.status = DealsStatus.initial,
    this.items = const [],
    this.failure,
  });

  DealsState copyWith({DealsStatus? status, List<DealItem>? items, Failure? failure}) {
    return DealsState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, items, failure];
}