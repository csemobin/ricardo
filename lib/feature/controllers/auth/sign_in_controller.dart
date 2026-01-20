import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/user_model.dart';
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
      final accessToken = response.body['data']['accessToken'];
      await PrefsHelper.setString(AppConstants.bearerToken, accessToken);

      if( response.body['data']!['accessToken'].toString().isNotEmpty){
          final userController = Get.find<UserController>();
          await userController.fetchUser();
          final user = userController.userModel;

          // final userResponse = await ApiClient.getData(ApiUrls.getMe);
          if(  user?.userProfile?.isProfileCompleted == true  && user?.userProfile?.role == 'driver' || user?.userProfile?.role == 'passenger' )
          {
            Get.offAllNamed(AppRoutes.homeScreen);
          }
          else if( user?.userProfile?.isProfileCompleted == false )
          {
            Get.offAllNamed(AppRoutes.driverProfileCreateScreen);
          }
      }
      isLoginStatus.value = false;
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
