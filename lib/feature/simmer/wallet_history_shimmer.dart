import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ricardo/app/utils/app_colors.dart';

class WalletScreenShimmer extends StatelessWidget {
  final String userRole;
  final int historyItemCount;

  const WalletScreenShimmer({
    super.key,
    required this.userRole,
    this.historyItemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Today's Earnings (driver only) ──────────────────
            if (userRole == 'driver') ...[
              _buildTodayEarningsShimmer(),
              SizedBox(height: 10.h),
            ],

            // ── Balance Container ────────────────────────────────
            _buildBalanceShimmer(),
            SizedBox(height: 20.h),

            // ── Buttons ──────────────────────────────────────────
            if (userRole == 'driver') _buildActionButtonsShimmer(),
            if (userRole == 'passenger') _buildAddMoneyButtonShimmer(),

            SizedBox(height: 20.h),

            // ── "Recent History" label ───────────────────────────
            _whiteBox(width: 130.w, height: 16.h),
            SizedBox(height: 10.h),

            // ── History Tiles ────────────────────────────────────
            _buildHistoryListShimmer(),
          ],
        ),
      ),
    );
  }

  // ── Today's Earnings ────────────────────────────────────────────
  Widget _buildTodayEarningsShimmer() {
    return Container(
      height: 63.h,
      width: double.maxFinite,
      color: Colors.grey.shade300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _whiteBox(width: 100.w, height: 12.h),
            SizedBox(height: 6.h),
            _whiteBox(width: 70.w, height: 16.h),
          ],
        ),
      ),
    );
  }

  // ── Balance Container ───────────────────────────────────────────
  Widget _buildBalanceShimmer() {
    return Container(
      height: 134.h,
      width: double.maxFinite,
      color: Colors.grey.shade300,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _whiteBox(width: 100.w, height: 24.h),
          SizedBox(height: 8.h),
          _whiteBox(width: 160.w, height: 24.h),
        ],
      ),
    );
  }

  // ── Driver Action Buttons ────────────────────────────────────────
  Widget _buildActionButtonsShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _whiteBox(width: 167.w, height: 44.h, radius: 50.r),
        _whiteBox(width: 167.w, height: 44.h, radius: 50.r),
      ],
    );
  }

  // ── Passenger Add Money Button ───────────────────────────────────
  Widget _buildAddMoneyButtonShimmer() {
    return _whiteBox(
      width: double.maxFinite,
      height: 44.h,
      radius: 50.r,
    );
  }

  // ── History List ─────────────────────────────────────────────────
  Widget _buildHistoryListShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historyItemCount,
      padding: const EdgeInsets.only(bottom: 80),
      separatorBuilder: (_, __) => Divider(
        color: AppColors.dividerLineColor,
        height: 1.h,
      ),
      itemBuilder: (_, __) => ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _whiteBox(width: 140.w, height: 14.h),
                SizedBox(height: 6.h),
                _whiteBox(width: 100.w, height: 12.h),
              ],
            ),
            _whiteBox(width: 60.w, height: 18.h),
          ],
        ),
      ),
    );
  }

  // ── Helper ───────────────────────────────────────────────────────
  Widget _whiteBox({
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