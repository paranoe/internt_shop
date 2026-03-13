import 'package:diplomeprojectmobile/features/checkout/domain/entities/city.dart';

class CityModel extends City {
  const CityModel({required super.cityId, required super.cityName});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityId: int.parse(json['city_id'].toString()),
      cityName: json['city_name']?.toString() ?? '',
    );
  }
}
