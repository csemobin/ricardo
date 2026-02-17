import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/simmer/ride_sharing_shimmer.dart';

class RideRequestBottomSheet extends StatefulWidget {
  final String pickupLocation;
  final String dropLocation;
  final String rideFare;
  final String distance;

  const RideRequestBottomSheet({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.rideFare,
    required this.distance,
  });

  @override
  State<RideRequestBottomSheet> createState() => _RideRequestBottomSheetState();
}

class _RideRequestBottomSheetState extends State<RideRequestBottomSheet> {
  final controller = Get.put(RideController());

  @override
  void initState() {
    if (mounted) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "Let's Go",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenColor,
                  ),
                ),
              ],
            ),
          ),

          // Ride fare section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ride Fair",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenColor,
                  ),
                ),
                Text(
                  widget.rideFare,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor, // Green color
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Finding nearby rides section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Finding nearby rides..",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "We have sent your ride request to the nearby riders.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Loading indicator (Shimmer effect)
          Obx(() {
            final status = Get.find<RideController>();
            if (status.isRiderDataLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: DriverSkeletonLoader(),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildShimmerLoader(),
            );
          }),

          SizedBox(height: 20.h),

          // Divider
          Obx(() {
            final status = Get.find<RideController>();
            if (status.isRiderDataLoading.value) {
              return LinearProgressIndicator(
                backgroundColor: Colors.green.shade50,
                color: AppColors.greenColor,
              );
            }
            return Divider(
              thickness: 1,
              color: Colors.grey.shade200,
              height: 1,
            );
          }),

          SizedBox(height: 16.h),

          // Your Trip section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Trip",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
                Text(
                  widget.distance,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Pickup and Drop locations
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // Pickup location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.blackColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.pickupLocation,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Drop location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor, // Green
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.dropLocation,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          // Circle shimmer
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          // Line shimmers
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 80.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
