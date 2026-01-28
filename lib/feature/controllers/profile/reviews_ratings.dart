import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/profile/driver_get_ratings.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class ReviewsRatingsController extends GetxController {
  RxBool isReviewsStatus = false.obs;
  RxDouble? ratingAverage = 0.0.obs;
  RxInt? totalRatings = 0.obs;

  RxList<DriverGetRatings> driverRatings = <DriverGetRatings>[].obs;

  Future<void> fetchReviewRating() async {
    try {
      isReviewsStatus.value = true;
      final response = await ApiClient.getData(ApiUrls.driverGetRating);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.body['data']['ratings'];
        driverRatings.value = data.map((e) => DriverGetRatings.fromJson(e)).toList();
        final rating = response.body['data']['ratingAverage'];
        final total = response.body['data']['totalRatings'];
        ratingAverage?.value = rating;
        totalRatings?.value = total;
      } else {
        Get.snackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isReviewsStatus.value = false;
    }
  }
}
