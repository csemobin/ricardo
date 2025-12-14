import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/utils/app_colors.dart';
import '../widgets/widgets.dart';


class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      this.suffixIcon,
      this.child,
      this.label,
      this.backgroundColor,
      this.foregroundColor,
      this.height,
      this.width,
      this.fontWeight,
      this.fontSize,
      this.fontName,
      required this.onPressed,
      this.radius,
      this.prefixIcon,
      this.bordersColor,
      this.suffixIconShow = false,
      this.prefixIconShow = false,
      this.title,
      this.iconHeight,
      this.iconWidth,
      this.elevation = false});

  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final Widget? child;
  final String? label;
  final Widget? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? radius;
  final String? fontName;
  final VoidCallback? onPressed;
  final Color? bordersColor;
  final bool suffixIconShow;
  final bool prefixIconShow;
  final double? iconHeight;
  final double? iconWidth;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      elevation: elevation,
      onTap: onPressed,
      color: backgroundColor ?? AppColors.secondaryColor,
      height: height ?? 46.h,
      width: width ?? double.infinity,
      radiusAll: radius ?? 10.r,
      bordersColor: bordersColor,
      child:child?? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Prefix Icon
          if (prefixIcon != null || prefixIconShow == true) ...[
            Icon(
              size: 18.r,
              prefixIcon ?? Icons.arrow_back,

              /// Use prefixIcon or fallback
              color: foregroundColor ?? AppColors.darkColor,
            ),
            SizedBox(width: 8.w),
          ],

          if (title != null) title!,

          /// Label Text
          if (label != null)
            Flexible(
              child: CustomText(
                text: label ?? '',
                color: foregroundColor ?? Colors.white,
                fontName: fontName ?? 'Inter',
                fontWeight: fontWeight ?? FontWeight.w500,
                fontSize: fontSize ?? 16.sp,
              ),
            ),

          /// Suffix Icon
          if (suffixIcon != null || suffixIconShow == true) ...[
            SizedBox(width: 8.w),
            // Use SvgPicture for SVG icons
            suffixIcon != null
                ? suffixIcon! // If a custom widget is passed as suffixIcon
                : Icon(Icons.arrow_forward_ios),
          ],
        ],
      ),
    );
  }
}
