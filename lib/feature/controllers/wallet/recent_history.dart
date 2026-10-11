import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/wallet/wallet_history_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';

class RecentHistoryController extends GetxController {
  RxBool isWalletLoadingStatus = false.obs;
  RxBool isLoadingMore         = false.obs;
  RxBool hasMoreData           = true.obs;

  RxInt  currentPage = 1.obs;
  RxInt  limit       = 10.obs;

  RxString userRole       = ''.obs;
  RxDouble userWallet     = 0.0.obs;
  RxDouble allTimeEarnings = 0.0.obs;
  RxDouble todayEarnings  = 0.0.obs;

  RxList<RecentHistory> recentHistoryList = <RecentHistory>[].obs;

  bool _hasFetchedOnce = false;
  Future<void> fetchIfNeeded() async {
    if (_hasFetchedOnce && recentHistoryList.isNotEmpty) return;
    await _fetchPage(page: 1, isRefresh: true);
  }
  Future<void> forceRefresh() async {
    await _fetchPage(page: 1, isRefresh: true);
  }
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMoreData.value || isWalletLoadingStatus.value) return;
    await _fetchPage(page: currentPage.value + 1, isRefresh: false);
  }
  Future<void> _fetchPage({required int page, required bool isRefresh}) async {
    try {
      if (isRefresh) {
        isWalletLoadingStatus.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await ApiClient.getData(
        ApiUrls.paymentRecentHistory(page, limit.value),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body['data'];
        if (page == 1) {
          todayEarnings.value    = (data['todayEarnings']   ?? 0).toDouble();
          allTimeEarnings.value  = (data['allTimeEarnings'] ?? 0).toDouble();
          userWallet.value       = (data['userWallet']      ?? 0).toDouble();
          userRole.value         = data['userRole']         ?? '';
        }

        final newItems = (data['recentHistory'] as List)
            .map((e) => RecentHistory.fromJson(e))
            .toList();

        if (isRefresh) {
          recentHistoryList.value = newItems;
        } else {
          recentHistoryList.addAll(newItems);
        }
        hasMoreData.value  = newItems.length >= limit.value;
        currentPage.value  = page;
        _hasFetchedOnce    = true;

      } else {
        showSnackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isWalletLoadingStatus.value = false;
      isLoadingMore.value         = false;
    }
  }
}