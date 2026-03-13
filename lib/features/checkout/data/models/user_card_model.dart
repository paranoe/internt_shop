import 'package:diplomeprojectmobile/features/checkout/domain/entities/user_card.dart';

class UserCardModel extends UserCardEntity {
  const UserCardModel({required super.cardId, required super.cardNumber});

  factory UserCardModel.fromJson(Map<String, dynamic> json) {
    return UserCardModel(
      cardId: int.parse(json['card_id'].toString()),
      cardNumber: json['card_number']?.toString() ?? '',
    );
  }
}
