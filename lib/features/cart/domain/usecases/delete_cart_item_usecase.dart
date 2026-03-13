import 'package:diplomeprojectmobile/features/cart/domain/repos/cart_repo.dart';

class DeleteCartItemUseCase {
  const DeleteCartItemUseCase(this._repo);

  final CartRepo _repo;

  Future<void> call({required int cartItemId}) {
    return _repo.deleteCartItem(cartItemId: cartItemId);
  }
}
