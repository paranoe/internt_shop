import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/controllers/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutController, CheckoutState>(
      listener: (context, state) {
        if (state.createdOrderId != null && state.createdOrderId! > 0) {
          context.go(
            '${AppRoutes.buyerOrderSuccess}?order_id=${state.createdOrderId}',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: BlocBuilder<CheckoutController, CheckoutState>(
          builder: (context, state) {
            if (state.status == CheckoutStatus.loading &&
                state.preview == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CheckoutStatus.error && state.preview == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Checkout load error',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final preview = state.preview;
            if (preview == null) {
              return const Center(child: Text('No checkout data'));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                ...preview.items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('Qty: ${item.quantity}'),
                      trailing: Text(item.lineTotal),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'City',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    value: state.selectedCity?.cityId,
                    items: state.cities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city.cityId,
                            child: Text(city.cityName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<CheckoutController>().loadPickupPoints(
                          value,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Pickup point',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    value: state.selectedPickupPoint?.pickupPointId,
                    items: state.pickupPoints
                        .map(
                          (point) => DropdownMenuItem(
                            value: point.pickupPointId,
                            child: Text('Pickup #${point.pickupPointId}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final point = state.pickupPoints.firstWhere(
                        (e) => e.pickupPointId == value,
                      );
                      context.read<CheckoutController>().selectPickupPoint(
                        point,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Payment method',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    value: state.selectedPaymentMethod?.paymentMethodId,
                    items: state.paymentMethods
                        .map(
                          (method) => DropdownMenuItem(
                            value: method.paymentMethodId,
                            child: Text(method.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final method = state.paymentMethods.firstWhere(
                        (e) => e.paymentMethodId == value,
                      );
                      context.read<CheckoutController>().selectPaymentMethod(
                        method,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Total: ${preview.totalAmount} ${preview.currency}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.status == CheckoutStatus.submitting
                        ? null
                        : () {
                            context.read<CheckoutController>().createOrder();
                          },
                    child: state.status == CheckoutStatus.submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm order'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
