import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class GlassBackgroundMultipleChildrenWidget extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final MainAxisSize? mainAxisSize;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final double? blurOne;
  final double? blurTwo;

  const GlassBackgroundMultipleChildrenWidget({
    super.key,
    required this.children,
    this.padding,
    this.borderRadius,
    this.mainAxisSize,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.blurOne,
    this.blurTwo,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurOne ?? 4,
          sigmaY: blurTwo ?? 4,
        ),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
            border: Border.all(
              color: AppColors.whiteColor.withOpacity(0.3),
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
          child: Column(
            mainAxisSize: mainAxisSize ?? MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
            children: children, // Use the passed children here
          ),
        ),
      ),
    );
  }
}
