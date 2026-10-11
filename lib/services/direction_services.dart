import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/view/home/map/helpers/location_bootstrap_helper.dart';

class DirectionsService {
  static final String _apiKey = dotenv.env['MAP_API_KEY'] ?? '';

  /// Driving-only Directions URL. Never use walking/transit — those draw
  /// footpaths and cut corners the car must not follow.
  static Uri _directionsUri(LatLng from, LatLng to) {
    return Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${from.latitude},${from.longitude}'
      '&destination=${to.latitude},${to.longitude}'
      '&mode=driving'
      '&overview=full'
      '&units=metric'
      '&key=$_apiKey',
    );
  }

  static Future<({int distanceMeters, int durationSeconds})?> getRouteMetrics(
    LatLng from,
    LatLng to,
  ) async {
    try {
      final res = await http.get(_directionsUri(from, to));

      final data = jsonDecode(res.body);

      if (data['status'] != 'OK') {
        return null;
      }

      final leg = data['routes'][0]['legs'][0];
      return (
        distanceMeters: (leg['distance']['value'] as num).round(),
        durationSeconds: (leg['duration']['value'] as num).round(),
      );
    } catch (e) {
      print('Error fetching route metrics: $e');
      return null;
    }
  }

  static Future<List<LatLng>> getPolyline(LatLng from, LatLng to) async {
    try {
      final res = await http.get(_directionsUri(from, to));

      final data = jsonDecode(res.body);

      if (data['status'] != 'OK') {
        print(
            'Directions API Error: ${data['status']} - ${data['error_message']}');
        return [];
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return [];

      // Prefer detailed DRIVING step geometry (follows curves on the roadway)
      // over simplified overview_polyline, which cuts corners onto footpaths.
      final detailed = _decodeDetailedStepPolyline(routes[0]);
      if (detailed.length >= 2) return detailed;

      final overview = routes[0]['overview_polyline']?['points'];
      if (overview is! String || overview.isEmpty) return [];

      return PolylinePoints()
          .decodePolyline(overview)
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    } catch (e) {
      print('Error fetching directions: $e');
      return [];
    }
  }

  /// Build a high-resolution route from each DRIVING step's encoded polyline.
  /// Walking / access-path steps are skipped so the car never follows a footpath.
  static List<LatLng> _decodeDetailedStepPolyline(dynamic route) {
    try {
      final legs = route['legs'];
      if (legs is! List || legs.isEmpty) return const [];

      final decoder = PolylinePoints();
      final points = <LatLng>[];

      for (final leg in legs) {
        final steps = leg['steps'];
        if (steps is! List) continue;
        for (final step in steps) {
          final travelMode = (step['travel_mode'] as String?)?.toUpperCase();
          // Strict roadway only — skip pedestrian / transit access legs.
          if (travelMode != null &&
              travelMode != 'DRIVING' &&
              travelMode != 'DRIVE') {
            continue;
          }
          final encoded = step['polyline']?['points'];
          if (encoded is! String || encoded.isEmpty) continue;
          final decoded = decoder.decodePolyline(encoded);
          for (final p in decoded) {
            final ll = LatLng(p.latitude, p.longitude);
            if (points.isEmpty ||
                points.last.latitude != ll.latitude ||
                points.last.longitude != ll.longitude) {
              points.add(ll);
            }
          }
        }
      }
      return points;
    } catch (_) {
      return const [];
    }
  }

  Future<String> getCurrentAddress() async {
    try {
      final position = await resolveInitialPosition();
      if (position == null) return kLocationLoadingAddress;

      final parts = await reverseGeocodeAddressParts(
        position.latitude,
        position.longitude,
      );
      return parts?.full ?? kLocationLoadingAddress;
    } catch (e) {
      return kLocationLoadingAddress;
    }
  }

  Future<Map<String, String>> getCurrentAddressParts() async {
    try {
      final position = await resolveInitialPosition();
      if (position == null) {
        return {
          'firstLine': kLocationLoadingAddress,
          'secondLine': '',
        };
      }

      final parts = await reverseGeocodeAddressParts(
        position.latitude,
        position.longitude,
      );
      if (parts == null) {
        return {
          'firstLine': kLocationLoadingAddress,
          'secondLine': '',
        };
      }
      return {
        'firstLine': parts.firstLine,
        'secondLine': parts.secondLine,
      };
    } catch (e) {
      return {
        'firstLine': kLocationLoadingAddress,
        'secondLine': '',
      };
    }
  }

  static Future<String> calculateDistance(double? lng, double? lat) async {
    if (lat == null || lng == null) return 'N/A';

    final googleController = Get.find<GoogleSearchLocationController>();

    final pickup = googleController.selectedPickup.value;
    if (pickup == null) return 'N/A';

    double distanceInMeters = Geolocator.distanceBetween(
      pickup.lat,
      pickup.lng,
      lat,
      lng,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} Meter';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} Kilometer';
    }
  }
}
