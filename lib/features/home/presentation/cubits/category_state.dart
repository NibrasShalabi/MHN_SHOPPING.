import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final Category? category;
  final List<Product> products;

  /// null means the "الكل" chip is selected.
  final String? selectedFilterId;

  /// Cursor for the next page; null once everything is loaded.
  final String? nextCursor;

  /// Swapping filters — the chips stay live, only the grid shows a spinner.
  final bool isFiltering;

  /// Appending the next page at the bottom of the grid.
  final bool isLoadingMore;

  final Failure? failure;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.category,
    this.products = const [],
    this.selectedFilterId,
    this.nextCursor,
    this.isFiltering = false,
    this.isLoadingMore = false,
    this.failure,
  });

  bool get hasMore => nextCursor != null;

  CategoryState copyWith({
    CategoryStatus? status,
    Category? category,
    List<Product>? products,
    String? selectedFilterId,
    bool clearFilter = false,
    String? nextCursor,
    bool clearCursor = false,
    bool? isFiltering,
    bool? isLoadingMore,
    Failure? failure,
  }) {
    return CategoryState(
      status: status ?? this.status,
      category: category ?? this.category,
      products: products ?? this.products,
      selectedFilterId: clearFilter ? null : (selectedFilterId ?? this.selectedFilterId),
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isFiltering: isFiltering ?? this.isFiltering,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    category,
    products,
    selectedFilterId,
    nextCursor,
    isFiltering,
    isLoadingMore,
    failure,
  ];
}