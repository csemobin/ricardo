import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class CustomSecondaryText extends StatelessWidget {
  final String text;

  const CustomSecondaryText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign:TextAlign.center,
      text,
      style: TextStyle(
        color: AppColors.primaryTextColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
