import 'dart:convert';

enum AddressSource { auto, manual }

class LocationSnapshot {
  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final DateTime updatedAt;

  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.formattedAddress,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'formattedAddress': formattedAddress,
    'updatedAt': updatedAt.toIso8601String(),
  };

  static LocationSnapshot fromJson(Map<String, dynamic> json) {
    return LocationSnapshot(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      formattedAddress: json['formattedAddress'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String toRawJson() => jsonEncode(toJson());

  static LocationSnapshot fromRawJson(String raw) =>
      fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

class ManualAddress {
  final String id;
  final String label;
  final String addressLine;
  final String? landmark;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime updatedAt;

  const ManualAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.updatedAt,
    this.landmark,
    this.city,
    this.state,
    this.postalCode,
  });

  String get formatted {
    final parts = <String>[
      addressLine,
      if (landmark != null && landmark!.trim().isNotEmpty)
        'Landmark: ${landmark!.trim()}',
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        postalCode!.trim(),
    ];

    return parts.where((e) => e.trim().isNotEmpty).join(', ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'addressLine': addressLine,
    'landmark': landmark,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'updatedAt': updatedAt.toIso8601String(),
  };

  static ManualAddress fromJson(Map<String, dynamic> json) {
    return ManualAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      addressLine: json['addressLine'] as String,
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class AddressCache {
  final LocationSnapshot? autoLocation;
  final List<ManualAddress> manualAddresses;
  final String selectedAddressId;

  const AddressCache({
    required this.autoLocation,
    required this.manualAddresses,
    required this.selectedAddressId,
  });

  ManualAddress? get selectedManual {
    for (final a in manualAddresses) {
      if (a.id == selectedAddressId) return a;
    }
    return null;
  }

  bool get isAutoSelected => selectedAddressId == AddressRepositoryKeys.autoId;
}

class AddressRepositoryKeys {
  static const String boxName = 'addresses_cache_v1';

  static const String autoId = 'auto';

  static const String kAutoLocation = 'auto_location';
  static const String kManualAddresses = 'manual_addresses';
  static const String kSelectedAddressId = 'selected_address_id';
  static const String kFirstInstallCompleted = 'first_install_completed';
}
