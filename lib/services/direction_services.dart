import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
}