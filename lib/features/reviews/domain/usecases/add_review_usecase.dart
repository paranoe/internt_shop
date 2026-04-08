import '../repos/reviews_repo.dart';

class AddReviewUseCase {
  const AddReviewUseCase(this._repo);

  final ReviewsRepo _repo;

  Future<void> call({
    required int productId,
    required int rating,
    String? comment,
  }) {
    return _repo.addReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}
