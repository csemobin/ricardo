import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverSkeletonLoader extends StatefulWidget {
  const DriverSkeletonLoader({super.key});

  @override
  State<DriverSkeletonLoader> createState() => _DriverSkeletonLoaderState();
}

class _DriverSkeletonLoaderState extends State<DriverSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    bool isCircle = false,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(6.r),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Circle Avatar Skeleton
          _skeletonBox(
            width: 50.w,
            height: 50.h,
            isCircle: true,
          ),

          SizedBox(width: 12.w),

          // Lines Skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Line (longer)
              _skeletonBox(width: 140.w, height: 12.h),

              SizedBox(height: 8.h),

              // Second Line (shorter)
              _skeletonBox(width: 100.w, height: 10.h),
            ],
          ),
        ],
      ),
    );
  }
}