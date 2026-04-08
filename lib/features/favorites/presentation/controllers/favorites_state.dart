import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';

enum FavoritesStatus { initial, loading, success, error }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final FavoritesStatus status;
  final List<CartItem> items;
  final String? errorMessage;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<CartItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
