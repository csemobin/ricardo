import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/socket/ride_details_socket_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class MapOPTController extends GetxController {
  // Controller are here
  final userController = Get.find<UserController>();

  @override
  void onInit() {
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
// ******* Offline & Online Related work are here ****
// ***************************************************

  RxBool isDriverSwitchAvailabilityStatus = false.obs;
  Future<void> driverSwitchAvailabilityStatus() async {
    isDriverSwitchAvailabilityStatus.value = true;
    final response = await ApiClient.patch(
      ApiUrls.driverSwitchAvailabilityStatus,
      {
        "location": {
          "type": "Point",
          "coordinates": [
            currentLongitudePosition?.value,
            currentLatitudePosition?.value
          ]
        }
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      userController.fetchUser();
    } else {
      Get.snackbar('Error', response.body['message']);
    }
    isDriverSwitchAvailabilityStatus.value = false;
  }

  //***************************************************
  // ******* Socket Rider Response  ****
  // ***************************************************
  RxBool isPassengerRequest = false.obs;
  Rx<RideDetailsSocketModel?> rideDetailsData =
  Rx<RideDetailsSocketModel?>(null);

  //***************************************************
  // ******* Book a Ride From the Driver  **************
  // ***************************************************

  Future<void>rideAcceptRide( String rideId ) async{
    LatLng currentLatLun = await CustomLocationHelper.getCurrentLocation();
    final response = await ApiClient.postData(ApiUrls.rideAcceptRideByRideId(rideId),{
      "coordinates": [
        currentLatLun.longitude,
        currentLatLun.latitude
      ]
    });
    if( response.statusCode == 200 || response.statusCode == 201 ){

    }else{
      Get.snackbar('Error', response.body['message']);
    }
  }

}
