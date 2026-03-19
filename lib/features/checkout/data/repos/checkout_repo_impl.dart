import 'package:diplomeprojectmobile/features/checkout/data/datasources/checkout_api.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_preview.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_result.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/city.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/payment_method.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/pickup_point.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/user_card.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/repos/checkout_repo.dart';

class CheckoutRepoImpl implements CheckoutRepo {
  const CheckoutRepoImpl(this._api);

  final CheckoutApi _api;

  @override
  Future<CheckoutPreview> getPreview() {
    return _api.getPreview();
  }

  @override
  Future<List<City>> getCities() {
    return _api.getCities();
  }

  @override
  Future<List<PickupPoint>> getPickupPoints({int? cityId}) {
    return _api.getPickupPoints(cityId: cityId);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() {
    return _api.getPaymentMethods();
  }

  @override
  Future<List<UserCardEntity>> getUserCards() {
    return _api.getUserCards();
  }

  @override
  Future<UserCardEntity> addUserCard({required String cardNumber}) {
    return _api.addUserCard(cardNumber: cardNumber);
  }

  @override
  Future<void> deleteUserCard(int cardId) {
    return _api.deleteUserCard(cardId);
  }

  @override
  Future<CheckoutResult> createOrder({
    required int pickupPointId,
    required int paymentMethodId,
    int? cardId,
  }) {
    return _api.createOrder(
      pickupPointId: pickupPointId,
      paymentMethodId: paymentMethodId,
      cardId: cardId,
    );
  }
}
