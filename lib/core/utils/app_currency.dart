class AppCurrency {
  static const String symbol = '₹';

  static String format(
    double amount, {
    int decimals = 2,
    bool freeForZero = true,
  }) {
    if (freeForZero && amount == 0) return 'FREE';
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }
}
