import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_details.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_image.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_parameter.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/review.dart';

enum ProductStatus { initial, loading, success, error }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.details,
    this.images = const [],
    this.parameters = const [],
    this.reviews = const [],
    this.errorMessage,
  });

  final ProductStatus status;
  final ProductDetails? details;
  final List<ProductImage> images;
  final List<ProductParameter> parameters;
  final List<ProductReview> reviews;
  final String? errorMessage;

  ProductState copyWith({
    ProductStatus? status,
    ProductDetails? details,
    List<ProductImage>? images,
    List<ProductParameter>? parameters,
    List<ProductReview>? reviews,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      details: details ?? this.details,
      images: images ?? this.images,
      parameters: parameters ?? this.parameters,
      reviews: reviews ?? this.reviews,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    details,
    images,
    parameters,
    reviews,
    errorMessage,
  ];
}
