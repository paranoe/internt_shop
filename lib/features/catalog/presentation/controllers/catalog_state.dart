import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';

enum CatalogStatus { initial, loading, success, error }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId,
    this.errorMessage,
  });

  final CatalogStatus status;
  final List<Category> categories;
  final List<ProductCardEntity> products;
  final int? selectedCategoryId;
  final String? errorMessage;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Category>? categories,
    List<ProductCardEntity>? products,
    int? selectedCategoryId,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearError = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    products,
    selectedCategoryId,
    errorMessage,
  ];
}
