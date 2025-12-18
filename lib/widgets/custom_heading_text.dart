import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class CustomHeadingText extends StatelessWidget {
  final String firstText, secondText;
  final double? letterSpacing;
  final bool? isColumn, isSwipedColor;

  const CustomHeadingText({
    super.key,
    required this.firstText,
    required this.secondText,
    this.letterSpacing,
    this.isColumn,
    this.isSwipedColor,
  });

  @override
  Widget build(BuildContext context) {
    return isColumn == true
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                firstText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.sp,
                  color: isSwipedColor == true
                      ? AppColors.primaryHeadingTextColor
                      : AppColors.secondaryHeadingTextColor,
                  letterSpacing: letterSpacing,
                ),
              ),
              Text(
                secondText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.sp,
                  color: isSwipedColor == true
                      ? AppColors.secondaryHeadingTextColor
                      : AppColors.primaryHeadingTextColor,
                  letterSpacing: letterSpacing,
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                firstText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.sp,
                  color: isSwipedColor == true
                      ? AppColors.primaryHeadingTextColor
                      : AppColors.secondaryHeadingTextColor,
                  letterSpacing: letterSpacing,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                secondText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24.sp,
                  color: isSwipedColor == true
                      ? AppColors.secondaryHeadingTextColor
                      : AppColors.primaryHeadingTextColor,
                  letterSpacing: letterSpacing,
                ),
              ),
            ],
          );
  }
}
