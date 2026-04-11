import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/user_model.dart';
import 'package:ricardo/feature/view/splash_screen/on_board_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/get_fcm_tocken.dart';
import 'package:ricardo/services/socket_services.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 3);
  static const Duration _transitionDuration = Duration(milliseconds: 600);
  static const Duration _fadeInDuration = Duration(milliseconds: 1000);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeSplash();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _fadeInDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _initializeSplash() async {
    try {
      await Future.delayed(_splashDuration);

      if (!mounted) return;

      final accessToken = await PrefsHelper.getString(AppConstants.bearerToken);

      if( accessToken.isEmpty ){
        await Get.offAll(
              () => const OnBoardScreen(),
          transition: Transition.fade,
          duration: _transitionDuration,
          curve: Curves.easeInOut,
        );
      }
      if( accessToken.isNotEmpty ){
        final UserController userController = Get.find<UserController>();
        await userController.fetchUser();
        final UserModel? user = userController.userModel.value;

        if( user == null ){
          Get.offAllNamed(AppRoutes.signInScreen);
          return;
        }

        if( user.userProfile?.isProfileCompleted == false){
          Get.offAllNamed(AppRoutes.driverProfileCreateScreen);
          return;
        }

        if( user.userProfile?.role == 'driver' && ( user.driverProfile?.licenseUploaded == false || user.driverProfile?.vehicleDataUploaded == false ) ){
          Get.offAllNamed(AppRoutes.uploadRequirementScreen);
          return;
        }
        Get.offAllNamed(AppRoutes.customBottomNavBar);
      }

    } catch (e) {
      debugPrint('Splash navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(128),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Assets.images.splashBackground.image(
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          LogoWidget(
            width: 100.w,
            height: 100.h,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}