import 'package:geolocator/geolocator.dart';

class LocationPermissionService {

  //Check if location is enabled
  static Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  //Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  //Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  //Open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  //Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  //Complete location check and request
  static Future<LocationStatus> checkAndRequestLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await isLocationEnabled();

    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();

      if (permission == LocationPermission.denied) {
        return LocationStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }

    return LocationStatus.granted;
  }
}

//Status enum
enum LocationStatus {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}