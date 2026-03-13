import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

import '../models/checkout_preview_model.dart';
import '../models/checkout_result_model.dart';
import '../models/city_model.dart';
import '../models/payment_method_model.dart';
import '../models/pickup_point_model.dart';
import '../models/user_card_model.dart';

class CheckoutApi {
  const CheckoutApi(this._dioClient);

  final DioClient _dioClient;

  Future<CheckoutPreviewModel> getPreview() async {
    final response = await _dioClient.dio.post(ApiEndpoints.checkoutPreview);
    return CheckoutPreviewModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<CityModel>> getCities() async {
    final response = await _dioClient.dio.get(ApiEndpoints.cities);
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<PickupPointModel>> getPickupPoints({int? cityId}) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.pickupPoints,
      queryParameters: cityId == null ? null : {'city_id': cityId},
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map(
          (e) => PickupPointModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _dioClient.dio.get(ApiEndpoints.paymentMethods);
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map(
          (e) =>
              PaymentMethodModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<List<UserCardModel>> getUserCards() async {
    final response = await _dioClient.dio.get(ApiEndpoints.myCards);
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => UserCardModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
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

  Future<CheckoutResultModel> createOrder({required int pickupPointId}) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.checkoutCreate,
      data: {'pickup_point_id': pickupPointId},
    );

    return CheckoutResultModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
