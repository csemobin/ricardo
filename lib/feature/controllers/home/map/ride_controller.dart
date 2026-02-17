import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class RideController extends GetxController{


  // Fetch Rider Related work are here
  RxBool isRiderDataLoading = false.obs;
  Future<void> fetchRiderData()async{
    try{
      isRiderDataLoading.value = true;
      final response = await ApiClient.getData(ApiUrls.imageBaseUrl);
      if( response.statusCode == 200 || response.statusCode == 201 ){
        final List data = response.body['data']['rider'];
      }else{
        Get.snackbar('Error', response.body['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isRiderDataLoading.value = true;
    }
  }

  //
}