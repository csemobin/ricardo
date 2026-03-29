import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/simmer/ride_sharing_shimmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/widgets/glass_background_widget.dart' as Glass;
import 'package:ricardo/widgets/request_ride_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final rideController = Get.find<RideController>();
  final googleSearchLocationController =
      Get.find<GoogleSearchLocationController>();

  @override
  void initState() {
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
      child: Glass.GlassBackgroundWidget(
        padding: EdgeInsets.all(0.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Finding nearby rides section
              Obx(() {
                final cnt = Get.find<RideController>();
                return cnt.drivers.isEmpty
                    ? Container(
                        color: AppColors.whiteColor,
                        width: double.maxFinite,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 17.h, horizontal: 23.w),
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
                      )
                    : SizedBox.shrink();
              }),

              // Divider / Progress Indicator
              Obx(() {
                final cnt = Get.find<RideController>();
                if (cnt.isRiderDataLoading.value) {
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

              // Main Driver Section
              Obx(() {
                final cnt = Get.find<RideController>();
                final mapOptController = Get.find<MapOPTController>();

                // Show shimmer while loading
                if (cnt.isRiderDataLoading.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: DriverSkeletonLoader(),
                  );
                }

                // Show expand radius button
                if (cnt.isExpanded.value == true &&
                    cnt.searchRadiusIndex.value <= 3) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
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

                // Show book new ride button if ride was cancelled
                if (cnt.rideCancel.value == true) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
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

                // ✅ Guard: if drivers list is empty, show nothing
                if (cnt.drivers.isEmpty) {
                  return SizedBox.shrink();
                }

                // ✅ Safe to access .first now
                final cardDetails = cnt.drivers.first;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.r),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby rides (${cnt.drivers.length})',
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontFamily.poppins,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.toNamed(AppRoutes.nearByDriverScreen,
                                  arguments: {
                                    'title':
                                        'Nearby rides (${cnt.drivers.length})',
                                    'estimatedCost': widget.rideFare
                                  });
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: FontFamily.poppins,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Driver Card
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.h, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.successColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        '${ApiUrls.imageBaseUrl}${cardDetails.image}',
                                        height: 85.h,
                                        width: 85.w,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(Icons.person, size: 85.h),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cardDetails.name.toString(),
                                          style: TextStyle(
                                            fontFamily: FontFamily.poppins,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.successColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.yellow, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              '${cardDetails.rating} ( ${cardDetails.totalRatings} )',
                                              style: TextStyle(
                                                fontFamily: FontFamily.poppins,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.darkColor,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Container(
                                              width: 2.w,
                                              height: 15.h,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.30),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              '${cardDetails.trips} Trips',
                                              style: TextStyle(
                                                fontFamily: FontFamily.poppins,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.darkColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.call,
                                              color: AppColors.greenColor,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${cardDetails.phone}',
                                              style: TextStyle(
                                                fontFamily: FontFamily.poppins,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse("tel:${cardDetails.phone}"));
                                  },
                                  child: RepaintBoundary(           // ✅ isolates rendering
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: SvgPicture.asset(
                                        Assets.icons.driverCardPhone,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Divider(
                              color: AppColors.successColor,
                              height: 1.h,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Car info.',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontFamily.poppins,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                            '${cardDetails.vehicle?.carName}'.split(' ').map((word) =>
                            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
                            ).join(' '),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 18.sp,
                                        color: AppColors.favoriteRitesCarText,
                                      ),

                                    ),
                                    Text(
                                      '${cardDetails.vehicle?.numberOfSeat} Seat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 16.sp,
                                        color: AppColors.favoriteRitesCarText,
                                      ),
                                    ),
                                    Text(
                                      '${cardDetails.vehicle?.carPlateNumber}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 16.sp,
                                        color: AppColors.favoriteRitesCarText,
                                      ),
                                    ),
                                    Text(
                                      '5 km away from you.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 16.sp,
                                        color: AppColors.dottedBorderColor,
                                      ),
                                    ),
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    '${ApiUrls.imageBaseUrl}${cardDetails.vehicle?.carImage?.filename}',
                                    width: 92.w,
                                    height: 92.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        Icon(Icons.directions_car, size: 92.h),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            RequestRideHandler(
                                cnt: cnt, cardDetails: cardDetails),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // View In Map Button - FIXED HERE
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00C514),
                              Color(0xFF006B0C),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              // Get all controllers
                              final rideController = Get.find<RideController>();
                              final googleSearchController =
                                  Get.find<GoogleSearchLocationController>();

                              print(
                                  'View in map clicked - hiding all UI elements Ride Request Bottom Sheet ');

                              // Optional: Force refresh the UI
                              setState(() {
                                // Hide everything
                                rideController
                                    .toggleViewInMap(); // Sets viewInMap=false, viewInMapReturn=true
                                googleSearchController
                                    .hideModal(); // Sets isModalOn=false
                              });
                            },
                            child: Center(
                              child: Text(
                                'View In Map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Your Trip section (only when no drivers found yet)
              Obx(() {
                final cnt = Get.find<RideController>();
                return cnt.drivers.isEmpty
                    ? Column(
                        children: [
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      Assets.images.originHumanLogo.path,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
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
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 8, top: 5, bottom: 5),
                                  width: 2,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: AppColors.blackColor),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AppColors.primaryColor,
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
                      )
                    : SizedBox.shrink();
              }),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
