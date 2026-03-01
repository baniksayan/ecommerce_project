class CartPricing {
  CartPricing._();

  static const double freeDeliveryThreshold = 99.0;
  static const double smallOrderThreshold = 49.0;
  static const double deliveryChargeThreshold = 19.0;

  static const double deliveryChargeAmount = 30.0;
  static const double smallOrderSurchargeAmount = 20.0;
  static const double handlingChargeAmount = 10.0;

  static double remainingForFreeDelivery(double subtotal) {
    if (subtotal >= freeDeliveryThreshold) return 0.0;
    final remaining = freeDeliveryThreshold - subtotal;
    return remaining < 0 ? 0.0 : remaining;
  }
}
