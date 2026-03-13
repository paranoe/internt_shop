import '../entities/checkout_preview.dart';
import '../entities/checkout_result.dart';
import '../entities/city.dart';
import '../entities/payment_method.dart';
import '../entities/pickup_point.dart';
import '../entities/user_card.dart';

abstract class CheckoutRepo {
  Future<CheckoutPreview> getPreview();
  Future<List<City>> getCities();
  Future<List<PickupPoint>> getPickupPoints({int? cityId});
  Future<List<PaymentMethod>> getPaymentMethods();
  Future<List<UserCardEntity>> getUserCards();
  Future<UserCardEntity> addUserCard({required String cardNumber});
  Future<void> deleteUserCard(int cardId);
  Future<CheckoutResult> createOrder({required int pickupPointId});
}
