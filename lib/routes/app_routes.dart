import 'package:flutter/material.dart';
import 'package:ricardo/feature/five_zero_screen.dart';
import 'package:ricardo/feature/view/auth/forget_password_otp_screen.dart';
import 'package:ricardo/feature/view/auth/reset_password_screen.dart';
import 'package:ricardo/feature/view/auth/sign_in_screen.dart';
import 'package:ricardo/feature/view/auth/auth_initial_screen.dart';
import 'package:ricardo/feature/view/auth/forgot_passwrod.dart';
import 'package:ricardo/feature/view/auth/otp_varify.dart';
import 'package:ricardo/feature/view/auth/selected_role_screen.dart';
import 'package:ricardo/feature/view/auth/sign_up_screen.dart';
import 'package:ricardo/feature/view/button_nav_bar/custom_button_nav_bar.dart';
import 'package:ricardo/feature/view/home/home_screen.dart';
import 'package:ricardo/feature/view/complete_profile/car_registration_screen.dart';
import 'package:ricardo/feature/view/complete_profile/driver_profile_create_screen.dart';
import 'package:ricardo/feature/view/complete_profile/profile_complete_popup_model_screen.dart';
import 'package:ricardo/feature/view/complete_profile/upload_driving_license_screen.dart';
import 'package:ricardo/feature/view/complete_profile/upload_requirement_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/legal_policy_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/privacy_policy_screen.dart';
import 'package:ricardo/feature/view/splash_screen/on_board_screen.dart';
import 'package:ricardo/feature/view/splash_screen/splash_screen.dart';
import 'package:ricardo/feature/view/wallet/add_amount_screen.dart';
import 'package:ricardo/feature/view/wallet/add_card_screen.dart';
import 'package:ricardo/feature/view/wallet/payment_methods_selection_screen.dart';
import 'package:ricardo/feature/view/wallet/withdraw_request_screen.dart';
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
  static const String forgetPasswordOtpVerifyScreen = '/forget_password_otp_screen';
  static const String signInScreen = 'sign_in_screen';
  static const String forgotPasswordScreen = '/forgot_password';
  static const String resetPasswordScreen = 'reset_password_screen';
  static const String driverProfileCreateScreen = '/driver_profile_create';
  static const String uploadRequirementScreen = '/upload_required_screen';
  static const String uploadDrivingLicenseScreen = '/upload_driving_license_screen';
  static const String carRegistrationScreen = '/car_registration_screen';
  static const String profileCompletePopupModelScreen = '/profile_complete_popup_modal_screen';
  static const String homeScreen = '/home_screen';
  static const String customBottomNavBar = '/custom_bottom_nav_bar';
  static const String paymentMethodsSelectionScreen = '/payment_mathods_selection_screen';
  static const String withdrawRequestScreen = '/withdraw_request_screen';
  static const String addCardScreen = '/add_card_screen';
  static const String termsAndConditionScreen = '/terms_condition_screen';
  static const String privacyPolicyScreen = '/privacy_policy_screen';
  static const String legalPolicyScreen = '/legal_policy_screen';
  static const String fiveZeroScreen = '/five_zero_screen';
  static const String addAmountScreen = 'add_amount_screen';

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
    driverProfileCreateScreen: (context) => DriverProfileCreateScreen(),
    uploadRequirementScreen: (context) => UploadRequirementScreen(),
    uploadDrivingLicenseScreen: (context) => UploadDrivingLicenseScreen(),
    carRegistrationScreen: (context) => CarRegistrationScreen(),
    profileCompletePopupModelScreen: (context) => ProfileCompletePopupModalScreen(),
    homeScreen: (context) => HomeScreen(),
    customBottomNavBar: (context) => CustomButtonNavBar(),
    paymentMethodsSelectionScreen: (context) => PaymentMethodsSelectionScreen(),
    withdrawRequestScreen: (context) => WithdrawRequestScreen(),
    addCardScreen: (context) => AddCardScreen(),
    privacyPolicyScreen: (context) => PrivacyPolicyScreen(),
    forgetPasswordOtpVerifyScreen: (context) => ForgetPasswordOtpScreen(),
    legalPolicyScreen : (context) => LegalPolicyScreen(),
    fiveZeroScreen: (context) => FiveZeroScreen(),
    addAmountScreen: (context) => AddAmountScreen(),
  };

}