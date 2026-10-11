import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';
import 'package:ricardo/feature/controllers/history/history_controller.dart';
import 'package:ricardo/feature/controllers/wallet/recent_history.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/services/api_client.dart';

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
      final fcmToken = await FirebaseNotificationService.getFCMToken();
      await PrefsHelper.setString(AppConstants.bearerToken, accessToken);
      if (fcmToken != null) {
        await PrefsHelper.setString(AppConstants.fcmToken, fcmToken);
      }

      socketConnect();

      if (response.body['data']!['accessToken'].toString().isNotEmpty) {
        final userController = Get.find<UserController>();
        await userController.fetchUser();
        final user = userController.userModel.value;

        if (response.body['data']!['user']['role'].toString() ==
            'super_admin') {
          showSnackbar('Error', 'You are not Eligible for login!');
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
          Get.offAllNamed(AppRoutes.customBottomNavBar);
        } else if (user?.userProfile?.isProfileCompleted == false) {
          Get.offAllNamed(AppRoutes.driverProfileCreateScreen);
        }
      }
      clearField();
    } else if (response.body != null &&
        response.body['data'] != null &&
        response.body['data']['isVerified'] == false) {
      final email = response.body['data']['email'];
      final verifyResponse = await ApiClient.postData(
          ApiUrls.otpSendVerification, {"email": email});
      if (verifyResponse.statusCode == 200) {
        Get.offAllNamed(AppRoutes.otpVarifyScreen,
            arguments: {'email': email, 'route': 'sing_up'});
      }
    } else {
      // Show the exact message from the backend
      final message = response.body is Map
          ? (response.body['message'] ??
              response.statusText ??
              'An error occurred')
          : (response.statusText ?? 'An error occurred');
      showSnackbar('Error', message.toString());
    }

    isLoginStatus.value = false;
  }

  Future<bool> logOut() async {
    final deviceId = await PrefsHelper.getString('device_id');
    final response =
        await ApiClient.postData(ApiUrls.authLogOut, {'deviceId': deviceId});
    if (response.statusCode == 200 || response.statusCode == 201) {
      await PrefsHelper.remove(AppConstants.bearerToken);
      await PrefsHelper.remove(AppConstants.deviceId);
      SocketServices.socket?.disconnect();
      SocketServices.socket?.dispose();
      PrefsHelper.remove(AppConstants.bearerToken);
      PrefsHelper.remove(AppConstants.fcmToken);
      await Get.find<UserController>().clearCachedUser();

      final recentCnt = Get.find<RecentHistoryController>();
      recentCnt.recentHistoryList.value = [];

      final historyCnt = Get.find<HistoryController>();
      historyCnt.historyDatas.value = [];

      Get.offAllNamed(AppRoutes.signInScreen);
      return true;
    } else {
      final message = response.body is Map
          ? (response.body['message'] ??
              response.body['data']?['message'] ??
              response.statusText ??
              'An error occurred')
          : (response.statusText ?? 'An error occurred');
      showSnackbar('Error', message.toString());
      return false;
    }
  }

  void clearField() {
    emailTextEditingController.clear();
    passwordTextEditingController.clear();
  }

  void socketConnect() async {
    await SocketServices.init();
    final String? token =
        await PrefsHelper.getString(AppConstants.bearerToken) ?? '';
    final String? fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);

    if (token != null && fcmToken != null) {
      SocketServices.socket?.emit(
          'user-connected', {"accessToken": token, "fcmToken": fcmToken});
    }
  }

  @override
  void onClose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }
}
