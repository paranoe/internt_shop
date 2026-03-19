class UserCardModel {
  UserCardModel({required this.cardId, required this.cardNumber});

  final int cardId;
  final String cardNumber;

  factory UserCardModel.fromJson(Map<String, dynamic> json) {
    return UserCardModel(
      cardId: json['card_id'] as int,
      cardNumber: (json['card_number'] as String?) ?? '',
    );
  }
}
