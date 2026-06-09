import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import 'package:diplomeprojectmobile/features/profile/data/models/profile_model.dart';

class ProfileApi {
  const ProfileApi(this._dioClient);

  final DioClient _dioClient;

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

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
    final response = await _dioClient.dio.get('/me/cards');
    return _extractItems(response.data);
  }

  Future<void> addCard(String cardNumber) async {
    await _dioClient.dio.post('/me/cards', data: {'card_number': cardNumber});
  }

  Future<void> deleteCard(int cardId) async {
    await _dioClient.dio.delete('/me/cards/$cardId');
  }

  /// Получает ТОЛЬКО сохранённые ПВЗ текущего пользователя.
  /// Это должен быть endpoint /me/pickup-points, а не общий /pickup-points.
  Future<List<Map<String, dynamic>>> getPickupPoints() async {
    final response = await _dioClient.dio.get('/me/pickup-points');

    print('MY PICKUP POINTS RESPONSE: ${response.data}');

    return _extractItems(response.data);
  }

  /// Добавляет выбранный общий ПВЗ в список ПВЗ текущего пользователя.
  Future<void> addPickupPoint(int pickupPointId) async {
    await _dioClient.dio.post(
      '/me/pickup-points',
      data: {'pickup_point_id': pickupPointId},
    );
  }

  /// Удаляет сохранённый ПВЗ пользователя по user_pickup_id.
  /// Не удаляет общий ПВЗ из таблицы pickup_points.
  Future<void> deletePickupPoint(int userPickupId) async {
    await _dioClient.dio.delete('/me/pickup-points/$userPickupId');
  }

  Future<List<Map<String, dynamic>>> getCities() async {
    final response = await _dioClient.dio.get(ApiEndpoints.cities);
    return _extractItems(response.data);
  }

  /// Общий список ПВЗ для выбора нового ПВЗ.
  /// Это НЕ профиль пользователя, поэтому тут используется /pickup-points.
  Future<List<Map<String, dynamic>>> getPickupPointsByCity(int cityId) async {
    final response = await _dioClient.dio.get(
      '/pickup-points',
      queryParameters: {'city_id': cityId},
    );

    return _extractItems(response.data);
  }
}
