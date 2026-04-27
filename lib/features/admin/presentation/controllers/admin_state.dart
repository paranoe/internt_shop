import 'package:equatable/equatable.dart';

enum AdminStatus { initial, loading, success, saving, error }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.parameters = const [],
    this.measurementUnits = const [],
    this.productParameters = const [],
    this.categories = const [],
    this.subcategories = const [],
    this.bindings = const [],
    this.cities = const [],
    this.pickupPoints = const [],
    this.products = const [],
    this.sellers = const [],
    this.users = const [],
    this.reviews = const [],
    this.adminSubcategories = const [],
    this.orders = const [],
    this.selectedOrder,
    this.selectedOrderItems = const [],
    this.stats,
    this.errorMessage,
  });

  final AdminStatus status;
  final List<Map<String, dynamic>> parameters;
  final List<Map<String, dynamic>> measurementUnits;
  final List<Map<String, dynamic>> productParameters;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> reviews;
  final List<Map<String, dynamic>> subcategories;
  final List<Map<String, dynamic>> bindings;
  final List<Map<String, dynamic>> cities;
  final List<Map<String, dynamic>> pickupPoints;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> sellers;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> adminSubcategories;
  final List<Map<String, dynamic>> orders;
  final Map<String, dynamic>? selectedOrder;
  final List<Map<String, dynamic>> selectedOrderItems;
  final Map<String, dynamic>? stats;
  final String? errorMessage;

  AdminState copyWith({
    AdminStatus? status,
    List<Map<String, dynamic>>? parameters,
    List<Map<String, dynamic>>? measurementUnits,
    List<Map<String, dynamic>>? productParameters,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? subcategories,
    List<Map<String, dynamic>>? reviews,
    List<Map<String, dynamic>>? bindings,
    List<Map<String, dynamic>>? cities,
    List<Map<String, dynamic>>? pickupPoints,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? sellers,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? adminSubcategories,
    List<Map<String, dynamic>>? orders,
    Map<String, dynamic>? selectedOrder,
    List<Map<String, dynamic>>? selectedOrderItems,
    Map<String, dynamic>? stats,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedOrder = false,
  }) {
    return AdminState(
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
      measurementUnits: measurementUnits ?? this.measurementUnits,
      productParameters: productParameters ?? this.productParameters,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      reviews: reviews ?? this.reviews,
      bindings: bindings ?? this.bindings,
      cities: cities ?? this.cities,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      products: products ?? this.products,
      sellers: sellers ?? this.sellers,
      users: users ?? this.users,
      adminSubcategories: adminSubcategories ?? this.adminSubcategories,
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder
          ? null
          : (selectedOrder ?? this.selectedOrder),
      selectedOrderItems: selectedOrderItems ?? this.selectedOrderItems,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    parameters,
    measurementUnits,
    productParameters,
    categories,
    subcategories,
    reviews,
    bindings,
    cities,
    pickupPoints,
    products,
    sellers,
    users,
    adminSubcategories,
    orders,
    selectedOrder,
    selectedOrderItems,
    stats,
    errorMessage,
  ];
}
