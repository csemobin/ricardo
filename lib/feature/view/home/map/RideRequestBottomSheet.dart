import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/simmer/ride_sharing_shimmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';

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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.r),
          topRight: Radius.circular(50.r),
        ),
      ),
      child: GlassBackgroundWidget(
        padding: EdgeInsets.all(0),
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
                    "Estimated Cost:",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  Text(
                    '\$${widget.rideFare}',
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
            Container(
              color: AppColors.whiteColor,
              width: double.maxFinite,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 17.h, horizontal: 23.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Finding nearby rides..",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                          fontFamily: FontFamily.poppins,
                          letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "We have sent your ride request to the nearby riders.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Obx(() {
              final status = Get.find<RideController>();
              if (status.isRiderDataLoading.value) {
                return LinearProgressIndicator(
                  backgroundColor: Colors.green.shade100,
                  color: AppColors.greenColor,
                  minHeight: 2,
                );
              }
              return Divider(
                thickness: 1,
                color: Colors.grey.shade200,
                height: 1,
              );
            }),
            SizedBox(height: 16.h),


            /*Obx(() {
              final cnt = Get.find<RideController>();



              if (cnt.isRiderDataLoading.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: DriverSkeletonLoader(),
                );
              }

              if ( cnt.searchRadiusIndex.value > 4 &&
                  cnt.isExpanded.value == true ) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryHeadingTextColor,
                      ),
                      onPressed: () {
                        cnt.fetchRiderData(cnt.rideId.value);
                      },
                      child: Text(
                        'Re Search',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return Text('maruf');

            }),*/
            Obx(() {
              final cnt = Get.find<RideController>();

              if (cnt.isRiderDataLoading.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: DriverSkeletonLoader(),
                );
              }


              if (cnt.isExpanded.value == true && cnt.searchRadiusIndex.value <= 3) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryHeadingTextColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        cnt.fetchRiderData(cnt.rideId.value);
                      },
                      child: Text(
                        'Expand Radius',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (cnt.rideCancel.value == true ) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.searchLocationScreen);
                      },
                      child: Text(
                        'Book New Ride',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Driver found!', // replace with your driver card widget
                  style: TextStyle(fontSize: 14.sp, color: AppColors.greenColor),
                ),
              );
            }),

            SizedBox(height: 20.h),

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup location
                  Row(
                    children: [
                      Image.asset(
                        Assets.images.originHumanLogo.path,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      // Icon(
                      //   Icons.location_on,
                      //   color: AppColors.blackColor,
                      //   size: 20.sp,
                      // ),
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

                  Container(
                    margin: EdgeInsets.only(left: 8, top: 5, bottom: 5),
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(color: AppColors.blackColor),
                  ),

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
