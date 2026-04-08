import '../entities/review.dart';

abstract class ReviewsRepo {
  Future<List<Review>> getProductReviews(int productId);

  Future<void> addReview({
    required int productId,
    required int rating,
    String? comment,
  });
}
