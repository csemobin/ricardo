import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class RideController extends GetxController{


  // Fetch Rider Related work are here
  RxBool isRiderDataLoading = false.obs;
  RxBool isRehitLoadingButton = false.obs;
  RxString rideId = ''.obs;

  RxBool isExpanded = false.obs;
  RxInt searchRadiusIndex = 0.obs;
  RxBool rideCancel = false.obs;

  // Nearby Rider Related work are here
  RxBool isButtonShow = false.obs;
  Future<void> fetchRiderData( String id)async{
    try{
      isRiderDataLoading.value = true;

      final response = await ApiClient.getData(ApiUrls.requestAreaRider(id));

      if( response.statusCode == 200 || response.statusCode == 201 ){
        Get.snackbar('Success', response.body['message'], snackPosition: SnackPosition.BOTTOM);

        final List drivers = response.body['data']['drivers'];

        final bool isExpandedValue = response.body['data']['expandSearchRadius']??false;
        final int searchRadiusIndexValue = response.body['data']['searchRadiusIndex'];
        final bool rideCancelValue = response.body['data']['rideCancel']??false;

        isExpanded.value = isExpandedValue;
        searchRadiusIndex.value = searchRadiusIndexValue;
        rideCancel.value = rideCancelValue;

      }else{
        Get.snackbar('Error', response.body['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isRiderDataLoading.value = false;
    }
  }

  //
}