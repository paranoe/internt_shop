import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_result.dart';

class CheckoutResultModel extends CheckoutResult {
  const CheckoutResultModel({
    required super.orderId,
    required super.totalAmount,
  });

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResultModel(
      orderId: int.parse(json['order_id'].toString()),
      totalAmount: json['total_amount']?.toString() ?? '0',
    );
  }
}
