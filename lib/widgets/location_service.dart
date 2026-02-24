import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<String> getCurrentAddress() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Location error: $e');
    }

    // Fallback to user address
    return 'Location unavailable';
  }
  // Usage
  static Future<String> showLocation() async {
    String address = await LocationService.getCurrentAddress();
    print('Current address: $address');
    return address;
    // Update UI with address
  }
}

