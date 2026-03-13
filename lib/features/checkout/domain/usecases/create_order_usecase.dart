import '../entities/checkout_result.dart';
import '../repos/checkout_repo.dart';

class CreateOrderUseCase {
  const CreateOrderUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<CheckoutResult> call({required int pickupPointId}) =>
      _repo.createOrder(pickupPointId: pickupPointId);
}
