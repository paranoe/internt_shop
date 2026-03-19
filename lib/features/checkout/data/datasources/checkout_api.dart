import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import 'package:diplomeprojectmobile/features/checkout/data/models/checkout_preview_model.dart';
import 'package:diplomeprojectmobile/features/checkout/data/models/checkout_result_model.dart';
import 'package:diplomeprojectmobile/features/checkout/data/models/city_model.dart';
import 'package:diplomeprojectmobile/features/checkout/data/models/payment_method_model.dart';
import 'package:diplomeprojectmobile/features/checkout/data/models/pickup_point_model.dart';
import 'package:diplomeprojectmobile/features/checkout/data/models/user_card_model.dart';

class CheckoutApi {
  const CheckoutApi(this._dioClient);

  final DioClient _dioClient;

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List<dynamic>? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<CheckoutPreviewModel> getPreview() async {
    final response = await _dioClient.dio.post(ApiEndpoints.checkoutPreview);

    return CheckoutPreviewModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<CityModel>> getCities() async {
    final items = _extractItems(
      (await _dioClient.dio.get(ApiEndpoints.cities)).data,
    );

    return items.map(CityModel.fromJson).toList();
  }

  Future<List<PickupPointModel>> getPickupPoints({int? cityId}) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.pickupPoints,
      queryParameters: cityId == null ? null : {'city_id': cityId},
    );

    final items = _extractItems(response.data);

    return items.map(PickupPointModel.fromJson).toList();
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final items = _extractItems(
      (await _dioClient.dio.get(ApiEndpoints.paymentMethods)).data,
    );

    return items.map(PaymentMethodModel.fromJson).toList();
  }

  Future<List<UserCardModel>> getUserCards() async {
    final items = _extractItems(
      (await _dioClient.dio.get(ApiEndpoints.myCards)).data,
    );

    return items.map(UserCardModel.fromJson).toList();
  }

  Future<UserCardModel> addUserCard({required String cardNumber}) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.myCards,
      data: {'card_number': cardNumber},
    );

    return UserCardModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteUserCard(int cardId) async {
    await _dioClient.dio.delete('${ApiEndpoints.myCards}/$cardId');
  }

  Future<CheckoutResultModel> createOrder({
    required int pickupPointId,
    required int paymentMethodId,
    int? cardId,
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.checkoutCreate,
      data: {
        'pickup_point_id': pickupPointId,
        'payment_method_id': paymentMethodId,
        if (cardId != null) 'card_id': cardId,
      },
    );

    return CheckoutResultModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
