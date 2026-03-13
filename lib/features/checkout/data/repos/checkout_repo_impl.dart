import '../../domain/entities/checkout_preview.dart';
import '../../domain/entities/checkout_result.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/pickup_point.dart';
import '../../domain/entities/user_card.dart';
import '../../domain/repos/checkout_repo.dart';
import '../datasources/checkout_api.dart';

class CheckoutRepoImpl implements CheckoutRepo {
  const CheckoutRepoImpl(this._api);

  final CheckoutApi _api;

  @override
  Future<CheckoutPreview> getPreview() => _api.getPreview();

  @override
  Future<List<City>> getCities() => _api.getCities();

  @override
  Future<List<PickupPoint>> getPickupPoints({int? cityId}) =>
      _api.getPickupPoints(cityId: cityId);

  @override
  Future<List<PaymentMethod>> getPaymentMethods() => _api.getPaymentMethods();

  @override
  Future<List<UserCardEntity>> getUserCards() => _api.getUserCards();

  @override
  Future<UserCardEntity> addUserCard({required String cardNumber}) =>
      _api.addUserCard(cardNumber: cardNumber);

  @override
  Future<void> deleteUserCard(int cardId) => _api.deleteUserCard(cardId);

  @override
  Future<CheckoutResult> createOrder({required int pickupPointId}) =>
      _api.createOrder(pickupPointId: pickupPointId);
}
