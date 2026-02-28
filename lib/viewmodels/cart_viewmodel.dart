import 'dart:async';

import '../data/models/cart_item_model.dart';
import '../data/repositories/cart_repository.dart';
import 'base_viewmodel.dart';

class CartViewModel extends BaseViewModel {
  final CartRepository _repository;
  StreamSubscription<List<CartItemModel>>? _sub;

  static const double freeDeliveryThreshold = 99.0;
  static const double smallOrderThreshold = 49.0;
  static const double deliveryChargeThreshold = 19.0;

  static const double deliveryChargeAmount = 30.0;
  static const double smallOrderSurchargeAmount = 20.0;
  static const double handlingChargeAmount = 10.0;

  List<CartItemModel> _items = const [];
  List<CartItemModel> get items => _items;

  CartViewModel({required CartRepository repository})
    : _repository = repository;

  Future<void> init() async {
    setLoading(true);
    clearError();

    try {
      await _repository.init();
      _sub?.cancel();
      _sub = _repository.watchItems().listen((items) {
        _items = items;
        notifyListeners();
      });
    } catch (e) {
      setError('Failed to load cart.');
    } finally {
      setLoading(false);
    }
  }

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity => _items.fold<int>(0, (sum, e) => sum + e.quantity);

  double get subtotal =>
      _items.fold<double>(0.0, (sum, e) => sum + (e.unitPrice * e.quantity));

  /// Pricing rules:
  /// - Subtotal >= 99: delivery is free + 10 handling charge
  /// - 49 <= Subtotal < 99: +20 small-order surcharge
  /// - Subtotal > 19: +30 delivery charge (unless Subtotal >= 99)
  double get deliveryCharge {
    if (isEmpty) return 0.0;
    if (subtotal >= freeDeliveryThreshold) return 0.0;
    if (subtotal > deliveryChargeThreshold) return deliveryChargeAmount;
    return 0.0;
  }

  double get handlingCharge {
    if (isEmpty) return 0.0;
    if (subtotal >= freeDeliveryThreshold) return handlingChargeAmount;
    return 0.0;
  }

  double get smallOrderSurcharge {
    if (isEmpty) return 0.0;
    if (subtotal < freeDeliveryThreshold && subtotal >= smallOrderThreshold) {
      return smallOrderSurchargeAmount;
    }
    return 0.0;
  }

  double get totalFees => deliveryCharge + handlingCharge + smallOrderSurcharge;

  double get totalAmount => subtotal + totalFees;

  CartItemModel? _find(String productId) {
    for (final item in _items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  Future<void> increment(String productId) async {
    final item = _find(productId);
    if (item == null) return;
    await _repository.setQuantity(productId, item.quantity + 1);
  }

  Future<void> decrement(String productId) async {
    final item = _find(productId);
    if (item == null) return;
    if (item.quantity <= 1) return;
    await _repository.setQuantity(productId, item.quantity - 1);
  }

  Future<void> remove(String productId) async {
    await _repository.removeItem(productId);
  }

  Future<void> add(CartItemModel item) async {
    await _repository.upsertItem(item);
  }

  Future<void> clear() async {
    await _repository.clear();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
