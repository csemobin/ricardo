import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/utils/app_colors.dart';
import '../widgets/widgets.dart';


class AuthTitleWidgets extends StatelessWidget {
  const AuthTitleWidgets(
      {super.key,
      required this.title,
      this.subtitle,
      this.titleColor,
      this.subTitleColor,
      this.titleFontSize,
      this.subTitleFontSize});

  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? subTitleColor;
  final double? titleFontSize;
  final double? subTitleFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       // Assets.icons.logoSvg.svg(),
        CustomText(
          top: 12.h,
          text: title,
          fontSize:titleFontSize?? 14.sp,
          color: titleColor ?? AppColors.appGreyColor,
        ),
        if(subTitleColor != null)...[
          SizedBox(height: 6.h),
          CustomText(
            textAlign: TextAlign.start,
            text: subtitle ?? '',
            fontSize:subTitleFontSize?? 15.sp,
            color: subTitleColor ?? AppColors.secondaryColor,
            textOverflow: TextOverflow.fade,
            fontName: 'Inter',
          ),
        ],
      ],
    );
  }
}
