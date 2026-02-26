import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/models/home/nearest_driver_model.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/services/socket_services.dart';

class RideController extends GetxController {
  final val = Get.find<GoogleSearchLocationController>();
  RxBool isSwippedButtonShow = false.obs;

  /*Map handle Related work are here Start */

  RxBool viewInMap = true.obs;
  RxBool viewInMapReturn = false.obs;
  // Add this method to handle view in map toggle
  void toggleViewInMap() {
    viewInMap.value = false;
    viewInMapReturn.value = true;
  }

  // Add this method to return to normal view
  void returnToNormalView() {
    viewInMap.value = true;
    viewInMapReturn.value = false;
  }
  /*Map handle Related work are here Start */

  // Mapped Swipped Button
  RxList<NearestDrivers> drivers = <NearestDrivers>[].obs;
  RxList<NearestDrivers> favouriteDrivers = <NearestDrivers>[].obs;

  RxInt selectedTab = 0.obs;

  void changeTab(int val) {
    selectedTab.value = val;
  }

  // Fetch Rider Related work are here
  RxBool isRiderDataLoading = false.obs;
  RxBool isRehitLoadingButton = false.obs;
  RxString rideId = ''.obs;

  RxBool isExpanded = false.obs;
  RxInt searchRadiusIndex = 0.obs;
  RxBool rideCancel = false.obs;

  // Nearby Rider Related work are here
  RxBool isButtonShow = false.obs;


  Future<void> fetchRiderData(String id) async {
    try {
      isRiderDataLoading.value = true;

      final response = await ApiClient.getData(ApiUrls.requestAreaRider(id));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', response.body['message'],
            snackPosition: SnackPosition.BOTTOM);

        final List driversList = response.body['data']['drivers'];

        // All Drivers are here
        final allDrivers =
            driversList.map((e) => NearestDrivers.fromJson(e)).toList();
        drivers.value = allDrivers;

        favouriteDrivers.value =
            allDrivers.where((driver) => driver.isFavorite == true).toList();

        final bool isExpandedValue =
            response.body['data']['expandSearchRadius'] ?? false;
        final int searchRadiusIndexValue =
            response.body['data']['searchRadiusIndex'];
        final bool rideCancelValue =
            response.body['data']['rideCancel'] ?? false;

        isExpanded.value = isExpandedValue;
        searchRadiusIndex.value = searchRadiusIndexValue;
        rideCancel.value = rideCancelValue;
      } else {
        Get.snackbar('Error', response.body['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isRiderDataLoading.value = false;
    }
  }

  //Request A Ride Related Controller are here
  RxBool isRequestBookRide = false.obs;
  RxBool isRideAccepted = false.obs;
  RxString acceptedRideDriverName = ''.obs;
  Rx<AcceptRideModel?> acceptRideModel = Rx<AcceptRideModel?>(null);
  Future<void> fetchSendPickUpRequest(String riderId, String driverId) async {
    try {
      isRequestBookRide.value = true;

      final response =
          await ApiClient.getData(ApiUrls.sendPickUpRequest(riderId, driverId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        SocketServices.socket?.on(
          'ride-accepted',
              (data) {
            if (data is Map<String, dynamic>) {

              if (data['isRideAccepted'] == true) {
                isRideAccepted.value = true;

                acceptedRideDriverName.value =
                    data['driver']?['driverName'] ?? '';

                // ✅ Convert JSON to Model
                acceptRideModel.value = AcceptRideModel.fromJson(data);
              }
            }

            debugPrint('================ Socket ride accepted data ================');
            Logger().e(data);

            debugPrint('================ Socket ride accepted data ================');
            debugPrint('================ String converstion ================');

            print(acceptRideModel.value);
          },
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isRequestBookRide.value = false;
    }
  }

  Future<void> cancelRequest(String riderId, String driverId) async {
    final response =
        await ApiClient.getData(ApiUrls.cancelRequest(riderId, driverId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Error', response.body['message']);
    } else {
      Get.snackbar('Error', response.body['message']);
    }
  }
}
