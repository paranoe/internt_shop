import 'package:diplomeprojectmobile/features/catalog/domain/entities/subcategory.dart';

class SubcategoryModel extends Subcategory {
  const SubcategoryModel({
    required super.subcategoryId,
    required super.categoryId,
    required super.name,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      subcategoryId: int.parse(json['subcategory_id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }
}
