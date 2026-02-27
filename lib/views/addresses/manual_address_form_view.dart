import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/buttons/app_button.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/location/address_location_coordinator.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/address_models.dart';
import '../main/main_view.dart';

class ManualAddressFormView extends StatefulWidget {
  final int currentBottomBarIndex;
  final ManualAddress? existing;

  const ManualAddressFormView({
    super.key,
    required this.currentBottomBarIndex,
    this.existing,
  });

  @override
  State<ManualAddressFormView> createState() => _ManualAddressFormViewState();
}

class _ManualAddressFormViewState extends State<ManualAddressFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pinCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _labelCtrl = TextEditingController(text: existing?.label ?? 'Home');
    _addressCtrl = TextEditingController(text: existing?.addressLine ?? '');
    _landmarkCtrl = TextEditingController(text: existing?.landmark ?? '');
    _cityCtrl = TextEditingController(text: existing?.city ?? '');
    _stateCtrl = TextEditingController(text: existing?.state ?? '');
    _pinCtrl = TextEditingController(text: existing?.postalCode ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final existing = widget.existing;

      final address = ManualAddress(
        id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        label: _labelCtrl.text.trim(),
        addressLine: _addressCtrl.text.trim(),
        landmark: _landmarkCtrl.text.trim().isEmpty
            ? null
            : _landmarkCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
        postalCode: _pinCtrl.text.trim().isEmpty ? null : _pinCtrl.text.trim(),
        updatedAt: now,
      );

      await AddressLocationCoordinator.instance.upsertManualAddress(address);

      if (!mounted) return;
      AppSnackbar.success(
        context,
        existing == null ? 'Address added' : 'Address updated',
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Could not save address');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;

    final isEditing = widget.existing != null;

    InputDecoration decoration(String hint) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.25),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      );
    }

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
          isEditing ? 'Edit Address' : 'Add Address',
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
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Address details',
                style: AppTextStyles.caption.copyWith(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _labelCtrl,
                textInputAction: TextInputAction.next,
                decoration: decoration('Label (e.g., Home, Work)'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Please enter a label';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: decoration('Address line'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Please enter your address';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _landmarkCtrl,
                textInputAction: TextInputAction.next,
                decoration: decoration('Landmark (optional)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: decoration('City (optional)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: decoration('State (optional)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: decoration('PIN code (optional)'),
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                text: isEditing ? 'Save Changes' : 'Save Address',
                isFullWidth: true,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
