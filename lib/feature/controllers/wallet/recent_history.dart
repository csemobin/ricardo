import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/wallet/wallet_history_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class RecentHistoryController extends GetxController {
  RxBool isWalletLoadingStatus = false.obs;
  RxInt currentPage = 1.obs;
  RxInt limit = 10.obs;

  RxString userRole = ''.obs;
  RxDouble userWallet = 0.0.obs;
  RxDouble allTimeEarnings = 0.0.obs;
  RxDouble todayEarnings = 0.0.obs;
  RxInt len = 200.obs;
  RxList<RecentHistory> recentHistoryList = <RecentHistory>[].obs;


  Future<void> fetchRecentHistory({bool isLoadMore = false}) async {
    try {
      isWalletLoadingStatus.value = true;
      final response = await ApiClient.getData(
          ApiUrls.paymentRecentHistory(currentPage.value, len.value));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body['data'];

        // Convert to double safely - handles both int and double from API
        todayEarnings.value = (data['todayEarnings'] ?? 0).toDouble();
        allTimeEarnings.value = (data['allTimeEarnings'] ?? 0).toDouble();
        userWallet.value = (data['userWallet'] ?? 0).toDouble();
        userRole.value = data['userRole'] ?? '';

        final recentHistories = data['recentHistory'] as List;
        recentHistoryList.value =
            recentHistories.map((e) => RecentHistory.fromJson(e)).toList();
      } else {
        Get.snackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isWalletLoadingStatus.value = false;
    }
  }
}
