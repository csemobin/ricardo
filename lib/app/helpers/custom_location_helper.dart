import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/feature/view/home/map/helpers/location_bootstrap_helper.dart';

class CustomLocationHelper{
  static Future<LatLng> getCurrentLocation() async {
    bool serviceEnable;
    LocationPermission permission;

    //Check if location service is enabled
    serviceEnable = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnable) {
      return Future.error('Location Services are disable');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location Permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location Permission Permanently denied.Enable from settings");
    }

    final Position? position = await resolveInitialPosition();
    if (position == null) {
      return Future.error('Could not get current location');
    }

    return LatLng(position.latitude, position.longitude);
  }
}
