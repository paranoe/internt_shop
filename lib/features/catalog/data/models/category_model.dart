import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.categoryId, required super.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: int.parse(json['category_id'].toString()),
      categoryName: json['category_name']?.toString() ?? '',
    );
  }
}
