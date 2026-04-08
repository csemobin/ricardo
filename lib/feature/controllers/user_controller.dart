import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';
import 'package:ricardo/feature/models/user_model.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class UserController extends GetxController {
  RxBool isBottomModalSheetStatus = false.obs;
  Rx<UserModel?> userModel = Rx<UserModel?>(null);

  RxBool isUserDataLoadingStatus = false.obs;

  Future<void> fetchUser() async {
    isUserDataLoadingStatus.value = true;

    final response = await ApiClient.getData(ApiUrls.getMe);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.body['data'];
      userModel.value = UserModel.fromJson(data);
      update();
    }
    isUserDataLoadingStatus.value = false;
    update();
  }
  /* ****************************
  * ****** RIDE STATUS RELATED *
  * ****************************/
  // Fetch Ride Status related work are here
  final RxBool isLoadingActiveRideStatus = false.obs;
  final mapOPTController = Get.find<MapOPTController>();
  final rideController = Get.find<RideController>();

  Future<void> fetchActiveRideStatus() async{
    try{
      final response = await ApiClient.getData(ApiUrls.getActiveRide);
      print(response.body);
      if( response.statusCode == 200 || response.statusCode == 201 ){

        SocketServices.socket?.on('ride-status', (data) {
          try {
            Map<String, dynamic> jsonData;

            if (data is List) {
              jsonData = Map<String, dynamic>.from(data[0]);
            } else if (data is String) {
              jsonData = jsonDecode(data);
            } else if (data is Map) {
              jsonData = Map<String, dynamic>.from(data);
            } else {
              return;
            }

            final RideStatusModel rideStatus =
            RideStatusModel.fromJson(jsonData);

            // ✅ Store in controller so UI can react
            mapOPTController.rideStatusData.value = rideStatus;

            if (rideStatus.acceptRide == true) {
              rideController.drivers.clear();
              mapOPTController.isCurrentMarkerShow.value = true;
              // _loadAcceptedRideRoute();
              debugPrint('🚗 ride-status: Driver Accepted');
            } else if (rideStatus.ongoingRide == true) {
              // _loadAcceptedRideRoute();
              debugPrint('🚗 ride-status: Driver arriving');
            } else if (rideStatus.arrivingRide == true) {
              debugPrint('🛣️ ride-status: Ride ongoing');
            } else if (rideStatus.completeRide == true) {
              // ✅ Ride done — clear all state and stop listening
              debugPrint('🏁 ride-status: Ride complete');
              rideController.isRideAccepted.value = false;
              rideController.acceptRideModel.value = null;
              mapOPTController.acceptedRideDriverDataStatus.value = false;
              mapOPTController.acceptedRideDriverData.value = null;
              mapOPTController.isPassengerRequest.value = false;
              mapOPTController.rideStatusData.value = null;
              mapOPTController.rideRequestReceivedAt.value = null;
              PrefsHelper.setString('status', '');
              PrefsHelper.setString('ride-accepted-data', '');
              PrefsHelper.setString('driver-status', '');
              PrefsHelper.setString('ride-accepted-driver-data', '');
              SocketServices.socket
                  ?.off('ride-status'); // ✅ Stop listening after complete
            } else if (rideStatus.driverCancel == true ||
                rideStatus.passengerCancel == true) {
              // ✅ Cancelled — clear all state and stop listening
              debugPrint('❌ ride-status: Ride cancelled');
              rideController.isRideAccepted.value = false;
              rideController.acceptRideModel.value = null;
              mapOPTController.acceptedRideDriverDataStatus.value = false;
              mapOPTController.acceptedRideDriverData.value = null;
              mapOPTController.isPassengerRequest.value = false;
              mapOPTController.rideStatusData.value = null;
              mapOPTController.rideRequestReceivedAt.value = null;
              PrefsHelper.setString('status', '');
              PrefsHelper.setString('ride-accepted-data', '');
              PrefsHelper.setString('driver-status', '');
              PrefsHelper.setString('ride-accepted-driver-data', '');
              SocketServices.socket
                  ?.off('ride-status'); // ✅ Stop listening after cancel
            }
          } catch (e, stackTrace) {
            print('ride-status ERROR: $e');
            print('STACK: $stackTrace');
          }
        });
      }

    }catch(e){
      debugPrint(e.toString());
    }finally{

    }
  }

}