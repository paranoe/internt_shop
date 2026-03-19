import 'package:equatable/equatable.dart';

enum SellerStatus { initial, loading, success, saving, error }

class SellerState extends Equatable {
  const SellerState({
    this.status = SellerStatus.initial,
    this.profile,
    this.products = const [],
    this.orders = const [],
    this.errorMessage,
  });

  final SellerStatus status;
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> orders;
  final String? errorMessage;

  SellerState copyWith({
    SellerStatus? status,
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? orders,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SellerState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      products: products ?? this.products,
      orders: orders ?? this.orders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, products, orders, errorMessage];
}
