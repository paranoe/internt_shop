import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplomeprojectmobile/features/reviews/data/datasources/reviews_api.dart';
import 'package:diplomeprojectmobile/features/reviews/data/repos/reviews_repo_impl.dart';
import 'package:diplomeprojectmobile/features/reviews/domain/usecases/add_review_usecase.dart';
import 'package:diplomeprojectmobile/features/reviews/domain/usecases/get_product_reviews_usecase.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';
import 'reviews_state.dart';

class ReviewsController extends Cubit<ReviewsState> {
  ReviewsController({required ReviewsApi reviewsApi})
    : _getProductReviews = GetProductReviewsUseCase(_buildRepo(reviewsApi)),
      _addReview = AddReviewUseCase(_buildRepo(reviewsApi)),
      super(const ReviewsState());

  final GetProductReviewsUseCase _getProductReviews;
  final AddReviewUseCase _addReview;

  static ReviewsRepoImpl _buildRepo(ReviewsApi reviewsApi) {
    return ReviewsRepoImpl(reviewsApi);
  }

  Future<void> loadProductReviews(int productId) async {
    emit(
      state.copyWith(
        status: ReviewsStatus.loading,
        clearError: true,
        lastAddedSuccessfully: false,
      ),
    );

    try {
      final reviews = await _getProductReviews(productId);

      emit(
        state.copyWith(
          status: ReviewsStatus.success,
          reviews: reviews,
          clearError: true,
          lastAddedSuccessfully: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ReviewsStatus.error,
          errorMessage: ErrorMapper.map(e),
          lastAddedSuccessfully: false,
        ),
      );
    }
  }

  Future<bool> addReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    emit(
      state.copyWith(
        status: ReviewsStatus.submitting,
        clearError: true,
        lastAddedSuccessfully: false,
      ),
    );

    try {
      await _addReview(productId: productId, rating: rating, comment: comment);

      final reviews = await _getProductReviews(productId);

      emit(
        state.copyWith(
          status: ReviewsStatus.success,
          reviews: reviews,
          clearError: true,
          lastAddedSuccessfully: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ReviewsStatus.error,
          errorMessage: ErrorMapper.map(e),
          lastAddedSuccessfully: false,
        ),
      );
      return false;
    }
  }
}
