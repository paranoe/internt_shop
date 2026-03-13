import 'package:diplomeprojectmobile/features/cart/domain/repos/cart_repo.dart';

class UpdateCartItemUseCase {
  const UpdateCartItemUseCase(this._repo);

  final CartRepo _repo;

  Future<void> call({
    required int cartItemId,
    int? quantity,
    bool? selectedForPurchase,
  }) {
    return _repo.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
      selectedForPurchase: selectedForPurchase,
    );
  }
}
