import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/appbar/common_app_bar.dart';
import '../../common/buttons/app_button.dart';
import '../../common/cards/app_card.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/location/address_location_coordinator.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_currency.dart';
import '../../data/models/address_models.dart';
import '../../data/repositories/hive_cart_repository.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../addresses/manual_address_form_view.dart';

class CheckoutView extends StatefulWidget {
  final int currentBottomBarIndex;

  const CheckoutView({super.key, this.currentBottomBarIndex = 0});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final CartViewModel _cartVm;

  AddressCache? _addressCache;
  bool _addressLoading = true;

  final TextEditingController _couponCtrl = TextEditingController();
  String? _couponMessage;
  _AppliedCoupon? _appliedCoupon;

  bool _summaryExpanded = true;
  bool _deliveryOptionsExpanded = false;
  bool _needCarryBag = false;

  @override
  void initState() {
    super.initState();
    _cartVm = CartViewModel(repository: HiveCartRepository());
    _cartVm.init();
    _loadAddressCache();
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    _cartVm.dispose();
    super.dispose();
  }

  Future<void> _loadAddressCache() async {
    if (!mounted) return;
    setState(() => _addressLoading = true);
    try {
      final cache = await AddressLocationCoordinator.instance.getCache();
      if (!mounted) return;
      setState(() {
        _addressCache = cache;
        _addressLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _addressLoading = false);
    }
  }

  Future<void> _openManualAddressForm({ManualAddress? existing}) async {
    HapticFeedback.selectionClick();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ManualAddressFormView(
          currentBottomBarIndex: widget.currentBottomBarIndex,
          existing: existing,
        ),
      ),
    );

