import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class OtpVerifyController extends GetxController {
  Timer? _timer;
  final RxInt _secondsRemaining = 180.obs;
  final RxBool _isTimerActive = false.obs;

  RxInt get secondsRemaining => _secondsRemaining;
  RxBool get isTimerActive => _isTimerActive;

  // OTP Verify Related work
  RxBool isVarifyEmail = false.obs;
  RxString otpEmail = ''.obs;
  final TextEditingController pinTEController = TextEditingController();

  // THIS IS THE KEY FIX: Create an observable string for the OTP text
  RxString otpText = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to text changes and update the observable
    pinTEController.addListener(() {
      otpText.value = pinTEController.text;
    });
  }

  void startTimer() {
    _isTimerActive.value = true;
    _secondsRemaining.value = 180;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining.value > 0) {
        _secondsRemaining.value--;
      } else {
        _timer?.cancel();
        _isTimerActive.value = false;
      }
    });
  }

  String get formattedTime {
    int minutes = _secondsRemaining.value ~/ 60;
    int seconds = _secondsRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void stopTimer() {
    _timer?.cancel();
    _isTimerActive.value = false;
  }

  Future<void> varifyOtp( String route ) async {
    if (pinTEController.text.length != 6) {
      Get.snackbar('Error', 'Please enter 6 digit OTP');
      return;
    }

    isVarifyEmail.value = true;

    final data = {
      "email": otpEmail.value,
      "otp": pinTEController.text.trim()
    };
    try {
      final response = await ApiClient.postData(ApiUrls.otpVerifyVerification, data);
      stopTimer();
      if(response.statusCode == 200 || response.statusCode == 201 ){
        Get.snackbar('Success', 'Email verified successfully!');
        if(route == 'sign_in'){

        }else if( route == 'forget_pass'){
          Get.toNamed(AppRoutes.resetPasswordScreen);
        }
        Get.toNamed(AppRoutes.signInScreen);
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification failed: ${e.toString()}');
    } finally {
      isVarifyEmail.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      stopTimer();
      pinTEController.clear();

      // final response = await ApiClient.postData(ApiUrls.resendOtp, {"email": otpEmail.value});

      Get.snackbar('Success', 'OTP sent successfully!');
      startTimer();

    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinTEController.dispose();
    super.dispose();
  }
}