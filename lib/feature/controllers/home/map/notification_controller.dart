import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/home/notification_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class NotificationController extends GetxController{

  ScrollController scrollController = ScrollController();

  RxBool isNotificationLoading = false.obs;
  RxBool isLoadMoreNotification = false.obs;

  RxInt limit = 10.obs;
  RxInt page = 1.obs;

  RxList<NotificationModel> notificationData = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationData();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
  }
  void loadMore() {
    if (!isLoadMoreNotification.value) {
      page.value++;
      fetchNotificationData();
    }
  }
  Future<void> fetchNotificationData() async {
    try {
      if (page.value == 1) {
        isNotificationLoading.value = true;
      } else {
        isLoadMoreNotification.value = true;
      }

      final response =
      await ApiClient.getData(ApiUrls.notification(limit.value, page.value));

      if (response.statusCode == 200 || response.statusCode == 201) {

        final List data = response.body['data']['data'];

        final newData =
        data.map((e) => NotificationModel.fromJson(e)).toList();

        if (page.value == 1) {
          notificationData.assignAll(newData); // first load
        } else {
          notificationData.addAll(newData); // append
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isNotificationLoading.value = false;
      isLoadMoreNotification.value = false;
    }
  }
}