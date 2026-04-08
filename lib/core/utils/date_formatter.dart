class DateFormatter {
  DateFormatter._();

  static String format(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }
}
