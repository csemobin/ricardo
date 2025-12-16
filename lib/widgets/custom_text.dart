import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/gen/fonts.gen.dart';

import '../app/utils/app_colors.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.maxline,
    this.textOverflow,
    this.fontName,
    this.textAlign = TextAlign.center,
    this.left = 0,
    this.right = 0,
    this.top = 0,
    this.bottom = 0,
    this.fontSize,
    this.textHeight,
    this.fontWeight = FontWeight.w400,
    this.color,
    this.onTap,
    this.decoration,
    this.decorationColor,
    this.letterSpacing,
    this.lineheight,
  });

  final String text;
  final int? maxline;
  final TextOverflow? textOverflow;
  final String? fontName;
  final TextAlign textAlign;

  final double left;
  final double right;
  final double top;
  final double bottom;

  final double? fontSize;
  final double? textHeight;
  final FontWeight fontWeight;
  final Color? color;
  final VoidCallback? onTap;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? letterSpacing;
  final double? lineheight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.only(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
        ),
        child: Text(
          text,
          maxLines: maxline,
          overflow: textOverflow,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            height: textHeight,
            letterSpacing: letterSpacing,
            fontFamily: fontName ?? FontFamily.intel,
            fontWeight: fontWeight,
            color: color ?? AppColors.darkColor,
            decoration: decoration,
            decorationColor: decorationColor,
          ),
        ),
      ),
    );
  }
}
