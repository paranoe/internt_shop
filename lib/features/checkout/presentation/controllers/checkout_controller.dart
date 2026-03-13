import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/checkout_api.dart';
import '../../data/repos/checkout_repo_impl.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/pickup_point.dart';
import '../../domain/entities/user_card.dart';
import '../../domain/usecases/add_user_card_usecase.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/delete_user_card_usecase.dart';
import '../../domain/usecases/get_cities_usecase.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import '../../domain/usecases/get_pickup_points_usecase.dart';
import '../../domain/usecases/get_user_cards_usecase.dart';
import '../../domain/usecases/preview_checkout_usecase.dart';
import 'checkout_state.dart';

class CheckoutController extends Cubit<CheckoutState> {
  CheckoutController({required CheckoutApi checkoutApi})
    : _previewUseCase = PreviewCheckoutUseCase(CheckoutRepoImpl(checkoutApi)),
      _getCitiesUseCase = GetCitiesUseCase(CheckoutRepoImpl(checkoutApi)),
      _getPickupPointsUseCase = GetPickupPointsUseCase(
        CheckoutRepoImpl(checkoutApi),
      ),
      _getPaymentMethodsUseCase = GetPaymentMethodsUseCase(
        CheckoutRepoImpl(checkoutApi),
      ),
      _getUserCardsUseCase = GetUserCardsUseCase(CheckoutRepoImpl(checkoutApi)),
      _addUserCardUseCase = AddUserCardUseCase(CheckoutRepoImpl(checkoutApi)),
      _deleteUserCardUseCase = DeleteUserCardUseCase(
        CheckoutRepoImpl(checkoutApi),
      ),
      _createOrderUseCase = CreateOrderUseCase(CheckoutRepoImpl(checkoutApi)),
      super(const CheckoutState());

  final PreviewCheckoutUseCase _previewUseCase;
  final GetCitiesUseCase _getCitiesUseCase;
  final GetPickupPointsUseCase _getPickupPointsUseCase;
  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  final GetUserCardsUseCase _getUserCardsUseCase;
  final AddUserCardUseCase _addUserCardUseCase;
  final DeleteUserCardUseCase _deleteUserCardUseCase;
  final CreateOrderUseCase _createOrderUseCase;

  Future<void> load() async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));

    try {
      final preview = await _previewUseCase();
      final cities = await _getCitiesUseCase();
      final methods = await _getPaymentMethodsUseCase();
      final cards = await _getUserCardsUseCase();

      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          preview: preview,
          cities: cities,
          paymentMethods: methods,
          userCards: cards,
          selectedCity: cities.isNotEmpty ? cities.first : null,
          selectedPaymentMethod: methods.isNotEmpty ? methods.first : null,
          selectedCard: cards.isNotEmpty ? cards.first : null,
          clearError: true,
        ),
      );

      if (cities.isNotEmpty) {
        await loadPickupPoints(cities.first.cityId);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadPickupPoints(int cityId) async {
    try {
      final points = await _getPickupPointsUseCase(cityId: cityId);
      final selectedCity = state.cities.firstWhere((e) => e.cityId == cityId);

      emit(
        state.copyWith(
          pickupPoints: points,
          selectedCity: selectedCity,
          selectedPickupPoint: points.isNotEmpty ? points.first : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }

  void selectPickupPoint(PickupPoint point) {
    emit(state.copyWith(selectedPickupPoint: point));
  }

  void selectCard(UserCardEntity card) {
    emit(state.copyWith(selectedCard: card));
  }

  Future<void> addCard(String cardNumber) async {
    await _addUserCardUseCase(cardNumber: cardNumber);
    final cards = await _getUserCardsUseCase();
    emit(
      state.copyWith(
        userCards: cards,
        selectedCard: cards.isNotEmpty ? cards.last : null,
      ),
    );
  }

  Future<void> deleteCard(int cardId) async {
    await _deleteUserCardUseCase(cardId);
    final cards = await _getUserCardsUseCase();
    emit(
      state.copyWith(
        userCards: cards,
        selectedCard: cards.isNotEmpty ? cards.first : null,
      ),
    );
  }

  Future<int?> createOrder() async {
    final pickup = state.selectedPickupPoint;
    if (pickup == null) return null;

    emit(state.copyWith(status: CheckoutStatus.submitting, clearError: true));

    try {
      final result = await _createOrderUseCase(
        pickupPointId: pickup.pickupPointId,
      );

      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          createdOrderId: result.orderId,
        ),
      );

      return result.orderId;
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return null;
    }
  }
}
