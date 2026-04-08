import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/product/data/datasources/product_api.dart';
import 'package:diplomeprojectmobile/features/product/data/repos/product_repo_impl.dart';
import 'package:diplomeprojectmobile/features/product/domain/usecases/get_product_details_usecase.dart';
import 'package:diplomeprojectmobile/features/product/domain/usecases/get_product_images_usecase.dart';
import 'package:diplomeprojectmobile/features/product/domain/usecases/get_product_parameters_usecase.dart';
import 'package:diplomeprojectmobile/features/product/domain/usecases/get_product_reviews_usecase.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';
import 'product_state.dart';

class ProductController extends Cubit<ProductState> {
  ProductController({required ProductApi productApi})
    : _getDetails = GetProductDetailsUseCase(_buildRepo(productApi)),
      _getImages = GetProductImagesUseCase(_buildRepo(productApi)),
      _getParameters = GetProductParametersUseCase(_buildRepo(productApi)),
      _getReviews = GetProductReviewsUseCase(_buildRepo(productApi)),
      super(const ProductState());

  final GetProductDetailsUseCase _getDetails;
  final GetProductImagesUseCase _getImages;
  final GetProductParametersUseCase _getParameters;
  final GetProductReviewsUseCase _getReviews;

  static ProductRepoImpl _buildRepo(ProductApi productApi) {
    return ProductRepoImpl(productApi);
  }

  Future<void> load(int productId) async {
    emit(state.copyWith(status: ProductStatus.loading, clearError: true));

    try {
      final details = await _getDetails(productId);
      final images = await _getImages(productId);
      final parameters = await _getParameters(productId);
      final reviews = await _getReviews(productId);

      emit(
        state.copyWith(
          status: ProductStatus.success,
          details: details,
          images: images,
          parameters: parameters,
          reviews: reviews,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }
}
