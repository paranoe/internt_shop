import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart.dart';

enum CartStatus { initial, loading, success, error }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.errorMessage,
  });

  final CartStatus status;
  final Cart? cart;
  final String? errorMessage;

  CartState copyWith({
    CartStatus? status,
    Cart? cart,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage];
}
