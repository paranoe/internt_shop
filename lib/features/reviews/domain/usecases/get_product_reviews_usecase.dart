import '../entities/review.dart';
import '../repos/reviews_repo.dart';

class GetProductReviewsUseCase {
  const GetProductReviewsUseCase(this._repo);

  final ReviewsRepo _repo;

  Future<List<Review>> call(int productId) {
    return _repo.getProductReviews(productId);
  }
}
