import 'package:diplomeprojectmobile/features/reviews/data/datasources/reviews_api.dart';
import 'package:diplomeprojectmobile/features/reviews/domain/entities/review.dart';
import 'package:diplomeprojectmobile/features/reviews/domain/repos/reviews_repo.dart';

class ReviewsRepoImpl implements ReviewsRepo {
  const ReviewsRepoImpl(this._api);

  final ReviewsApi _api;

  @override
  Future<List<Review>> getProductReviews(int productId) {
    return _api.getProductReviews(productId);
  }

  @override
  Future<void> addReview({
    required int productId,
    required int rating,
    String? comment,
  }) {
    return _api.addReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}
