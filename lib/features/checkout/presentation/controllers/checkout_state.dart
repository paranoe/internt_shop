import 'package:equatable/equatable.dart';

import '../../domain/entities/checkout_preview.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/pickup_point.dart';
import '../../domain/entities/user_card.dart';

enum CheckoutStatus { initial, loading, success, error, submitting }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.preview,
    this.cities = const [],
    this.pickupPoints = const [],
    this.paymentMethods = const [],
    this.userCards = const [],
    this.selectedCity,
    this.selectedPickupPoint,
    this.selectedPaymentMethod,
    this.selectedCard,
    this.errorMessage,
    this.createdOrderId,
  });

  final CheckoutStatus status;
  final CheckoutPreview? preview;
  final List<City> cities;
  final List<PickupPoint> pickupPoints;
  final List<PaymentMethod> paymentMethods;
  final List<UserCardEntity> userCards;
  final City? selectedCity;
  final PickupPoint? selectedPickupPoint;
  final PaymentMethod? selectedPaymentMethod;
  final UserCardEntity? selectedCard;
  final String? errorMessage;
  final int? createdOrderId;

  CheckoutState copyWith({
    CheckoutStatus? status,
    CheckoutPreview? preview,
    List<City>? cities,
    List<PickupPoint>? pickupPoints,
    List<PaymentMethod>? paymentMethods,
    List<UserCardEntity>? userCards,
    City? selectedCity,
    PickupPoint? selectedPickupPoint,
    PaymentMethod? selectedPaymentMethod,
    UserCardEntity? selectedCard,
    String? errorMessage,
    int? createdOrderId,
    bool clearError = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      preview: preview ?? this.preview,
      cities: cities ?? this.cities,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      userCards: userCards ?? this.userCards,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedPickupPoint: selectedPickupPoint ?? this.selectedPickupPoint,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedCard: selectedCard ?? this.selectedCard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdOrderId: createdOrderId ?? this.createdOrderId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    preview,
    cities,
    pickupPoints,
    paymentMethods,
    userCards,
    selectedCity,
    selectedPickupPoint,
    selectedPaymentMethod,
    selectedCard,
    errorMessage,
    createdOrderId,
  ];
}
