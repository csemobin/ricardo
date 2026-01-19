import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class ResetPasswordController extends GetxController{

  RxBool isResetPasswordStatus = false.obs;
  final TextEditingController resetNewPasswordTEController = TextEditingController();
  final TextEditingController confirmNewPasswordTEController = TextEditingController();

  Future<bool> resetPasswordHandler(String email) async {
    isResetPasswordStatus.value = true;

    final data = {
      "email": email,
      "newPassword": resetNewPasswordTEController.text.trim(),
    };
    try{
      final response = await ApiClient.postData(ApiUrls.resetPassword, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        Get.snackbar('Error', response.body['data']['message']);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset password: ${e.toString()}');
      return false;
    }finally {
      isResetPasswordStatus.value = false;
    }
  }

}