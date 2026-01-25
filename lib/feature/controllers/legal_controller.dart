import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class LegalController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString legalContent = ''.obs;

  Future<void> fetchLegalData(String url) async {
    try {
      legalContent.value = '';
      isLoading.value = true;

      final response = await ApiClient.getData(ApiUrls.legalContent(url));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body['data']['value'];
        legalContent.value = data;
      } else {
        Get.snackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
