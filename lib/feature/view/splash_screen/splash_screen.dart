import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/view/button_nav_bar/custom_button_nav_bar.dart';
import 'package:ricardo/gen/assets.gen.dart';
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

      await Get.offAll(
        // () => const OnBoardScreen(),
        () =>  CustomButtonNavBar(),
        transition: Transition.fade,
        duration: _transitionDuration,
        curve: Curves.easeInOut,
      );
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
            width: 285,
            height: 285,
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
