import '../entities/user_card.dart';
import '../repos/checkout_repo.dart';

class AddUserCardUseCase {
  const AddUserCardUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<UserCardEntity> call({required String cardNumber}) =>
      _repo.addUserCard(cardNumber: cardNumber);
}
