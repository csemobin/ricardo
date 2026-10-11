import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/helpers/prefs_helper.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/user_model.dart';
import 'package:ricardo/feature/view/auth/auth_initial_screen.dart';
import 'package:ricardo/feature/view/splash_screen/on_board_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
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
      final fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);
      final hasSeenOnboard = await PrefsHelper.getBool(AppConstants.onBoardKey);

      if (accessToken.isEmpty || fcmToken.isEmpty) {
        if (hasSeenOnboard) {
          await Get.offAll(
            () => const AuthInitialScreen(),
            transition: Transition.fade,
            duration: _transitionDuration,
            curve: Curves.easeInOut,
          );
        } else {
          await Get.offAll(
            () => const OnBoardScreen(),
            transition: Transition.fade,
            duration: _transitionDuration,
            curve: Curves.easeInOut,
          );
        }
        return;
      }

      if (accessToken.isNotEmpty && fcmToken.isNotEmpty) {
        final UserController userController = Get.find<UserController>();
        await userController.loadCachedUser();
        try {
          await userController.fetchUser().timeout(const Duration(seconds: 12));
        } catch (e) {
          debugPrint('Splash fetchUser skipped: $e');
        }
        final UserModel? user = userController.userModel.value;

        if (user == null) {
          Get.offAllNamed(AppRoutes.signInScreen);
          return;
        }

        if (user.userProfile?.isProfileCompleted == false) {
          Get.offAllNamed(AppRoutes.driverProfileCreateScreen);
          return;
        }

        if (user.userProfile?.role == 'driver' &&
            (user.driverProfile?.licenseUploaded == false ||
                user.driverProfile?.vehicleDataUploaded == false)) {
          Get.offAllNamed(AppRoutes.uploadRequirementScreen);
          return;
        }
        try {
          await Get.find<MapOPTController>().seedCachedCoordinates();
        } catch (e) {
          debugPrint('Splash location seed skipped: $e');
        }
        Get.offAllNamed(AppRoutes.customBottomNavBar);
      }
    } catch (e) {
      debugPrint('Splash navigation error: $e');
      if (!mounted) return;
      Get.offAll(
        () => const AuthInitialScreen(),
        transition: Transition.fade,
        duration: _transitionDuration,
      );
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