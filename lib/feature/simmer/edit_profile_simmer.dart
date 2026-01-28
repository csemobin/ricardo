import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class ShimmerContainer extends StatefulWidget {
  const ShimmerContainer();

  @override
  State<ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 58.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.whiteColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Color(0xff94949e).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    width: 60.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Color(0xff94949e).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                width: 180.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: Color(0xff94949e).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}