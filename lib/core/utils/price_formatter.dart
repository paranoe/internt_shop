class PriceFormatter {
  PriceFormatter._();

  static String format(String value, {String? currency}) {
    final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0;

    final text = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    if (currency == null || currency.trim().isEmpty) {
      return text;
    }

    return '$text ${currency.trim()}';
  }
}
