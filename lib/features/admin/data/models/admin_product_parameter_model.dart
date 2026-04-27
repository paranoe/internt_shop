class AdminProductParameterModel {
  const AdminProductParameterModel({
    required this.parameterId,
    required this.name,
    required this.dataType,
    this.unitId,
    this.unitName,
    this.unitShortName,
  });

  final int parameterId;
  final String name;
  final String dataType;
  final int? unitId;
  final String? unitName;
  final String? unitShortName;

  factory AdminProductParameterModel.fromJson(Map<String, dynamic> json) {
    return AdminProductParameterModel(
      parameterId: int.parse(json['parameter_id'].toString()),
      name: json['name']?.toString() ?? '',
      dataType: json['data_type']?.toString() ?? 'text',
      unitId: json['unit_id'] == null
          ? null
          : int.tryParse(json['unit_id'].toString()),
      unitName: json['unit_name']?.toString(),
      unitShortName: json['unit_short_name']?.toString(),
    );
  }
}
