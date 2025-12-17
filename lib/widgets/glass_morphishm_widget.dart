import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';

class GlassmorphismWidget extends StatelessWidget {
  const GlassmorphismWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
                color: AppColors.whiteColor.withOpacity(0.15),
                border: Border.all(color: Colors.white.withOpacity(0.8))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(padding: EdgeInsets.only(top: 32.h)),
                Image.asset(Assets.images.glassmorphismLogo.path),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'Password changed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenColor,
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  textAlign: TextAlign.center,
                  'Your password has been changed successfully',
                  style: TextStyle(
                    color: Color(0Xff4E4E4E),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                CustomPrimaryButton(
                  title: 'Back to Home',
                  onHandler: () {
                    Get.toNamed(AppRoutes.signInScreen);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
