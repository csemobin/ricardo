import 'dart:ffi';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';

class MapOPTController extends GetxController{
  // Controller are here
  final userController = Get.find<UserController>();

  RxBool isFirstStep = false.obs;

  @override
  void onInit(){
    getLocation();
    super.onInit();
  }

  //***************************************************
  // ******* Current Location Related work are here****
  // ***************************************************

  RxString currentLocation = 'Fetching location...'.obs;
  RxDouble? currentLatitudePosition = 0.0.obs;
  RxDouble? currentLongitudePosition = 0.0.obs;

  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLatitudePosition?.value = position.latitude;
      currentLongitudePosition?.value = position.longitude;

      // Convert coordinates to address using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

          currentLocation.value =
          '${place.street}, ${place.subLocality}, ${place.locality}';

      }
    } catch (e) {
      // ✅ Fallback to user address from API if location fails
        currentLocation.value = 'Location not available';
    }
  }

//***************************************************
// ******* Marker Related work are here ****
// ***************************************************
}