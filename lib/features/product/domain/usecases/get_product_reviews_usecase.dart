import 'package:diplomeprojectmobile/features/product/domain/entities/review.dart';
import 'package:diplomeprojectmobile/features/product/domain/repos/product_repo.dart';

class GetProductReviewsUseCase {
  const GetProductReviewsUseCase(this._repo);

  final ProductRepo _repo;

  Future<List<ProductReview>> call(int productId) =>
      _repo.getProductReviews(productId);
}
