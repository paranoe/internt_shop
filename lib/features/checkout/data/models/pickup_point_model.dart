import 'package:diplomeprojectmobile/features/checkout/domain/entities/pickup_point.dart';

class PickupPointModel extends PickupPoint {
  const PickupPointModel({
    required super.pickupPointId,
    required super.cityId,
    required super.cityName,
  });

  factory PickupPointModel.fromJson(Map<String, dynamic> json) {
    return PickupPointModel(
      pickupPointId: int.parse(json['pickup_point_id'].toString()),
      cityId: int.parse(json['city_id'].toString()),
      cityName: json['city_name']?.toString() ?? '',
    );
  }
}
