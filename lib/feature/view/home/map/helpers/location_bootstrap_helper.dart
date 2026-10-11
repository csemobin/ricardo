import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// GoogleMap [initialCameraPosition] only — never the user's location.
const double kMapFallbackLatitude = 37.7749;
const double kMapFallbackLongitude = -122.4194;

const String kLocationLoadingAddress = 'Getting your location...';

bool isValidLatLng(double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  if (lat.isNaN || lng.isNaN) return false;
  if (lat.abs() < 0.0001 && lng.abs() < 0.0001) return false;
  if (lat.abs() > 90 || lng.abs() > 180) return false;
  return true;
}

/// San Francisco placeholder used only to construct GoogleMap before GPS.
bool isAppFallbackCoordinate(double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  return (lat - kMapFallbackLatitude).abs() < 1e-4 &&
      (lng - kMapFallbackLongitude).abs() < 1e-4;
}

bool isUsableDevicePosition(Position position) {
  return isValidLatLng(position.latitude, position.longitude) &&
      !isAppFallbackCoordinate(position.latitude, position.longitude);
}

bool isUnknownAddressText(String? value) {
  if (value == null) return true;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return true;
  final lower = trimmed.toLowerCase();
  return lower == 'unknown' ||
      lower == 'unnamed road' ||
      lower == 'null' ||
      lower.contains('unknown address') ||
      lower == 'fetching location...' ||
      lower == 'getting your location...' ||
      lower == 'location not available' ||
      lower == 'no address found';
}

/// Fresh device GPS only. OS last-known / other-app cache is never returned —
/// on first install that is often a stale city and was shown as the user.
Future<Position?> resolveInitialPosition() async {
  final completer = Completer<Position?>();
  StreamSubscription<Position>? sub;
  Timer? timeout;

  void finish(Position? pos) {
    if (!completer.isCompleted) completer.complete(pos);
  }

  void accept(Position pos) {
    if (!isUsableDevicePosition(pos)) return;
    finish(pos);
  }

  timeout = Timer(const Duration(seconds: 10), () => finish(null));

  unawaited(() async {
    try {
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      accept(current);
    } catch (e) {
      debugPrint('getCurrentPosition(high) failed: $e');
    }
  }());

  try {
    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen(
      accept,
      onError: (Object e) {
        debugPrint('position stream bootstrap failed: $e');
      },
    );
    return await completer.future;
  } catch (e) {
    debugPrint('resolveInitialPosition failed: $e');
    return null;
  } finally {
    timeout.cancel();
    await sub?.cancel();
  }
}

Future<({String firstLine, String secondLine, String full})?>
    reverseGeocodeAddressParts(double lat, double lng) async {
  if (!isValidLatLng(lat, lng)) return null;

  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final parsed = _partsFromPlacemark(placemarks.first);
        if (parsed != null) return parsed;
      }
    } catch (e) {
      debugPrint('placemarkFromCoordinates attempt $attempt failed: $e');
    }
    await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
  }

  return _googleGeocodeFallback(lat, lng);
}

({String firstLine, String secondLine, String full})? _partsFromPlacemark(
  Placemark place,
) {
  String keep(String? value) {
    if (isUnknownAddressText(value)) return '';
    return value!.trim();
  }

  final firstParts = <String>[
    keep(place.street),
    keep(place.subLocality),
  ].where((e) => e.isNotEmpty).toList();

  final secondParts = <String>[
    keep(place.locality),
    keep(place.subAdministrativeArea),
    keep(place.administrativeArea),
    keep(place.country),
  ].where((e) => e.isNotEmpty).toList();

  // Drop duplicates (e.g. locality repeated as subAdministrativeArea).
  final seen = <String>{};
  final secondUnique = <String>[];
  for (final part in secondParts) {
    final key = part.toLowerCase();
    if (seen.add(key)) secondUnique.add(part);
  }

  if (firstParts.isEmpty && secondUnique.isEmpty) return null;

  final firstLine =
      firstParts.isNotEmpty ? firstParts.join(', ') : secondUnique.first;
  final secondLine = firstParts.isEmpty
      ? secondUnique.skip(1).join(', ')
      : secondUnique.join(', ');
  final full = [firstLine, secondLine].where((e) => e.isNotEmpty).join(', ');
  if (isUnknownAddressText(full)) return null;
  return (firstLine: firstLine, secondLine: secondLine, full: full);
}

Future<({String firstLine, String secondLine, String full})?>
    _googleGeocodeFallback(double lat, double lng) async {
  final apiKey = dotenv.env['MAP_API_KEY'] ?? '';
  if (apiKey.isEmpty) return null;

  try {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng&key=$apiKey',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body);
    if (json is! Map || json['status'] != 'OK') return null;
    final results = json['results'];
    if (results is! List || results.isEmpty) return null;

    final formatted = results.first['formatted_address']?.toString() ?? '';
    if (isUnknownAddressText(formatted)) return null;

    final comma = formatted.indexOf(',');
    if (comma <= 0 || comma >= formatted.length - 1) {
      return (firstLine: formatted, secondLine: '', full: formatted);
    }
    return (
      firstLine: formatted.substring(0, comma).trim(),
      secondLine: formatted.substring(comma + 1).trim(),
      full: formatted,
    );
  } catch (e) {
    debugPrint('Google geocode fallback failed: $e');
    return null;
  }
}
