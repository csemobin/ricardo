import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/models/support_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class SupportController extends GetxController {
  final isLoading = false.obs;
  final Rx<SupportModel?> supportModel = Rx<SupportModel?>(null);

  Future<void> fetchSupportData() async {
    try {
      isLoading.value = true;

      final response = await ApiClient.getData(ApiUrls.support);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body['data'];
        supportModel.value = SupportModel.fromJson(data);
      } else {
        Get.snackbar('Error', response.body['message']);
      }
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}