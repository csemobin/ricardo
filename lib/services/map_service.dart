import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ricardo/feature/models/home/place_suggestion.dart';

class PlacesService {
  static final String _apiKey = dotenv.env['MAP_API_KEY'] ?? '';
  
  /// Get place suggestions from Google Places API
  /// 
  /// If [latitude] and [longitude] are provided, the search will be biased
  /// to locations within [radiusInMeters] (default 50km) of that point.
  /// Setting strictbounds=true ensures results are ONLY from within that radius.
  /// 
  /// This restricts search results to the user's current city area.
  static Future<List<PlaceSuggestion>> getPlaceSuggestions(
    String input, {
    String countryCode = 'us',
    double? latitude,
    double? longitude,
    int radiusInMeters = 50000, // 50km radius by default
  }) async {
    if (input.isEmpty) return [];

    // Build URL with location bias if coordinates are provided
    String urlString = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';
    
    // Add location bias to restrict results to user's current city area
    if (latitude != null && longitude != null) {
      urlString += '&location=$latitude,$longitude&radius=$radiusInMeters&strictbounds=true';
    }

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return (json['predictions'] as List)
            .map((p) => PlaceSuggestion.fromJson(p))
            .toList();
      }
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return PlaceDetails.fromJson(json['result']);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
