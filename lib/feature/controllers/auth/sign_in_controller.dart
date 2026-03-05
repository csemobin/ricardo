import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/services/socket_services.dart';

class SignInController extends GetxController {
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  RxBool canSubmit = false.obs;
  RxBool isLoginStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailTextEditingController.addListener(_checkSubmit);
    passwordTextEditingController.addListener(_checkSubmit);

  }

  void _checkSubmit() {
    canSubmit.value = emailTextEditingController.text.isNotEmpty &&
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

      socketConnect();

      if (response.body['data']!['accessToken'].toString().isNotEmpty) {
        final userController = Get.find<UserController>();
        await userController.fetchUser();
        final user = userController.userModel.value;

        if (response.body['data']!['user']['role'].toString() == 'super_admin') {
          Get.snackbar('Error', 'You are not Eligible for login!');
          passwordTextEditingController.clear();
          emailTextEditingController.clear();
          PrefsHelper.remove('accessToken');
          isLoginStatus.value = false;
          return;
        }

        if (user?.userProfile?.isProfileCompleted == true &&
            user?.userProfile?.role == 'driver' ||
            user?.userProfile?.isProfileCompleted == true &&
                user?.userProfile?.role == 'passenger') {
          final cnt = Get.find<CustomBottomNavBarController>();
          cnt.onChange(0);
          // cnt.selectedIndex.value = 0;

          // String? getAccessToken = await PrefsHelper.getString('accessToken');
          // String? fcmToken = await FirebaseNotificationService.getFCMToken();
          // PrefsHelper.setString(AppConstants.fcmToken, fcmToken);
          // await SocketServices.init();
          //
          // SocketServices.socket?.emit('user-connected', {
          //   "accessToken" : getAccessToken,
          //   "fcmToken" : fcmToken
          // });
          //
          //
          // print('===== FCMTOKEN>>>>>>>>>>>>>>>>>>>>>> $fcmToken ==================');
          // print('=======AccessToken>>>>>>>>>>>>>>>>>>>>>> $getAccessToken');

           /// here will be socket construction

          Get.offAllNamed(AppRoutes.customBottomNavBar);
        } else if (user?.userProfile?.isProfileCompleted == false) {
          Get.offAllNamed(AppRoutes.driverProfileCreateScreen);
        }
      }
      clearField();
    } else if (response.body['data'] != null &&
        response.body['data']['isVerified'] == false) {
      final email = response.body['data']['email'];
      final verifyResponse = await ApiClient.postData(
          ApiUrls.otpSendVerification, {"email": email});
      if (verifyResponse.statusCode == 200) {
        Get.offAllNamed(AppRoutes.otpVarifyScreen,
            arguments: {'email': email, 'route': 'sing_up'});
      }
    }  else {
      Get.snackbar('Error', response.body['message'] ?? 'An error occurred');
    }

    isLoginStatus.value = false;
  }

  Future<void> logOut() async {
    final response = await ApiClient.postData(ApiUrls.authLogOut, {});
    if (response.statusCode == 200 || response.statusCode == 201) {
      await PrefsHelper.remove(AppConstants.bearerToken);
      SocketServices.socket?.disconnect();
      SocketServices.socket?.dispose();
      PrefsHelper.remove(AppConstants.bearerToken);
      PrefsHelper.remove(AppConstants.fcmToken);
      Get.offAllNamed(AppRoutes.signInScreen);
    } else {
      Get.snackbar('Error', response.body['data']['message']);
    }
  }

  void clearField() {
    emailTextEditingController.clear();
    passwordTextEditingController.clear();
  }


  void socketConnect() async{
    await SocketServices.init();
    final String? token =
        await PrefsHelper.getString(AppConstants.bearerToken) ?? '';
    final String? fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);
    if (token != null && token.isNotEmpty) {
      SocketServices.socket
          ?.emit('user-connected', {"accessToken": token, "fcmToken": fcmToken});
    }
  }

  @override
  void onClose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }
}
