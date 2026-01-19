import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class SignInController extends GetxController {
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  RxBool canSubmit = false.obs;
  RxBool isLoginStatus = false.obs;

  @override
  void onInit(){
    super.onInit();
    emailTextEditingController.addListener(_checkSubmit);
    passwordTextEditingController.addListener(_checkSubmit);
  }

  void _checkSubmit() {
    canSubmit.value =
        emailTextEditingController.text.isNotEmpty &&
            passwordTextEditingController.text.isNotEmpty;
  }


  Future<void> logInUser() async {
    isLoginStatus.value = true;
    final data = {
      "email": emailTextEditingController.text.trim(),
      "password": passwordTextEditingController.text,
    };
    final response = await ApiClient.postData(ApiUrls.authLogin, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = response.body['data'];

      PrefsHelper.setString(
          'accessToken', response.body['data']['accessToken']
      );

      print('R E S P O N S E==================>>>>> $response');

      if (user['isActive'] == 'active' &&
          user['isVerified'] == true &&
          user['role'] == 'driver') {
        Get.toNamed(AppRoutes.driverProfileCreateScreen);
      } else if (user['isActive'] == 'active' &&
          user['isVerified'] == true &&
          user['role'] == 'passenger') {
        Get.toNamed(AppRoutes.driverProfileCreateScreen);
      } else if( user['jodi email veryfied na kore thake then oore email varify korabo ']){
        Get.toNamed(AppRoutes.otpVarifyScreen, arguments: {'route': 'sign_in'});
      }else{
        Get.toNamed(AppRoutes.homeScreen);
      }
    } else {
      Get.snackbar('Error', response.body['message']);
    }
    isLoginStatus.value = false;
  }

  @override
  void onClose(){
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }
}
