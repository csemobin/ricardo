import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class FavouriteRiderShimmer extends StatefulWidget {
  final int itemCount;
  const FavouriteRiderShimmer({super.key, this.itemCount = 3});

  @override
  State<FavouriteRiderShimmer> createState() => _FavouriteRiderShimmerState();
}

class _FavouriteRiderShimmerState extends State<FavouriteRiderShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _shimmerGradient(double slide) {
    return LinearGradient(
      colors: [
        Colors.grey.shade300,
        Colors.grey.shade100,
        Colors.grey.shade300,
      ],
      stops: [0.1, 0.5, 0.9],
      begin: Alignment(-1 - slide, -0.3),
      end: Alignment(1 + slide, 0.3),
    );
  }

  Widget _buildShimmerCard(double slide) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return _shimmerGradient(slide).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.successColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // Profile Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 85.h,
                      width: 85.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14.h, width: 120.w, color: Colors.grey),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(height: 12.h, width: 40.w, color: Colors.grey),
                            SizedBox(width: 8.w),
                            Container(height: 12.h, width: 60.w, color: Colors.grey),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(height: 12.h, width: 16.w, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Container(height: 12.h, width: 80.w, color: Colors.grey),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                Container(height: 24.h, width: 24.w, color: Colors.grey)
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color: AppColors.successColor.withOpacity(0.2), height: 1.h),
            SizedBox(height: 10.h),
            Container(height: 14.h, width: 80.w, color: Colors.grey),
            SizedBox(height: 8.h),
            // Car Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    4,
                        (index) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Container(
                        height: 14.h,
                        width: 140.w,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 92.h,
                  width: 92.w,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double slide = _controller.value * 2; // sliding animation
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) => _buildShimmerCard(slide),
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          padding: EdgeInsets.only(bottom: 16.h),
        );
      },
    );
  }
}
