import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/checkout/data/datasources/checkout_api.dart';
import 'package:diplomeprojectmobile/features/checkout/data/repos/checkout_repo_impl.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/payment_method.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/pickup_point.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/user_card.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/add_user_card_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/delete_user_card_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/get_cities_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/get_payment_methods_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/get_pickup_points_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/get_user_cards_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/usecases/preview_checkout_usecase.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/controllers/checkout_state.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';

class CheckoutController extends Cubit<CheckoutState> {
  CheckoutController({required CheckoutApi checkoutApi})
    : _checkoutApi = checkoutApi,
      _previewUseCase = PreviewCheckoutUseCase(_buildRepo(checkoutApi)),
      _getCitiesUseCase = GetCitiesUseCase(_buildRepo(checkoutApi)),
      _getPickupPointsUseCase = GetPickupPointsUseCase(_buildRepo(checkoutApi)),
      _getPaymentMethodsUseCase = GetPaymentMethodsUseCase(
        _buildRepo(checkoutApi),
      ),
      _getUserCardsUseCase = GetUserCardsUseCase(_buildRepo(checkoutApi)),
      _addUserCardUseCase = AddUserCardUseCase(_buildRepo(checkoutApi)),
      _deleteUserCardUseCase = DeleteUserCardUseCase(_buildRepo(checkoutApi)),
      super(const CheckoutState());

  final CheckoutApi _checkoutApi;
  final PreviewCheckoutUseCase _previewUseCase;
  final GetCitiesUseCase _getCitiesUseCase;
  final GetPickupPointsUseCase _getPickupPointsUseCase;
  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  final GetUserCardsUseCase _getUserCardsUseCase;
  final AddUserCardUseCase _addUserCardUseCase;
  final DeleteUserCardUseCase _deleteUserCardUseCase;

  static CheckoutRepoImpl _buildRepo(CheckoutApi checkoutApi) {
    return CheckoutRepoImpl(checkoutApi);
  }

  Future<void> load() async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));

    try {
      final preview = await _previewUseCase();
      final cities = await _getCitiesUseCase();
      final methods = await _getPaymentMethodsUseCase();
      final cards = await _getUserCardsUseCase();

      final selectedCity = cities.isNotEmpty ? cities.first : null;
      final selectedMethod = methods.isNotEmpty ? methods.first : null;
      final selectedCard = cards.isNotEmpty ? cards.first : null;

      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          preview: preview,
          cities: cities,
          paymentMethods: methods,
          userCards: cards,
          selectedCity: selectedCity,
          selectedPaymentMethod: selectedMethod,
          selectedCard: selectedCard,
          clearError: true,
        ),
      );

      if (selectedCity != null) {
        await loadPickupPoints(selectedCity.cityId);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> loadPickupPoints(int cityId) async {
    try {
      final points = await _getPickupPointsUseCase(cityId: cityId);

      final selectedCity =
          state.cities.where((e) => e.cityId == cityId).isNotEmpty
          ? state.cities.firstWhere((e) => e.cityId == cityId)
          : null;

      emit(
        state.copyWith(
          pickupPoints: points,
          selectedCity: selectedCity,
          selectedPickupPoint: points.isNotEmpty ? points.first : null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: ErrorMapper.map(e)));
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(selectedPaymentMethod: method, clearError: true));
  }

  void selectPickupPoint(PickupPoint point) {
    emit(state.copyWith(selectedPickupPoint: point, clearError: true));
  }

  void selectCard(UserCardEntity card) {
    emit(state.copyWith(selectedCard: card, clearError: true));
  }

  Future<bool> addCard(String cardNumber) async {
    try {
      await _addUserCardUseCase(cardNumber: cardNumber);
      final cards = await _getUserCardsUseCase();

      emit(
        state.copyWith(
          userCards: cards,
          selectedCard: cards.isNotEmpty ? cards.last : null,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: ErrorMapper.map(e)));
      return false;
    }
  }

  Future<void> deleteCard(int cardId) async {
    try {
      await _deleteUserCardUseCase(cardId);
      final cards = await _getUserCardsUseCase();

      UserCardEntity? nextSelected;
      if (cards.isNotEmpty) {
        final currentSelectedId = state.selectedCard?.cardId;
        final stillExists = cards.where((e) => e.cardId == currentSelectedId);

        nextSelected = stillExists.isNotEmpty ? stillExists.first : cards.first;
      }

      emit(
        state.copyWith(
          userCards: cards,
          selectedCard: nextSelected,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: ErrorMapper.map(e)));
    }
  }

  Future<int?> createOrder() async {
    final pickup = state.selectedPickupPoint;
    final paymentMethod = state.selectedPaymentMethod;

    if (pickup == null || paymentMethod == null) {
      return null;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting, clearError: true));

    try {
      final result = await _checkoutApi.createOrder(
        pickupPointId: pickup.pickupPointId,
        paymentMethodId: paymentMethod.paymentMethodId,
        cardId: state.selectedCard?.cardId,
      );

      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          createdOrderId: result.orderId,
          clearError: true,
        ),
      );

      return result.orderId;
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
      return null;
    }
  }
}
