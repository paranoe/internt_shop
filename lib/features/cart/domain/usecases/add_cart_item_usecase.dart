import 'package:diplomeprojectmobile/features/cart/domain/repos/cart_repo.dart';

class AddCartItemUseCase {
  const AddCartItemUseCase(this._repo);

  final CartRepo _repo;

  Future<void> call({required int productId, required int quantity}) {
    return _repo.addCartItem(productId: productId, quantity: quantity);
  }
}
