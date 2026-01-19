import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class ForgetPasswordController extends GetxController{
  final TextEditingController forgetPasswordTEController = TextEditingController();
  RxBool isForgetPasswordStatus = false.obs;

  Future<void> forgetPassword() async{
    isForgetPasswordStatus.value = true;
    final data = {
      "email": forgetPasswordTEController.text.trim()
    };
    final response = await ApiClient.postData(ApiUrls.otpSendForgotPassword, data);

    if( response.statusCode == 200 || response.statusCode == 201 ){
      Get.toNamed(AppRoutes.forgetPasswordOtpVerifyScreen, arguments: {'email': forgetPasswordTEController.text.trim(),'route': 'forget_pass'});
      forgetPasswordTEController.clear();
    }else{
      Get.snackbar('Error', response.body['message']);
    }

    isForgetPasswordStatus.value = false;
  }
  @override
  void onClose() {
    forgetPasswordTEController.dispose();
    super.onClose();
  }
}