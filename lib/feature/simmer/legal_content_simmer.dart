import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class LegalContentSimmer extends StatefulWidget {
  const LegalContentSimmer({super.key});

  @override
  State<LegalContentSimmer> createState() => _LegalContentSimmerState();
}

class _LegalContentSimmerState extends State<LegalContentSimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.whiteColor),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFFEBEBF4),
                  Color(0xFFF4F4F4),
                  Color(0xFFEBEBF4),
                ],
                stops: [
                  _animation.value - 0.3,
                  _animation.value,
                  _animation.value + 0.3,
                ],
                transform: GradientRotation(_animation.value),
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              _buildShimmerBox(width: 150.w, height: 20.h),
              SizedBox(height: 15.h),

              // Paragraph lines
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 250.w, height: 12.h),
              SizedBox(height: 20.h),

              // Section 1
              _buildShimmerBox(width: 180.w, height: 18.h),
              SizedBox(height: 12.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 200.w, height: 12.h),
              SizedBox(height: 20.h),

              // Section 2
              _buildShimmerBox(width: 160.w, height: 18.h),
              SizedBox(height: 12.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 280.w, height: 12.h),
              SizedBox(height: 20.h),

              // Section 3
              _buildShimmerBox(width: 140.w, height: 18.h),
              SizedBox(height: 12.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 220.w, height: 12.h),
              SizedBox(height: 20.h),

              // Section 4
              _buildShimmerBox(width: 170.w, height: 18.h),
              SizedBox(height: 12.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 240.w, height: 12.h),
              SizedBox(height: 20.h),

              // Section 5
              _buildShimmerBox(width: 190.w, height: 18.h),
              SizedBox(height: 12.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: double.infinity, height: 12.h),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 260.w, height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}