import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class AppCustomDesign {
  AppCustomDesign._();
  static TextStyle get headingTextStyle => TextStyle(
      color: AppColors.darkColor,
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2
  );
}