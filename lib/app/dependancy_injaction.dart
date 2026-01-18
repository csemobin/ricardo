import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/auth/forget_password_controller.dart';
import 'package:ricardo/feature/controllers/auth/otp_varify_controller.dart';
import 'package:ricardo/feature/controllers/auth/sign_in_controller.dart';
import 'package:ricardo/feature/controllers/auth/sign_up_controller.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/driving_license_controller.dart';

class DependencyInjection implements Bindings{
  @override
  void dependencies(){
    Get.put(CustomBottomNavBarController());
    Get.put(DrivingLicenseController());
    Get.put(SignUpController());
    Get.put(OtpVerifyController());
    Get.put(SignInController());
    Get.put(ForgetPasswordController());
  }
}