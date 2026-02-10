import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ricardo/feature/models/home/place_suggestion.dart';

class PlacesService {
  static final String apiKey = dotenv.env['MAP_API_KEY'] ?? 'AIzaSyDRtHHeHvKyg74x9nIG9gHufZbDYZs6Ue4';

  static Future<List<PlaceSuggestion>> getPlaceSuggestions(String input, {
    String countryCode = 'us',
  }) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey');

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

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async{
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'
    );

    try{
      final response = await http.get(url);
      if( response.statusCode == 200 || response.statusCode == 201 ){
        final json = jsonDecode(response.body);
        return PlaceDetails.fromJson(json['result']);
      }
    }catch(e){
      print(e.toString());
    }
    return null;
  }

}
