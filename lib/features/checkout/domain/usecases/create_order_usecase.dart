import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_result.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/repos/checkout_repo.dart';

class CreateOrderUseCase {
  const CreateOrderUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<CheckoutResult> call({
    required int pickupPointId,
    required int paymentMethodId,
    int? cardId,
  }) {
    return _repo.createOrder(
      pickupPointId: pickupPointId,
      paymentMethodId: paymentMethodId,
      cardId: cardId,
    );
  }
}
