import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/buttons/app_button.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/location/address_location_coordinator.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/address_models.dart';
import '../main/main_view.dart';
import 'manual_address_form_view.dart';

class MyAddressesView extends StatefulWidget {
  final int currentBottomBarIndex;

  const MyAddressesView({super.key, required this.currentBottomBarIndex});

  @override
  State<MyAddressesView> createState() => _MyAddressesViewState();
}

class _MyAddressesViewState extends State<MyAddressesView> {
  AddressCache? _cache;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cache = await AddressLocationCoordinator.instance.getCache();
    if (!mounted) return;
    setState(() {
      _cache = cache;
      _loading = false;
    });
  }

  void _onBottomBarTap(BuildContext context, int index) {
    if (index == widget.currentBottomBarIndex) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainView(initialIndex: index)),
        (route) => false,
      );
    }
  }

  Future<void> _openAddressPicker(BuildContext context) async {
    final cache = _cache;
    if (cache == null) return;

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
                    await _load();
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
                      'Select address',
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
                  enabled: true,
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

    if (saved == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;

    final cache = _cache;

    final selectedTitle = cache == null
        ? 'Address'
        : (cache.isAutoSelected
              ? 'Current Location'
              : (cache.selectedManual?.label ?? 'Address'));

    final selectedSubtitle = cache == null
        ? ''
        : (cache.isAutoSelected
              ? (cache.autoLocation?.formattedAddress ??
                    (cache.autoLocation != null
                        ? '${cache.autoLocation!.latitude.toStringAsFixed(6)}, ${cache.autoLocation!.longitude.toStringAsFixed(6)}'
                        : 'Not detected yet'))
              : (cache.selectedManual?.formatted ?? ''));

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isIOS ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
            color: onSurface,
          ),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Addresses',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Semantics(
                  label: 'Cart, 2 items',
                  button: true,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.08),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.shopping_cart_outlined, color: primary),
                      tooltip: 'Cart',
                      onPressed: () => HapticFeedback.lightImpact(),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 6,
                  child: IgnorePointer(
                    child: Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: widget.currentBottomBarIndex,
        onTap: (index) => _onBottomBarTap(context, index),
        items: [
          CommonBottomBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          CommonBottomBarItem(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: 'Wishlist',
          ),
          CommonBottomBarItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Orders',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Current selection',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _openAddressPicker(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedTitle,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: theme.iconTheme.color,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  selectedSubtitle.isEmpty
                                      ? '—'
                                      : selectedSubtitle,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: onSurface.withValues(alpha: 0.72),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outline(
                          text: 'Locate Me Again',
                          icon: Icons.my_location_outlined,
                          isFullWidth: true,
                          onPressed: () async {
                            HapticFeedback.selectionClick();
                            try {
                              await AddressLocationCoordinator.instance
                                  .locateMeAgain(context);
                              await _load();
                            } catch (_) {
                              if (mounted) {
                                AppSnackbar.error(
                                  context,
                                  'Could not update location',
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.secondary(
                          text: 'Add Address Manually',
                          icon: Icons.add_location_alt_outlined,
                          isFullWidth: true,
                          onPressed: () => _openManualAddressForm(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Manual addresses',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.disabledColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if ((cache?.manualAddresses ?? []).isEmpty)
                    Text(
                      'No manual addresses added yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.65),
                      ),
                    )
                  else
                    ...cache!.manualAddresses.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _openManualAddressForm(existing: m),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.home_outlined,
                                  color: theme.iconTheme.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.label,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        m.formatted,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: onSurface.withValues(
                                                alpha: 0.7,
                                              ),
                                              height: 1.35,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
