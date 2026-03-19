import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import 'package:diplomeprojectmobile/features/profile/data/models/profile_model.dart';

class ProfileApi {
  const ProfileApi(this._dioClient);

  final DioClient _dioClient;

  Future<ProfileModel> getProfile() async {
    final response = await _dioClient.dio.get(ApiEndpoints.me);

    return ProfileModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
  }) async {
    final response = await _dioClient.dio.patch(
      ApiEndpoints.me,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'patronymic': patronymic,
        'phone': phone,
        'gender': gender,
      },
    );

    return ProfileModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<Map<String, dynamic>>> getCards() async {
    final response = await _dioClient.dio.get('${ApiEndpoints.me}/cards');

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> addCard(String cardNumber) async {
    await _dioClient.dio.post(
      '${ApiEndpoints.me}/cards',
      data: {'card_number': cardNumber},
    );
  }

  Future<void> deleteCard(int cardId) async {
    await _dioClient.dio.delete('${ApiEndpoints.me}/cards/$cardId');
  }

  Future<List<Map<String, dynamic>>> getPickupPoints() async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.me}/pickup-points',
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> addPickupPoint(int pickupPointId) async {
    await _dioClient.dio.post(
      '${ApiEndpoints.me}/pickup-points',
      data: {'pickup_point_id': pickupPointId},
    );
  }

  Future<void> deletePickupPoint(int userPickupId) async {
    await _dioClient.dio.delete(
      '${ApiEndpoints.me}/pickup-points/$userPickupId',
    );
  }

  Future<List<Map<String, dynamic>>> getCities() async {
    final response = await _dioClient.dio.get(ApiEndpoints.cities);

    if (response.data is List) {
      return (response.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getPickupPointsByCity(int cityId) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.pickupPoints,
      queryParameters: {'city_id': cityId},
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
