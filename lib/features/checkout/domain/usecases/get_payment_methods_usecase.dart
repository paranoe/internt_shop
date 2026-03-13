import '../entities/payment_method.dart';
import '../repos/checkout_repo.dart';

class GetPaymentMethodsUseCase {
  const GetPaymentMethodsUseCase(this._repo);

  final CheckoutRepo _repo;

  Future<List<PaymentMethod>> call() => _repo.getPaymentMethods();
}
