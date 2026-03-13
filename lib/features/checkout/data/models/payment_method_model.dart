import 'package:diplomeprojectmobile/features/checkout/domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.paymentMethodId,
    required super.name,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      paymentMethodId: int.parse(json['payment_method_id'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }
}
