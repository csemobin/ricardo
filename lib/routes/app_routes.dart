import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/auth/auth_initial_screen.dart';
import 'package:ricardo/feature/view/auth/otp_varify.dart';
import 'package:ricardo/feature/view/auth/selected_role_screen.dart';
import 'package:ricardo/feature/view/auth/sign_up_screen.dart';
import 'package:ricardo/feature/view/splash_screen/on_board_screen.dart';
import 'package:ricardo/feature/view/splash_screen/splash_screen.dart';
abstract class AppRoutes {

  ///  ============= > initialRoute < ==============
  static const String initialRoute = splashScreen;

  ///  ============= > routes name < ==============
  static const String splashScreen = '/';
  static const String onBoardingScreen = '/on_board_screen';
  static const String authInitialScreen = '/auth_initial_screen';
  static const String selectedRoleScreen = '/selected_role_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String otpVarifyScreen = 'otp_varify_screen';

  ///  ============= > routes < ==============
  static final routes = <String, WidgetBuilder>{
    splashScreen : (context) => SplashScreen(),
    onBoardingScreen: (context) => OnBoardScreen(),
    authInitialScreen: (context) => AuthInitialScreen(),
    selectedRoleScreen: (context) => SelectedRoleScreen(),
    signUpScreen: (context) => SignUpScreen(),
    otpVarifyScreen: (context) => OtpVarify(),
  };
}