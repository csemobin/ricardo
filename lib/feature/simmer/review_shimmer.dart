import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewShimmer extends StatefulWidget {
  const ReviewShimmer({super.key});

  @override
  State<ReviewShimmer> createState() => _ReviewShimmerState();
}

class _ReviewShimmerState extends State<ReviewShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox({double width = double.infinity, double height = 12, BorderRadius? borderRadius}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(4.r),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Average rating box
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            children: [
              _buildShimmerBox(width: double.maxFinite, height: 200.h, borderRadius: BorderRadius.circular(6.r)),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) => Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: _buildShimmerBox(width: 20.w, height: 20.h, borderRadius: BorderRadius.circular(4.r)),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              _buildShimmerBox(width: 100.w, height: 14.h, borderRadius: BorderRadius.circular(4.r)),
            ],
          ),
        ),
        // Review cards
        Column(
          children: List.generate(
            3, // number of shimmer items
                (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 6.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image
                    _buildShimmerBox(
                        width: 40, height: 40, borderRadius: BorderRadius.circular(100)),
                    SizedBox(width: 8.w),
                    // Name + stars + comment
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(width: 120.w, height: 14.h),
                          SizedBox(height: 6.h),
                          Row(
                            children: List.generate(
                              5,
                                  (index) => Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: _buildShimmerBox(width: 12.w, height: 12.h),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          _buildShimmerBox(width: double.infinity, height: 12.h),
                          SizedBox(height: 4.h),
                          _buildShimmerBox(width: double.infinity, height: 12.h),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
