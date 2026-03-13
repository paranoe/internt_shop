import 'package:diplomeprojectmobile/features/product/domain/entities/product_parameter.dart';

class ProductParameterModel extends ProductParameter {
  const ProductParameterModel({required super.name, required super.value});

  factory ProductParameterModel.fromJson(Map<String, dynamic> json) {
    return ProductParameterModel(
      name: (json['parameter_name'] ?? json['name']).toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}
