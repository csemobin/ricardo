import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';

class NearByDriverScreen extends StatefulWidget {
  const NearByDriverScreen({super.key});

  @override
  State<NearByDriverScreen> createState() => _NearByDriverScreenState();
}

class _NearByDriverScreenState extends State<NearByDriverScreen> {
  final googleSearchLocationController =
  Get.find<GoogleSearchLocationController>();
  final title = Get.arguments['title'];
  final estimatedCost = Get.arguments['estimatedCost'];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 18.h,
            ),
            Obx(() {
              final cnt = Get.find<RideController>();
              return cnt.drivers.isNotEmpty
                  ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
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
                          googleSearchLocationController.distance.value,
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
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
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
                                // widget.pickupLocation,
                                // googleSearchLocationController.distance.
                                googleSearchLocationController
                                    .pickupController.text,
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
                          margin:
                          EdgeInsets.only(left: 8, top: 5, bottom: 5),
                          width: 2,
                          height: 20,
                          decoration:
                          BoxDecoration(color: AppColors.blackColor),
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
                                googleSearchLocationController
                                    .dropController.text,
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
                  SizedBox(height: 14.h),
                ],
              )
                  : SizedBox.shrink();
            }),
            Divider(
              color: AppColors.greenColor,
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Cost: ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryTextColor,
                    fontFamily: FontFamily.poppins,
                  ),
                ),
                Text(
                  '$estimatedCost \$' ?? '0',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 22.h,
            ),
            Obx(() {
              final cnt = Get.find<RideController>();
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => cnt.changeTab(0),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text(
                                  'Nearby rides (${cnt.drivers.isNotEmpty &&
                                      cnt.drivers.length <= 9 ? '0${cnt.drivers
                                      .length}' : '${cnt.drivers.length}'})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cnt.selectedTab.value == 0
                                        ? AppColors.greenColor
                                        : AppColors.swippedButtonColor,
                                    fontWeight: cnt.selectedTab.value == 0
                                        ? FontWeight.w600
                                        : FontWeight.w600,
                                    fontFamily: FontFamily.poppins,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                              // Underline indicator
                              Container(
                                height: cnt.selectedTab.value == 0 ? 5.h : 3.h,
                                decoration: BoxDecoration(
                                  color: cnt.selectedTab.value == 0
                                      ? AppColors.greenColor
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.r),
                                    topRight: Radius.circular(10.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => cnt.changeTab(1),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text(
                                  'Favorites rides (${cnt.favouriteDrivers
                                      .isNotEmpty &&
                                      cnt.favouriteDrivers.length <= 9 ? '0${cnt
                                      .favouriteDrivers.length}' : '${cnt
                                      .favouriteDrivers.length}'})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cnt.selectedTab.value == 1
                                        ? AppColors.greenColor
                                        : AppColors.swippedButtonColor,
                                    fontWeight: cnt.selectedTab.value == 1
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              // Underline indicator
                              Container(
                                height: cnt.selectedTab.value == 1 ? 5.h : 3.h,
                                decoration: BoxDecoration(
                                  color: cnt.selectedTab.value == 1
                                      ? AppColors.greenColor
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.r),
                                    topRight: Radius.circular(10.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            SizedBox(
              height: 18.h,
            ),
            Obx(() {
              final cnt = Get.find<RideController>();
              return cnt.selectedTab.value == 0
                  ? ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                // scrollDirection: Axis.vertical,
                itemCount: cnt.drivers.length,
                itemBuilder: (context, index) {
                  final cardDetails = cnt.drivers[index];
                  return // Driver Card
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      '${ApiUrls.imageBaseUrl}${cardDetails
                                          .image}',
                                      height: 85.h,
                                      width: 85.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) =>
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
                                              color: Colors.yellow,
                                              size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            '${cardDetails
                                                .rating} ( ${cardDetails
                                                .totalRatings} )',
                                            style: TextStyle(
                                              fontFamily:
                                              FontFamily.poppins,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
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
                                              fontFamily:
                                              FontFamily.poppins,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
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
                                              fontFamily:
                                              FontFamily.poppins,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: SvgPicture.asset(
                                      Assets.icons.driverCardPhone),
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
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.poppins,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${cardDetails.vehicle?.carName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '${cardDetails.vehicle?.numberOfSeat} Seat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '${cardDetails.vehicle?.carPlateNumber}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '5 km away from you.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ],
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  '${ApiUrls.imageBaseUrl}${cardDetails.vehicle
                                      ?.carImage?.filename}',
                                  width: 92.w,
                                  height: 92.h,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                      Icon(
                                          Icons.directions_car,
                                          size: 92.h),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          // Request Ride
                          RequestRideHandler(cnt: cnt, cardDetails: cardDetails),
                          // Request Ride
                          // ElevatedButton(
                          //   onPressed: (){
                          //     cnt.fetchSendPickUpRequest(cnt.rideId.value, cardDetails.sId!);
                          //     showDialog(
                          //       context: context,
                          //       builder: (context) {
                          //         return  Dialog(
                          //             backgroundColor: Colors.transparent,
                          //             child: GlassBackgroundMultipleChildrenWidget(
                          //               mainAxisSize: MainAxisSize.min,
                          //               mainAxisAlignment:MainAxisAlignment.center,
                          //               crossAxisAlignment: CrossAxisAlignment.center,
                          //               children: [
                          //                 Image.asset(
                          //                   Assets.images.waiting.path,
                          //                   fit: BoxFit.cover,
                          //                 ),
                          //                 Text('Sending your ride request…'),
                          //                 Text('Waiting for driver to accept.'),
                          //                 ElevatedButton(onPressed: (){}, child: Text('YES')),
                          //                 ElevatedButton(
                          //                   onPressed: () {
                          //
                          //                     Navigator.pop(context);
                          //                   },
                          //                   child: Text('Cancel Request'),
                          //                 ),
                          //               ],
                          //             )
                          //         );
                          //       },
                          //     );
                          //   },
                          //   /* onPressed: () {
                          //           GlassBackgroundWidget(children: [Text('maruf')]);
                          //           // ConfirmPopUpModal(child: Text('maruf'));
                          //           // cnt.fetchSendPickUpRequest(cnt.rideId.value, cardDetails.sId!);
                          //         },*/
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color(0xFF34A853),
                          //     foregroundColor: Colors.white,
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: 24, vertical: 14),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     elevation: 0,
                          //   ),
                          //   child: Text(
                          //     'Request Ride',
                          //     style: TextStyle(
                          //       fontSize: 15,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10.h);
                },
                padding: EdgeInsets.only(
                  bottom: 16.h,
                ),
              )
                  : ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                // scrollDirection: Axis.vertical,
                itemCount: cnt.favouriteDrivers.length,
                itemBuilder: (context, index) {
                  final cardDetails = cnt.favouriteDrivers[index];
                  return // Driver Card
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      '${ApiUrls.imageBaseUrl}${cardDetails
                                          .image}',
                                      height: 85.h,
                                      width: 85.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                          stackTrace) =>
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
                                              color: Colors.yellow,
                                              size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            '${cardDetails
                                                .rating} ( ${cardDetails
                                                .totalRatings} )',
                                            style: TextStyle(
                                              fontFamily:
                                              FontFamily.poppins,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
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
                                              fontFamily:
                                              FontFamily.poppins,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
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
                                              fontFamily:
                                              FontFamily.poppins,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: SvgPicture.asset(
                                      Assets.icons.driverCardPhone),
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
                              fontSize: 14.sp,
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
                                    '${cardDetails.vehicle?.carName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '${cardDetails.vehicle?.numberOfSeat} Seat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '${cardDetails.vehicle?.carPlateNumber}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '5 km away from you.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ],
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  cardDetails.image != null && cardDetails.image!.isNotEmpty
                                      ? '${ApiUrls.imageBaseUrl}${cardDetails.image}'
                                      : 'assets/images/profile-icon.png', // if backend default exists
                                  width: 92.w,
                                  height: 92.h,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/driver.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          // Request Ride
                          RequestRideHandler(cnt: cnt, cardDetails: cardDetails),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     GlassBackgroundMultipleChildrenWidget(
                          //         children: [Text('maruf')]);
                          //     // cnt.fetchSendPickUpRequest(cnt.rideId.value, cardDetails.sId!);
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color(0xFF34A853),
                          //     foregroundColor: Colors.white,
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: 24, vertical: 14),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     elevation: 0,
                          //   ),
                          //   child: Text(
                          //     'Request Ride',
                          //     style: TextStyle(
                          //       fontSize: 15,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10.h);
                },
                padding: EdgeInsets.only(
                  bottom: 16.h,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
