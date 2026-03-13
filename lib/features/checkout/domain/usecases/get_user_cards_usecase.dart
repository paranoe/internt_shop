import '../entities/user_card.dart';
import '../repos/checkout_repo.dart';

class GetUserCardsUseCase {
  const GetUserCardsUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<List<UserCardEntity>> call() => _repo.getUserCards();
}
