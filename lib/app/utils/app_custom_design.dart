import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class AppCustomDesign {
  AppCustomDesign._();

  static TextStyle get headingTextStyle => TextStyle(
        color: AppColors.darkColor,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      );

  static TextStyle get walletScreenTextStyle => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      );

  static BoxDecoration get linearButtonBoxDecorationDesign => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0Xff1BB600),
            Color(0Xff007635),
            Color(0Xff01AF44),
          ],
        ),
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(
          color: Colors.green,
          width: 1,
        ),
      );
}
