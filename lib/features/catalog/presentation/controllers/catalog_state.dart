import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/subcategory.dart';

enum CatalogStatus { initial, loading, success, error }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.categories = const [],
    this.subcategories = const [],
    this.products = const [],
    this.availableParameters = const [],
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    this.searchQuery = '',
    this.minPrice = '',
    this.maxPrice = '',
    this.minRating,
    this.sortBy = 'popular',
    this.parameterFilters = const {},
    this.errorMessage,
  });

  final CatalogStatus status;
  final List<Category> categories;
  final List<Subcategory> subcategories;
  final List<ProductCardEntity> products;
  final List<Map<String, dynamic>> availableParameters;
  final int? selectedCategoryId;
  final int? selectedSubcategoryId;
  final String searchQuery;
  final String minPrice;
  final String maxPrice;
  final double? minRating;
  final String sortBy;
  final Map<int, String> parameterFilters;
  final String? errorMessage;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Category>? categories,
    List<Subcategory>? subcategories,
    List<ProductCardEntity>? products,
    List<Map<String, dynamic>>? availableParameters,
    int? selectedCategoryId,
    int? selectedSubcategoryId,
    String? searchQuery,
    String? minPrice,
    String? maxPrice,
    double? minRating,
    String? sortBy,
    Map<int, String>? parameterFilters,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearSelectedSubcategory = false,
    bool clearSearchQuery = false,
    bool clearPrices = false,
    bool clearRating = false,
    bool clearParameterFilters = false,
    bool clearError = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      products: products ?? this.products,
      availableParameters: availableParameters ?? this.availableParameters,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      selectedSubcategoryId: clearSelectedSubcategory
          ? null
          : (selectedSubcategoryId ?? this.selectedSubcategoryId),
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      minPrice: clearPrices ? '' : (minPrice ?? this.minPrice),
      maxPrice: clearPrices ? '' : (maxPrice ?? this.maxPrice),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
      parameterFilters: clearParameterFilters
          ? {}
          : (parameterFilters ?? this.parameterFilters),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    subcategories,
    products,
    availableParameters,
    selectedCategoryId,
    selectedSubcategoryId,
    searchQuery,
    minPrice,
    maxPrice,
    minRating,
    sortBy,
    parameterFilters,
    errorMessage,
  ];
}