    if (!mounted) return;
    if (saved == true) {
      await _loadAddressCache();
    }
  }

  String _addressTitle(AddressCache cache) {
    if (cache.isAutoSelected) return 'Current Location';
    return cache.selectedManual?.label ?? 'Delivery Address';
  }

  String _addressSubtitle(AddressCache cache) {
    if (cache.isAutoSelected) {
      final auto = cache.autoLocation;
      return auto?.formattedAddress ??
          (auto != null
              ? '${auto.latitude.toStringAsFixed(6)}, ${auto.longitude.toStringAsFixed(6)}'
              : 'Not detected yet');
    }
    return cache.selectedManual?.formatted ?? '';
  }

  Future<void> _openAddressPicker() async {
    final cache =
        _addressCache ?? await AddressLocationCoordinator.instance.getCache();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final onSurface = theme.colorScheme.onSurface;

        Widget buildTile({
          required String id,
          required String title,
          required String subtitle,
          bool enabled = true,
        }) {
          final selected = cache.selectedAddressId == id;
          return RadioListTile<String>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            visualDensity: VisualDensity.compact,
            value: id,
            groupValue: cache.selectedAddressId,
            onChanged: enabled
                ? (v) async {
                    HapticFeedback.selectionClick();
                    Navigator.pop(ctx);
                    await AddressLocationCoordinator.instance
                        .setSelectedAddressId(
                          v ?? AddressRepositoryKeys.autoId,
                        );
                    if (!mounted) return;
                    await _loadAddressCache();
                  }
                : null,
            title: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled ? onSurface : onSurface.withValues(alpha: 0.5),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: enabled
                    ? onSurface.withValues(alpha: 0.7)
                    : onSurface.withValues(alpha: 0.45),
              ),
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            selected: selected,
          );
        }

        final auto = cache.autoLocation;
        final autoSubtitle =
            auto?.formattedAddress ??
            (auto != null
                ? '${auto.latitude.toStringAsFixed(6)}, ${auto.longitude.toStringAsFixed(6)}'
                : 'Not detected yet');

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select delivery address',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                buildTile(
                  id: AddressRepositoryKeys.autoId,
                  title: 'Current Location',
                  subtitle: autoSubtitle,
                  enabled: false,
                ),
                if (cache.manualAddresses.isNotEmpty) const Divider(height: 1),
                for (final m in cache.manualAddresses)
                  buildTile(id: m.id, title: m.label, subtitle: m.formatted),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _openManualAddressForm();
                      },
                      icon: const Icon(
                        Icons.add_location_alt_outlined,
                        size: 18,
                      ),
                      label: const Text('Add Address Manually'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _itemsLikelyInStockForEstimate() {
    return true;
  }

  String _deliveryEstimateText({required bool inStock}) {
    return inStock
        ? 'Delivery in 30–45 minutes.'
        : 'Delivery may take up to 24 hours.';
  }

  void _applyCoupon() {
    HapticFeedback.selectionClick();
    final code = _couponCtrl.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _couponMessage = 'Enter a coupon code.';
        _appliedCoupon = null;
      });
      return;
    }

    // Static/demo coupon logic for now.
    if (code == 'SAVE10') {
      setState(() {
        _appliedCoupon = const _AppliedCoupon(code: 'SAVE10', percentOff: 10);
        _couponMessage = 'Coupon applied: 10% off items.';
      });
      return;
    }

    if (code == 'FREESHIP') {
      setState(() {
        _appliedCoupon = const _AppliedCoupon(
          code: 'FREESHIP',
          freeDelivery: true,
        );
        _couponMessage = 'Coupon applied: delivery is free.';
      });
      return;
    }

    setState(() {
      _couponMessage = 'Invalid coupon code.';
      _appliedCoupon = null;
    });
  }

  void _removeCoupon() {
    HapticFeedback.selectionClick();
    setState(() {
      _appliedCoupon = null;
      _couponMessage = null;
      _couponCtrl.clear();
    });
  }

  double _discountAmount({
    required double itemsSubtotal,
    required _AppliedCoupon? coupon,
  }) {
    if (coupon == null) return 0.0;
    if (coupon.percentOff != null && coupon.percentOff! > 0) {
      return itemsSubtotal * (coupon.percentOff! / 100.0);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _cartVm,
      builder: (context, _) {
        final cache = _addressCache;

        final itemsSubtotal = _cartVm.subtotal;
        final baseDelivery = _cartVm.deliveryCharge;
        final baseHandling = _cartVm.handlingCharge;
        final baseSmallOrder = _cartVm.smallOrderSurcharge;

        final coupon = _appliedCoupon;
        final delivery = (coupon?.freeDelivery == true) ? 0.0 : baseDelivery;
        final discount = _discountAmount(
          itemsSubtotal: itemsSubtotal,
          coupon: coupon,
        );

        final total =
            (itemsSubtotal - discount) +
            delivery +
            baseHandling +
            baseSmallOrder;

        return Scaffold(
          appBar: CommonAppBar(title: 'Checkout'),
          body: SafeArea(
            child: _cartVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartVm.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Center(
                      child: Text(
                        'Your cart is empty.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    physics: const BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast,
                    ),
                    children: [
                      _CheckoutSectionCard(
                        title: 'Estimated Delivery',
                        trailing: TextButton(
                          onPressed: _openAddressPicker,
                          child: const Text('Change'),
                        ),
                        child: _EstimatedDeliveryContent(
                          addressLoading: _addressLoading,
                          addressTitle: cache == null
                              ? 'Delivery Address'
                              : _addressTitle(cache),
                          addressSubtitle: cache == null
                              ? 'Select an address for delivery'
                              : _addressSubtitle(cache),
                          estimateText: _deliveryEstimateText(
                            inStock: _itemsLikelyInStockForEstimate(),
                          ),
                          note:
                              'Delivery times may vary. Holidays not included.',
                          optionsExpanded: _deliveryOptionsExpanded,
                          needCarryBag: _needCarryBag,
                          onToggleExpanded: () {
                            HapticFeedback.selectionClick();
                            setState(
                              () => _deliveryOptionsExpanded =
                                  !_deliveryOptionsExpanded,
                            );
                          },
                          onCarryBagChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _needCarryBag = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CheckoutSectionCard(
                        title: 'Order Summary',
                        trailing: Tooltip(
                          message: _summaryExpanded ? 'Collapse' : 'Expand',
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _summaryExpanded = !_summaryExpanded,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                _summaryExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        child: _SummaryBreakdown(
                          expanded: _summaryExpanded,
                          itemsSubtotal: itemsSubtotal,
                          discount: discount,
                          delivery: delivery,
                          handling: baseHandling,
                          smallOrderSurcharge: baseSmallOrder,
                          total: total,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CheckoutSectionCard(
                        title: 'Coupon',
                        child: _CouponSection(
                          controller: _couponCtrl,
                          appliedCoupon: _appliedCoupon,
                          message: _couponMessage,
                          onApply: _applyCoupon,
                          onRemove: _removeCoupon,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CheckoutSectionCard(
                        title: 'Payment Method',
                        child: _PaymentMethodCard(),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${AppCurrency.symbol}${total.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppButton.primary(
                    text: 'Place Order',
                    isFullWidth: true,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      AppSnackbar.success(
                        context,
                        'Order placed (demo). Cash on Delivery selected.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckoutSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _CheckoutSectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AddressPreview extends StatelessWidget {
  final bool loading;
  final String title;
  final String subtitle;

  const _AddressPreview({
    required this.loading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final fontSize = AppTextStyles.bodyMedium.fontSize ?? 14.0;
    final iconTopPadding = (fontSize * 0.18).clamp(2.0, 6.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: iconTopPadding),
          child: Icon(
            Icons.location_on_outlined,
            size: 18,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: loading
              ? Text(
                  'Loading address…',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: onSurface.withValues(alpha: 0.75),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: onSurface.withValues(alpha: 0.65),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SummaryBreakdown extends StatelessWidget {
  final bool expanded;
  final double itemsSubtotal;
  final double discount;
  final double delivery;
  final double handling;
  final double smallOrderSurcharge;
  final double total;

  const _SummaryBreakdown({
    required this.expanded,
    required this.itemsSubtotal,
    required this.discount,
    required this.delivery,
    required this.handling,
    required this.smallOrderSurcharge,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    TextStyle rowStyle({bool bold = false, Color? color}) {
      return AppTextStyles.bodyMedium.copyWith(
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        color: color ?? onSurface,
      );
    }

    Widget row(String label, String value, {bool bold = false, Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: rowStyle(
                  bold: bold,
                  color: onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
            Text(
              value,
              style: rowStyle(bold: bold, color: color),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expanded) ...[
          row(
            'Items Subtotal',
            '${AppCurrency.symbol}${itemsSubtotal.toStringAsFixed(2)}',
          ),
          if (discount > 0)
            row(
              'Discount',
              '-${AppCurrency.symbol}${discount.toStringAsFixed(2)}',
              color: theme.primaryColor,
            ),
          row(
            'Delivery Charge',
            delivery <= 0
                ? 'FREE'
                : '${AppCurrency.symbol}${delivery.toStringAsFixed(2)}',
            color: delivery <= 0 ? theme.primaryColor : null,
          ),
          if (smallOrderSurcharge > 0)
            row(
              'Small-order Charge',
              '${AppCurrency.symbol}${smallOrderSurcharge.toStringAsFixed(2)}',
            ),
          if (handling > 0)
            row(
              'Handling Charge',
              '${AppCurrency.symbol}${handling.toStringAsFixed(2)}',
            ),
          Divider(color: theme.dividerColor.withValues(alpha: 0.8)),
        ],
        row(
          'Total Amount',
          '${AppCurrency.symbol}${total.toStringAsFixed(2)}',
          bold: true,
          color: theme.primaryColor,
        ),
      ],
    );
  }
}

class _CouponSection extends StatelessWidget {
  final TextEditingController controller;
  final _AppliedCoupon? appliedCoupon;
  final String? message;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponSection({
    required this.controller,
    required this.appliedCoupon,
    required this.message,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final applied = appliedCoupon != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: !applied,
          decoration: InputDecoration(
            hintText: 'Enter coupon code',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onApply(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                applied
                    ? 'Applied: ${appliedCoupon!.code}'
                    : 'Try: SAVE10 or FREESHIP',
                style: AppTextStyles.caption.copyWith(
                  color: onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            if (applied)
              TextButton(onPressed: onRemove, child: const Text('Remove'))
            else
              AppButton.outline(text: 'Apply', onPressed: onApply),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            style: AppTextStyles.caption.copyWith(
              color: onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.payments_outlined, color: theme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash on Delivery',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Pay in cash when your order arrives.',
                style: AppTextStyles.caption.copyWith(
                  color: onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.check_circle_rounded, color: theme.primaryColor, size: 22),
      ],
    );
  }
}

class _EstimatedDeliveryContent extends StatelessWidget {
  final bool addressLoading;
  final String addressTitle;
  final String addressSubtitle;
  final String estimateText;
  final String note;
  final bool optionsExpanded;
  final bool needCarryBag;
  final VoidCallback onToggleExpanded;
  final ValueChanged<bool> onCarryBagChanged;

  const _EstimatedDeliveryContent({
    required this.addressLoading,
    required this.addressTitle,
    required this.addressSubtitle,
    required this.estimateText,
    required this.note,
    required this.optionsExpanded,
    required this.needCarryBag,
    required this.onToggleExpanded,
    required this.onCarryBagChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final optionBg = theme.primaryColor.withValues(alpha: 0.08);
    final optionBorder = theme.dividerColor.withValues(alpha: 0.70);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddressPreview(
          loading: addressLoading,
          title: addressTitle,
          subtitle: addressSubtitle,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.schedule_rounded,
                size: 20,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estimateText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: AppTextStyles.caption.copyWith(
                      color: onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onToggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'More delivery options',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onSurface.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                Icon(
                  optionsExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: onSurface.withValues(alpha: 0.70),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (optionsExpanded) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: optionBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: optionBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Need a carry bag?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                ),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  constraints: const BoxConstraints(minHeight: 34),
                  isSelected: [needCarryBag, !needCarryBag],
                  onPressed: (index) {
                    onCarryBagChanged(index == 0);
                  },
                  selectedColor: theme.primaryColor,
                  color: onSurface.withValues(alpha: 0.7),
                  fillColor: theme.primaryColor.withValues(alpha: 0.10),
                  borderColor: optionBorder,
                  selectedBorderColor: theme.primaryColor.withValues(
                    alpha: 0.55,
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Yes'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('No'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AppliedCoupon {
  final String code;
  final int? percentOff;
  final bool freeDelivery;

  const _AppliedCoupon({
    required this.code,
    this.percentOff,
    this.freeDelivery = false,
  });
}
