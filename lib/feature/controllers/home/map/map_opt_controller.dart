import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ricardo/app/helpers/custom_location_helper.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_driver_model.dart';
import 'package:ricardo/feature/models/socket/get_ride_driver_location.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/feature/view/home/map/driver_location_service.dart';
import 'package:ricardo/services/api_client.dart';

class MapOPTController extends GetxController {
  // Controller are here
  UserController? _userController;
  UserController get userController => _userController ??= Get.find<UserController>();
  RxBool isCurrentMarkerShow = true.obs;
  RxBool showCancelReasonDialog = false.obs;
  final Rx<GetRideDriverLocation?> getRideDriverLocation = Rx<GetRideDriverLocation?>(null);

  @override
  void onInit() {
    getLocation();
    super.onInit();
  }
  Timer? _rideRequestTimer;
  RxDouble timerProgress = 1.0.obs;
  RxBool isRideRequestExpired = false.obs;

  void startRideRequestTimer() {
    _rideRequestTimer?.cancel();

    final timeoutMinutes =
        int.tryParse(dotenv.env['RIDE_MODAL_EXPIRE_TIME'] ?? '') ?? 2;
    final totalMillis = timeoutMinutes * 60 * 1000;
    final startTime = DateTime.now();

    timerProgress.value = 1.0;
    isRideRequestExpired.value = false;

    _rideRequestTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final remaining = totalMillis - elapsed;

        if (remaining <= 0) {
          timerProgress.value = 0.0;
          isRideRequestExpired.value = true;
          timer.cancel();
        } else {
          timerProgress.value = remaining / totalMillis;
        }
      },
    );
  }

  void cancelRideRequestTimer() {
    _rideRequestTimer?.cancel();
    _rideRequestTimer = null;
    timerProgress.value = 1.0;
    isRideRequestExpired.value = false;
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

  Rx<DateTime?> rideRequestReceivedAt = Rx<DateTime?>(null);  // tracks when request arrived
  Rx<RideStatusModel?> rideStatusData = Rx<RideStatusModel?>(null); // ride-status socket data

  //***************************************************
// *** Socket Accept Ride Driver Model  Response ****
// ***************************************************
  RxBool acceptedRideDriverDataStatus = false.obs;
  Rx<AcceptRideDriverModel?> acceptedRideDriverData =
      Rx<AcceptRideDriverModel?>(null);

  //***************************************************
  // ******* Book a Ride From the Driver  **************
  // ***************************************************
  final isRideAcceptStatus = false.obs;

  Future<void> rideAcceptRide(String rideId) async {
    isRideAcceptStatus.value = true;
    LatLng currentLatLun = await CustomLocationHelper.getCurrentLocation();

    final response =
    await ApiClient.postData(ApiUrls.rideAcceptRideByRideId(rideId), {
      "coordinates": [currentLatLun.longitude, currentLatLun.latitude]
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Ride accepted');
      DriverLocationService().startEmitting(rideId);
      DriverLocationService().listenResponse((data) {
        print(data);
      },);
      isRideAcceptStatus.value = false;
      // SocketServices.socket?.emit('get-driver-location', {
      //   'rideId': rideId
      // });
      //
      // SocketServices.socket?.on("get-ride-driver-location", (data) {
      //   print('📍 Driver location: $data');
      // });
      // SocketServices.socket?.onAny((event, data) {
      //   print('📡 $event => $data');
      // });
    } else {
      isRideAcceptStatus.value = false;
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

  // Ride Status change are here
  Future<void>rideStatusChange( String rideId, String status ) async {
    try{
      final response = await ApiClient.postData(ApiUrls.rideChangeRideStatus(rideId),
          {
            "status": status
          });
      if( response.statusCode == 200 || response.statusCode == 201 ){
        print(response.body);
          print('asdjfklajsdflkjasdl');
      }else{
        Get.snackbar('error', response.body['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{

    }
  }

  @override
  void dispose() {
    provideTips.dispose();
    _rideRequestTimer?.cancel(); // ✅ add this
    DriverLocationService().stop();
    super.dispose();
  }
}
