import '../repos/checkout_repo.dart';

class DeleteUserCardUseCase {
  const DeleteUserCardUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<void> call(int cardId) => _repo.deleteUserCard(cardId);
}
