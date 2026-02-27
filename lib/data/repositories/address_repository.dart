import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/address_models.dart';

class AddressRepository {
  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box != null) return;
    _box = await Hive.openBox<dynamic>(AddressRepositoryKeys.boxName);
  }

  Box<dynamic> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError('AddressRepository not initialized. Call init() first.');
    }
    return box;
  }

  bool get isFirstInstallCompleted =>
      (_requireBox.get(AddressRepositoryKeys.kFirstInstallCompleted)
          as bool?) ??
      false;

  Future<void> setFirstInstallCompleted(bool value) async {
    await _requireBox.put(AddressRepositoryKeys.kFirstInstallCompleted, value);
  }

  Future<AddressCache> getCache() async {
    final rawAuto = _requireBox.get(AddressRepositoryKeys.kAutoLocation);
    final rawManual = _requireBox.get(AddressRepositoryKeys.kManualAddresses);
    final selectedId =
        (_requireBox.get(AddressRepositoryKeys.kSelectedAddressId)
            as String?) ??
        AddressRepositoryKeys.autoId;

    LocationSnapshot? auto;
    if (rawAuto is String && rawAuto.isNotEmpty) {
      try {
        auto = LocationSnapshot.fromRawJson(rawAuto);
      } catch (_) {
        auto = null;
      }
    }

    final manual = <ManualAddress>[];
    if (rawManual is String && rawManual.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawManual);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              manual.add(ManualAddress.fromJson(item));
            } else if (item is Map) {
              manual.add(
                ManualAddress.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      } catch (_) {
        // ignore
      }
    }

    return AddressCache(
      autoLocation: auto,
      manualAddresses: manual,
      selectedAddressId: selectedId,
    );
  }

  Future<void> saveAutoLocation(LocationSnapshot snapshot) async {
    await _requireBox.put(
      AddressRepositoryKeys.kAutoLocation,
      snapshot.toRawJson(),
    );
  }

  Future<void> setSelectedAddressId(String id) async {
    await _requireBox.put(AddressRepositoryKeys.kSelectedAddressId, id);
  }

  Future<void> upsertManualAddress(ManualAddress address) async {
    final cache = await getCache();
    final list = [...cache.manualAddresses];

    final idx = list.indexWhere((a) => a.id == address.id);
    if (idx >= 0) {
      list[idx] = address;
    } else {
      list.insert(0, address);
    }

    await _requireBox.put(
      AddressRepositoryKeys.kManualAddresses,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteManualAddress(String id) async {
    final cache = await getCache();
    final list = cache.manualAddresses.where((a) => a.id != id).toList();
    await _requireBox.put(
      AddressRepositoryKeys.kManualAddresses,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );

    final selected =
        (_requireBox.get(AddressRepositoryKeys.kSelectedAddressId)
            as String?) ??
        AddressRepositoryKeys.autoId;
    if (selected == id) {
      await setSelectedAddressId(AddressRepositoryKeys.autoId);
    }
  }
}
