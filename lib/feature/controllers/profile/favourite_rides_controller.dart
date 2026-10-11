import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/profile/favourites_rides_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';

class FavouriteRidesController extends GetxController{
  RxBool isLoadingStatus = false.obs;
  RxList<FavouritesRiderModel> favouriteRiderModel = <FavouritesRiderModel>[].obs;

  Future<void> fetchFavouriteRides()async{
    try{
      isLoadingStatus.value = true;
      final response = await ApiClient.getData(ApiUrls.favouriteRides);

      if( response.statusCode == 200 || response.statusCode == 201 ){
        final List data = response.body['data'];
        print('==================>>>>>>$data');

        favouriteRiderModel.value = data.map((e)=> FavouritesRiderModel.fromJson(e)).toList();
      }else{
        showSnackbar('Error', response.body['data']['message']);
      }
    }catch(e){
      debugPrint(e.toString());
    }finally{
      isLoadingStatus.value = false;
    }
  }
  
  RxBool deleteFavouriteRideStatus = false.obs;
  Future<void>deleteFavouriteRide( String riderId )async{
    try{
      deleteFavouriteRideStatus.value = true;
      final response = await ApiClient.deleteData(ApiUrls.favouriteRiderDelete(riderId));
      if( response.statusCode == 200 || response.statusCode == 201 ){
        favouriteRiderModel.removeWhere((rider) => rider.driverId.toString() == riderId);
        showSnackbar('Success', 'Ride removed from favourites.',snackPosition: SnackPosition.BOTTOM);
      }else{
        showSnackbar('Error', response.body['message'],snackPosition: SnackPosition.BOTTOM);
      }

    }catch(e){
      debugPrint(e.toString());
    }finally{
      deleteFavouriteRideStatus.value = false;
    }
  }

}