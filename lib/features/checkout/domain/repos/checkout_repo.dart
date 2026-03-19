import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_preview.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_result.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/city.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/payment_method.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/pickup_point.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/user_card.dart';

abstract class CheckoutRepo {
  Future<CheckoutPreview> getPreview();

  Future<List<City>> getCities();

  Future<List<PickupPoint>> getPickupPoints({int? cityId});

  Future<List<PaymentMethod>> getPaymentMethods();

  Future<List<UserCardEntity>> getUserCards();

  Future<UserCardEntity> addUserCard({required String cardNumber});

  Future<void> deleteUserCard(int cardId);

  Future<CheckoutResult> createOrder({
    required int pickupPointId,
    required int paymentMethodId,
    int? cardId,
  });
}
