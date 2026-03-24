import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class HistoryScreenShimmer extends StatelessWidget {
  final int groupCount;
  final int ridesPerGroup;

  const HistoryScreenShimmer({
    super.key,
    this.groupCount = 4,
    this.ridesPerGroup = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: groupCount,
        padding: EdgeInsets.only(bottom: 85.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeaderShimmer(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ridesPerGroup,
              separatorBuilder: (_, __) => SizedBox(height: 4.h),
              itemBuilder: (_, __) => _buildRideCardShimmer(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date Header ────────────────────────────────────────────────
  // Real: Container(h:30, BoxDecoration(navBarBg), Padding(h:25, v:5), Text)
  Widget _buildDateHeaderShimmer() {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.navBarBackgroundColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _box(width: 80.w, height: 14.h),
      ),
    );
  }

  // ── Ride Card ──────────────────────────────────────────────────
  // Real: Container(BoxDecoration(whiteColor))
  //         Padding(v:12.h, h:25.w)
  //           Column(crossAxisAlignment.start)
  Widget _buildRideCardShimmer() {
    return Container(
      decoration: BoxDecoration(color: AppColors.whiteColor),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Row: formattedDateTime ←→ formattedFare ──────────
            // Real: Row(MainAxisAlignment.spaceBetween)
            //         Text(formattedDateTime, fontSize:14, w600)
            //         Text(formattedFare,     fontSize:14, w600)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _box(width: 155.w, height: 14.h), // "12 Jan 2025, 08:30 AM"
                _box(width: 52.w,  height: 14.h), // "$12.50"
              ],
            ),

            SizedBox(height: 12.h),

            // ── Pickup Row ───────────────────────────────────────
            // Real: Row[
            //   Image.asset(directRight),
            //   SizedBox(width:8),
            //   Expanded → Column(
            //     Text('PICK UP',  fontSize:12, w500)
            //     Text(address,    fontSize:14, w600, maxLines:2)
            //   )
            // ]
            _buildLocationRowShimmer(),

            // ── Vertical Separator ───────────────────────────────
            // Real: Padding(left:12, top:4, bottom:4)
            //         Container(w:2, h:20, BoxDecoration(separaterBgColor))
            Padding(
              padding: EdgeInsets.only(left: 12.w, top: 4.h, bottom: 4.h),
              child: Container(
                width: 2.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.separaterBgColor,
                ),
              ),
            ),

            // ── Dropoff Row ──────────────────────────────────────
            // Real: Row[
            //   Image.asset(location),
            //   SizedBox(width:8),
            //   Expanded → Column(
            //     Text('DROP OFF', fontSize:12, w500)
            //     Text(address,    fontSize:14, w600, maxLines:2)
            //   )
            // ]
            _buildLocationRowShimmer(),
          ],
        ),
      ),
    );
  }

  // ── Location Row ────────────────────────────────────────────────
  // Mirrors BOTH pickup and dropoff rows exactly
  Widget _buildLocationRowShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Real: Image.asset(directRight / location) — natural icon size
        _box(width: 20.w, height: 20.w, radius: 3.r),

        SizedBox(width: 8.w),

        // Real: Expanded(child: Column(...))
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Real: Text('PICK UP', fontSize:12.sp, w500)
              _box(width: 55.w, height: 12.h),

              SizedBox(height: 5.h),

              // Real: Text(address, fontSize:14.sp, w600, maxLines:2)
              // Line 1 — full width
              _box(width: double.infinity, height: 14.h),

              SizedBox(height: 4.h),

              // Line 2 — partial (simulates maxLines:2 + ellipsis)
              _box(width: double.infinity, height: 14.h),
            ],
          ),
        ),
      ],
    );
  }

  // ── Box Helper ──────────────────────────────────────────────────
  Widget _box({
    required double width,
    required double height,
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 4.r),
      ),
    );
  }
}