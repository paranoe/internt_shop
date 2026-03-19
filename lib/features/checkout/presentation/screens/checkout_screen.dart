import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/payment_method.dart';
import 'package:diplomeprojectmobile/features/checkout/domain/entities/user_card.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/controllers/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const int _minCardDigits = 12;
  static const int _maxCardDigits = 19;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutController>().load();
    });
  }

  bool _isCardMethod(PaymentMethod? method) {
    if (method == null) return false;

    final name = method.name.trim().toLowerCase();
    return name.contains('card') ||
        name.contains('карт') ||
        name.contains('visa') ||
        name.contains('mastercard');
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _showAddCardDialog() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    final saved =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Добавить карту',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberInputFormatter(maxDigits: _maxCardDigits),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Номер карты',
                          hintText: '1234 5678 9012 3456',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        validator: (value) {
                          final digits = _digitsOnly(value ?? '');

                          if (digits.isEmpty) {
                            return 'Введите номер карты';
                          }

                          if (digits.length < _minCardDigits) {
                            return 'Номер карты слишком короткий';
                          }

                          if (digits.length > _maxCardDigits) {
                            return 'Слишком много цифр';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final ok = await context
                                .read<CheckoutController>()
                                .addCard(_digitsOnly(controller.text));

                            if (!mounted) return;
                            Navigator.of(sheetContext).pop(ok);
                          },
                          child: const Text('Сохранить карту'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Карта добавлена')));
    } else {
      final error = context.read<CheckoutController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _deleteCard(int cardId) async {
    await context.read<CheckoutController>().deleteCard(cardId);

    if (!mounted) return;

    final error = context.read<CheckoutController>().state.errorMessage;
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _submitOrder(CheckoutState state) async {
    if (state.selectedPickupPoint == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите пункт выдачи')));
      return;
    }

    if (_isCardMethod(state.selectedPaymentMethod) &&
        state.selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите карту для оплаты')),
      );
      return;
    }

    await context.read<CheckoutController>().createOrder();
  }

  Widget _buildCardTile(UserCardEntity card, UserCardEntity? selectedCard) {
    final isSelected = selectedCard?.cardId == card.cardId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isSelected ? const Color(0xFFF3F0FF) : Colors.white,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFE6EAF2),
        ),
      ),
      child: ListTile(
        leading: Radio<int>(
          value: card.cardId,
          groupValue: selectedCard?.cardId,
          onChanged: (_) {
            context.read<CheckoutController>().selectCard(card);
          },
        ),
        title: Text(
          card.cardNumber,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('Карта #${card.cardId}'),
        trailing: IconButton(
          onPressed: () => _deleteCard(card.cardId),
          icon: const Icon(Icons.delete_outline),
        ),
        onTap: () {
          context.read<CheckoutController>().selectCard(card);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutController, CheckoutState>(
      listener: (context, state) {
        if (state.createdOrderId != null && state.createdOrderId! > 0) {
          context.go(
            '${AppRoutes.buyerOrderDetails}?id=${state.createdOrderId}',
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          title: const Text('Оформление заказа'),
          centerTitle: true,
        ),
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
                    state.errorMessage ?? 'Не удалось загрузить оформление',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final preview = state.preview;
            if (preview == null) {
              return const Center(child: Text('Нет данных для оформления'));
            }

            final cardPayment = _isCardMethod(state.selectedPaymentMethod);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Состав заказа',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...preview.items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('Количество: ${item.quantity}'),
                      trailing: Text(
                        item.lineTotal,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Город',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: state.selectedCity?.cityId,
                  decoration: const InputDecoration(
                    labelText: 'Выберите город',
                    prefixIcon: Icon(Icons.location_city),
                  ),
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
                const SizedBox(height: 16),
                const Text(
                  'Пункт выдачи',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: state.selectedPickupPoint?.pickupPointId,
                  decoration: const InputDecoration(
                    labelText: 'Выберите ПВЗ',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: state.pickupPoints
                      .map(
                        (point) => DropdownMenuItem(
                          value: point.pickupPointId,
                          child: Text('ПВЗ #${point.pickupPointId}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    final point = state.pickupPoints.firstWhere(
                      (e) => e.pickupPointId == value,
                    );

                    context.read<CheckoutController>().selectPickupPoint(point);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Способ оплаты',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.paymentMethods.map((method) {
                    final isSelected =
                        state.selectedPaymentMethod?.paymentMethodId ==
                        method.paymentMethodId;

                    return ChoiceChip(
                      label: Text(method.name),
                      selected: isSelected,
                      onSelected: (_) {
                        context.read<CheckoutController>().selectPaymentMethod(
                          method,
                        );
                      },
                    );
                  }).toList(),
                ),
                if (cardPayment) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Мои карты',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _showAddCardDialog,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.userCards.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Сохранённых карт пока нет'),
                    )
                  else
                    ...state.userCards.map(
                      (card) => _buildCardTile(card, state.selectedCard),
                    ),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Итого',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${preview.totalAmount} ${preview.currency}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: state.status == CheckoutStatus.submitting
                        ? null
                        : () => _submitOrder(state),
                    child: state.status == CheckoutStatus.submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Подтвердить заказ'),
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

class _CardNumberInputFormatter extends TextInputFormatter {
  _CardNumberInputFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final isGroupEnd = (i + 1) % 4 == 0;
      final isNotLast = i + 1 != digits.length;

      if (isGroupEnd && isNotLast) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
