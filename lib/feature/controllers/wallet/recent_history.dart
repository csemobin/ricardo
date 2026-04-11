import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/wallet/wallet_history_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class RecentHistoryController extends GetxController {
  RxBool isWalletLoadingStatus = false.obs;  // first load
  RxBool isLoadingMore         = false.obs;  // pagination load
  RxBool hasMoreData           = true.obs;   // false when last page reached

  RxInt  currentPage = 1.obs;
  RxInt  limit       = 10.obs;   // items per page

  RxString userRole       = ''.obs;
  RxDouble userWallet     = 0.0.obs;
  RxDouble allTimeEarnings = 0.0.obs;
  RxDouble todayEarnings  = 0.0.obs;

  RxList<RecentHistory> recentHistoryList = <RecentHistory>[].obs;

  bool _hasFetchedOnce = false;

  // ── Called from initState ──────────────────────────────────────
  Future<void> fetchIfNeeded() async {
    if (_hasFetchedOnce && recentHistoryList.isNotEmpty) return;
    await _fetchPage(page: 1, isRefresh: true);
  }

  // ── Called from RefreshIndicator ───────────────────────────────
  Future<void> forceRefresh() async {
    await _fetchPage(page: 1, isRefresh: true);
  }

  // ── Called from scroll listener (load more) ────────────────────
  Future<void> loadMore() async {
    // Block if: already loading, no more data, or first load in progress
    if (isLoadingMore.value || !hasMoreData.value || isWalletLoadingStatus.value) return;
    await _fetchPage(page: currentPage.value + 1, isRefresh: false);
  }

  // ── Core fetch ─────────────────────────────────────────────────
  Future<void> _fetchPage({required int page, required bool isRefresh}) async {
    try {
      // Show appropriate loader
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

        // Wallet summary — only update on first page
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
          // Replace entire list on refresh
          recentHistoryList.value = newItems;
        } else {
          // Append new items on load more
          recentHistoryList.addAll(newItems);
        }

        // If returned items < limit → we've hit the last page
        hasMoreData.value  = newItems.length >= limit.value;
        currentPage.value  = page;
        _hasFetchedOnce    = true;

      } else {
        Get.snackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isWalletLoadingStatus.value = false;
      isLoadingMore.value         = false;
    }
  }
}