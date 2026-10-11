import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class GlassDesignContainer extends StatelessWidget {
  const GlassDesignContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.whiteColor),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkColor.withValues(alpha: 0.01),
                offset: const Offset(0, -4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
