import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
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
// *** Socket Accept Ride Driver Model  Response ****
// ***************************************************
  RxBool acceptedRideDriverDataStatus = false.obs;
  Rx<AcceptRideDriverModel?> acceptedRideDriverData =
      Rx<AcceptRideDriverModel?>(null);

  //***************************************************
  // ******* Book a Ride From the Driver  **************
  // ***************************************************

  Future<void> rideAcceptRide(String rideId) async {
    LatLng currentLatLun = await CustomLocationHelper.getCurrentLocation();

    print(
        '===================>>>>>>>>>>>>>>> check $currentLatLun ${currentLatLun.latitude} ${currentLatLun.longitude}');

    final response =
        await ApiClient.postData(ApiUrls.rideAcceptRideByRideId(rideId), {
      "coordinates": [currentLatLun.longitude, currentLatLun.latitude]
    });
    if (response.statusCode != 200 || response.statusCode != 201) {
      Get.snackbar('Error', response.body['message']);
    }
  }

  // ---------------- Tips related work are here
  // -------------------------------------------
  final TextEditingController provideTips = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isTipsSuccess = false.obs;

  Future<bool> provideTipsHandler(String rideId) async {
    if (provideTips.text.trim().isEmpty) {
      isTipsSuccess.value = false;
      return false;
    }

    try {
      isLoading.value = true;

      final response = await ApiClient.postData(
        ApiUrls.sendTips,
        {
          "amount": provideTips.text.trim(),
          "rideId": rideId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isTipsSuccess.value = true;
        provideTips.clear();
        return true;
      } else {
        provideTips.clear();
        isTipsSuccess.value = false;
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      isTipsSuccess.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ------------- Review related work are here
  // -------------------------------------------

  final isAddedFavouriteRiderStatus = false.obs;
  final addedFavourite = false.obs;

  Future<bool> addedFavouriteRide(String driverId) async {
    try {
      isAddedFavouriteRiderStatus.value = true; // ✅ start loading

      final response = await ApiClient.postData(
        ApiUrls.favoriteRider,
        {"driver": driverId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        addedFavourite.value = true;
        return true;
      } else if (response.statusCode == 400 && response.body['message'] == 'Driver already added to favorites') {
        Get.snackbar("Info", "Already added to favorites");
        addedFavourite.value = false;
        return true;
      } else {
        addedFavourite.value = false;
        final message = response.body is Map
            ? response.body['message'] ?? 'Something went wrong'
            : 'Something went wrong';

        Get.snackbar('Error', message);
        return false;
      }
    } catch (e) {
      addedFavourite.value = false;
      Get.snackbar('Error', e.toString());
      debugPrint(e.toString());
      return false; // ✅ FIXED
    } finally {
      isAddedFavouriteRiderStatus.value = false; // ✅ stop loading
    }
  }

  @override
  void dispose() {
    provideTips.dispose();
    super.dispose();
  }
}
