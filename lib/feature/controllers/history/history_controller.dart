import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/history/complete_ride_history.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class HistoryController extends GetxController{

  final RxBool isHistoryFetchStatus = false.obs;
  RxList<CompleteRideHistoryModel?> historyDatas = <CompleteRideHistoryModel?>[].obs;

  Future<void> fetchHistoryData() async{
    try{
      isHistoryFetchStatus.value = true;
      final response = await ApiClient.getData(ApiUrls.rideHistory);
      if( response.statusCode == 200 || response.statusCode == 201 ){
        final List datas = response.body['data'];
        historyDatas.value = datas.map((e)=> CompleteRideHistoryModel.fromJson(e)).toList();
      }else{
        Get.snackbar('Error', response.body['data']['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isHistoryFetchStatus.value = false;
    }
  }
}