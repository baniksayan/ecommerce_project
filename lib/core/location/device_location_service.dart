import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/address_models.dart';

class LocationException implements Exception {
  final String code;
  final String message;

  const LocationException(this.code, this.message);

  @override
  String toString() => 'LocationException($code): $message';

  static const String serviceDisabled = 'service_disabled';
  static const String permissionDenied = 'permission_denied';
  static const String permissionDeniedForever = 'permission_denied_forever';
  static const String timeout = 'timeout';
  static const String unknown = 'unknown';
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  Future<LocationSnapshot> getCurrentLocationSnapshot({
    required bool requestPermissionIfNeeded,
    Duration timeLimit = const Duration(seconds: 12),
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        LocationException.serviceDisabled,
        'Location services are disabled.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermissionIfNeeded) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        LocationException.permissionDenied,
        'Location permission denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        LocationException.permissionDeniedForever,
        'Location permission permanently denied.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeLimit,
      );

      final formatted = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      return LocationSnapshot(
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: formatted,
        updatedAt: DateTime.now(),
      );
    } on TimeoutException {
      throw const LocationException(
        LocationException.timeout,
        'Timed out while fetching current location.',
      );
    } catch (e) {
      throw LocationException(LocationException.unknown, e.toString());
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final parts = <String?>[
        p.name,
        p.street,
        p.subLocality,
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.postalCode,
        p.country,
      ];

      final cleaned = <String>[];
      for (final part in parts) {
        if (part == null) continue;
        final value = part.trim();
        if (value.isEmpty) continue;
        if (cleaned.contains(value)) continue;
        cleaned.add(value);
      }

      if (cleaned.isEmpty) return null;
      return cleaned.join(', ');
    } catch (_) {
      return null;
    }
  }
}
