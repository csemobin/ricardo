import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class GlassBackgroundWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? borderLeftRightRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? blurNumber;

  const GlassBackgroundWidget({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderLeftRightRadius,
    this.blurNumber,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius ?? 24.r),
        topRight: Radius.circular(borderRadius ?? 24.r),
        bottomLeft: Radius.circular(borderLeftRightRadius ?? 0.r),
        bottomRight: Radius.circular(borderLeftRightRadius ?? 0.r),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurNumber ?? 16,
          sigmaY: blurNumber ?? 16,
        ),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.whiteColor).withOpacity(0.3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius ?? 12.r),
              topRight: Radius.circular(borderRadius ?? 12.r),
            ),
            border: Border.all(
              color: (borderColor ?? AppColors.whiteColor).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child, // Use the passed child here
        ),
      ),
    );
  }
}