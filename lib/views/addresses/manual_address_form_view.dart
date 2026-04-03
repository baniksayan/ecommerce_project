import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/buttons/app_button.dart';
import '../../common/buttons/cart_icon_button.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/dropdowns/app_dropdown.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/location/address_location_coordinator.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/address_models.dart';
import '../main/main_view.dart';

class _NameTitleCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final words = text.split(' ');
    final normalized = words.map((word) {
      if (word.isEmpty) return word;
      final first = word.substring(0, 1).toUpperCase();
      final rest = word.length > 1 ? word.substring(1).toLowerCase() : '';
      return '$first$rest';
    }).join(' ');

    return TextEditingValue(
      text: normalized,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

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

  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _houseCtrl;
  late final TextEditingController _villageAreaCtrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _instructionsCtrl;
  late final TextEditingController _otherTypeCtrl;

  static const String _fixedState = 'West Bengal';
  static const String _fixedCountry = 'India';
  static const List<String> _availablePincodes = [
    '736132',
    '736168',
    '736132',
    '736134',
    '736157',
    '736156',
    '736170',
  ];

  static const List<String> _addressTypes = ['Home', 'Work', 'Other'];
  late String _selectedAddressType;
  String? _selectedPincode;
  String? _pincodeError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    final initialType = (existing?.label ?? 'Home').trim();
    _selectedAddressType = _addressTypes.contains(initialType)
        ? initialType
        : 'Other';

    _nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    _mobileCtrl = TextEditingController(text: existing?.mobileNumber ?? '');
    _houseCtrl = TextEditingController(text: existing?.houseFlatNo ?? '');
    _villageAreaCtrl = TextEditingController(
      text: existing?.buildingStreetArea ?? '',
    );
    _landmarkCtrl = TextEditingController(text: existing?.landmark ?? '');
    _instructionsCtrl = TextEditingController(
      text: existing?.deliveryInstructions ?? '',
    );
    _selectedPincode = _availablePincodes.contains(existing?.postalCode)
        ? existing?.postalCode
        : null;
    _otherTypeCtrl = TextEditingController(
      text: _selectedAddressType == 'Other' && initialType != 'Other'
          ? initialType
          : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _houseCtrl.dispose();
    _villageAreaCtrl.dispose();
    _landmarkCtrl.dispose();
    _instructionsCtrl.dispose();
    _otherTypeCtrl.dispose();
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
    final isValid = _formKey.currentState!.validate();
    final hasPincode = _selectedPincode != null;

    setState(() {
      _pincodeError = hasPincode ? null : 'Please select a pincode';
    });

    if (!isValid || !hasPincode) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final existing = widget.existing;
      final customType = _otherTypeCtrl.text.trim();
      final resolvedType =
          _selectedAddressType == 'Other' && customType.isNotEmpty
          ? customType
          : _selectedAddressType;
      final digitsOnly = _mobileCtrl.text.replaceAll(RegExp(r'\D'), '');

      final address = ManualAddress(
        id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        label: resolvedType,
        fullName: _nameCtrl.text.trim(),
        mobileNumber: digitsOnly,
        houseFlatNo: _houseCtrl.text.trim(),
        buildingStreetArea: _villageAreaCtrl.text.trim(),
        landmark: _landmarkCtrl.text.trim().isEmpty
            ? null
            : _landmarkCtrl.text.trim(),
        city: null,
        state: _fixedState,
        postalCode: _selectedPincode,
        deliveryInstructions: _instructionsCtrl.text.trim().isEmpty
            ? null
            : _instructionsCtrl.text.trim(),
        mapLatitude: null,
        mapLongitude: null,
        mapAddress: null,
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
          CartIconButton(
            margin: const EdgeInsets.only(right: 12),
            currentBottomBarIndex: widget.currentBottomBarIndex,
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
              Text(
                'Keep it simple: add the details a local delivery partner needs.',
                style: AppTextStyles.caption.copyWith(
                  color: onSurface.withValues(alpha: 0.62),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [_NameTitleCaseFormatter()],
                decoration: decoration('Full Name *'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Please enter full name';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                textInputAction: TextInputAction.next,
                decoration: decoration('Mobile Number *').copyWith(
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Text(
                      '🇮🇳 +91',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  final digits = value.replaceAll(RegExp(r'\D'), '');
                  if (digits.length != 10) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  if (!RegExp(r'^[6-9]').hasMatch(digits)) {
                    return 'Mobile number must start with 6, 7, 8, or 9';
                  }
                  return null;
                },
                buildCounter:
                    (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) => null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _houseCtrl,
                textInputAction: TextInputAction.next,
                decoration: decoration('House / Flat / House Name *'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) {
                    return 'Please enter house/flat/house name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _villageAreaCtrl,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: decoration('Village / Area Name *'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) {
                    return 'Please enter village/area name';
                  }
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
              Text(
                'Address Type (optional)',
                style: AppTextStyles.caption.copyWith(
                  color: onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _addressTypes.map((type) {
                  final selected = _selectedAddressType == type;
                  final IconData? icon = switch (type) {
                    'Home' => Icons.home_rounded,
                    'Work' => Icons.work_rounded,
                    _ => null,
                  };

                  return ChoiceChip(
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 16,
                            color: selected
                                ? theme.primaryColor
                                : onSurface.withValues(alpha: 0.65),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(type),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _selectedAddressType = type;
                    }),
                  );
                }).toList(),
              ),
              if (_selectedAddressType == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherTypeCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: decoration('Other Address Type *'),
                  validator: (v) {
                    if (_selectedAddressType != 'Other') return null;
                    final value = (v ?? '').trim();
                    if (value.isEmpty) {
                      return 'Please enter other address type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  'Example: Farm, Shop, Relative House',
                  style: AppTextStyles.caption.copyWith(
                    color: onSurface.withValues(alpha: 0.58),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              AppDropdown<String>(
                label: 'Pincode *',
                value: _selectedPincode,
                entries: _availablePincodes
                    .map(
                      (p) => DropdownMenuEntry<String>(
                        value: p,
                        label: p,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPincode = value;
                    _pincodeError = null;
                  });
                },
                errorText: _pincodeError,
                helperText: 'Delivery available only in listed pincodes',
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _fixedState,
                enabled: false,
                decoration: decoration('State (auto-filled)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _fixedCountry,
                enabled: false,
                decoration: decoration('Country (auto-filled)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsCtrl,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: decoration('Delivery Instructions (optional)'),
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
