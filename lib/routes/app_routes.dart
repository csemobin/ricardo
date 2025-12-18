import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/auth/reset_password_screen.dart';
import 'package:ricardo/feature/view/auth/sign_in_screen.dart';
import 'package:ricardo/feature/view/auth/auth_initial_screen.dart';
import 'package:ricardo/feature/view/auth/forgot_passwrod.dart';
import 'package:ricardo/feature/view/auth/otp_varify.dart';
import 'package:ricardo/feature/view/auth/selected_role_screen.dart';
import 'package:ricardo/feature/view/auth/sign_up_screen.dart';
import 'package:ricardo/feature/view/profile/car_registration_screen.dart';
import 'package:ricardo/feature/view/profile/driver_profile_create.dart';
import 'package:ricardo/feature/view/profile/profile_complete_popup_model_screen.dart';
import 'package:ricardo/feature/view/profile/upload_driving_license_screen.dart';
import 'package:ricardo/feature/view/profile/upload_requirement_screen.dart';
import 'package:ricardo/feature/view/splash_screen/on_board_screen.dart';
import 'package:ricardo/feature/view/splash_screen/splash_screen.dart';
abstract class AppRoutes {

  ///  ============= > initialRoute < ==============
  static const String initialRoute = splashScreen;

  ///  ============= > routes name < ==============
  static const String splashScreen = '/';
  // static const String splashScreen = '/driver_profile_create';
  static const String onBoardingScreen = '/on_board_screen';
  static const String authInitialScreen = '/auth_initial_screen';
  static const String selectedRoleScreen = '/selected_role_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String otpVarifyScreen = 'otp_varify_screen';
  static const String signInScreen = 'sign_in_screen';
  static const String forgotPasswordScreen = '/forgot_password';
  static const String resetPasswordScreen = 'reset_password_screen';
  static const String driverProfileCreateScreen = '/driver_profile_create';
  static const String uploadRequirementScreen = '/upload_required_screen';
  static const String uploadDrivingLicenseScreen = '/upload_driving_license_screen';
  static const String carRegistrationScreen = '/car_registration_screen';
  static const String profileCompletePopupModelScreen = '/profile_complete_popup_modal_screen';
  ///  ============= > routes < ==============
  static final routes = <String, WidgetBuilder>{
    splashScreen : (context) => SplashScreen(),
    onBoardingScreen: (context) => OnBoardScreen(),
    authInitialScreen: (context) => AuthInitialScreen(),
    selectedRoleScreen: (context) => SelectedRoleScreen(),
    signUpScreen: (context) => SignUpScreen(),
    otpVarifyScreen: (context) => OtpVarify(),
    signInScreen: (context) => SignInScreen(),
    forgotPasswordScreen: (context) => ForgotPassword(),
    resetPasswordScreen : (context) => ResetPasswordScreen(),
    driverProfileCreateScreen: (context) => DriverProfileCreate(),
    uploadRequirementScreen: (context) => UploadRequirementScreen(),
    uploadDrivingLicenseScreen: (context) => UploadDrivingLicenseScreen(),
    carRegistrationScreen: (context) => CarRegistrationScreen(),
    profileCompletePopupModelScreen: (context) => ProfileCompletePopupModalScreen(),
  };

}