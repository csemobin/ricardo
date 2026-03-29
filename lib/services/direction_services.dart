import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ricardo/app/helpers/custom_location_helper.dart';

class DirectionsService {
  // Make sure to enable these APIs in Google Cloud Console:
  // - Maps SDK for Android
  // - Directions API
  // static final String apiKey = dotenv.env['API_KEY'] ?? '';
  static final String _apiKey = dotenv.env['MAP_API_KEY'] ?? '';


  static Future<List<LatLng>> getPolyline(LatLng from, LatLng to) async {
    try {
      final res = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${from.latitude},${from.longitude}'
            '&destination=${to.latitude},${to.longitude}'
            '&key=$_apiKey',
      ));

      final data = jsonDecode(res.body);

      if (data['status'] != 'OK') {
        print('Directions API Error: ${data['status']} - ${data['error_message']}');
        return [];
      }

      return PolylinePoints()
          .decodePolyline(data['routes'][0]['overview_polyline']['points'])
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    } catch (e) {
      print('Error fetching directions: $e');
      return [];
    }
  }

  Future<String> getCurrentAddress() async {
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Convert position to address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
  }

  static Future<String> calculateDistance(double? lng, double? lat) async {
    if (lat == null || lng == null) return 'N/A';

    final LatLng currentLocation = await CustomLocationHelper.getCurrentLocation();

    if (currentLocation.latitude.isNaN || currentLocation.longitude.isNaN) return 'N/A';

    // ⚠️ GeoJSON coordinates are [longitude, latitude] — note the order!
    double distanceInMeters = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      lat,   // ✅ latitude is index [1]
      lng,   // ✅ longitude is index [0]
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

}