import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/home/nearest_driver_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class RideController extends GetxController {
  RxList<NearestDrivers> drivers = <NearestDrivers>[].obs;
  RxList<NearestDrivers> favouriteDrivers = <NearestDrivers>[].obs;

  RxInt selectedTab = 0.obs;

  void changeTab(int val){
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
        final allDrivers = driversList.map((e) => NearestDrivers.fromJson(e)).toList();
        drivers.value = allDrivers;

        favouriteDrivers.value = allDrivers.where((driver) => driver.isFavorite == true).toList();


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

}
