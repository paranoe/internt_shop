class UserPickupPointModel {
  UserPickupPointModel({
    required this.userPickupId,
    required this.pickupPointId,
    required this.cityId,
    required this.cityName,
  });

  final int userPickupId;
  final int pickupPointId;
  final int cityId;
  final String cityName;

  factory UserPickupPointModel.fromJson(Map<String, dynamic> json) {
    return UserPickupPointModel(
      userPickupId: json['user_pickup_id'] as int,
      pickupPointId: json['pickup_point_id'] as int,
      cityId: json['city_id'] as int,
      cityName: (json['city_name'] as String?) ?? '',
    );
  }
}
