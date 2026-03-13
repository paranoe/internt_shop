import 'package:diplomeprojectmobile/features/cart/domain/entities/cart.dart';
import 'package:diplomeprojectmobile/features/cart/domain/repos/cart_repo.dart';

class GetCartUseCase {
  const GetCartUseCase(this._repo);

  final CartRepo _repo;

  Future<Cart> call() => _repo.getCart();
}
