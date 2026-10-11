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
import 'package:ricardo/services/direction_services.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/request_ride_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class NearByDriverScreen extends StatefulWidget {
  const NearByDriverScreen({super.key});

  @override
  State<NearByDriverScreen> createState() => _NearByDriverScreenState();
}

class _NearByDriverScreenState extends State<NearByDriverScreen> {
  final googleSearchLocationController = Get.find<GoogleSearchLocationController>();
  late final String title;
  late final String estimatedCost;

  @override
  void initState() {
    super.initState();
    title = Get.arguments?['title'] ?? 'Nearby Drivers';
    estimatedCost = Get.arguments?['estimatedCost']?.toString() ?? '0';
  }

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
            SizedBox(height: 18.h),
            Obx(() {
              final cnt = Get.find<RideController>();
              return cnt.drivers.isNotEmpty
                  ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup location
                        Row(
                          children: [
                            Image.asset(
                              Assets.images.originHumanLogo.path,
                              width: 20.w,
                              height: 20.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                googleSearchLocationController.pickupController.text,
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
                          margin: EdgeInsets.only(left: 8.w, top: 5.h, bottom: 5.h),
                          width: 2.w,
                          height: 20.h,
                          color: AppColors.blackColor,
                        ),
                        // Drop location
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
                                googleSearchLocationController.dropController.text,
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
                  : const SizedBox.shrink();
            }),
            Divider(
              color: AppColors.greenColor,
              thickness: 1.h,
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
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
                    '\$$estimatedCost',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
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
                                  'Nearby rides (${_formatNumber(cnt.drivers.length)})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cnt.selectedTab.value == 0
                                        ? AppColors.greenColor
                                        : AppColors.swippedButtonColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: FontFamily.poppins,
                                    fontSize: cnt.selectedTab.value == 0 ? 18.sp : 16.sp,
                                  ),
                                ),
                              ),
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
                                  'Favorites rides (${_formatNumber(cnt.favouriteDrivers.length)})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cnt.selectedTab.value == 1
                                        ? AppColors.greenColor
                                        : AppColors.swippedButtonColor,
                                    fontWeight: cnt.selectedTab.value == 1
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: cnt.selectedTab.value == 1 ? 18.sp : 16.sp,
                                  ),
                                ),
                              ),
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
            SizedBox(height: 18.h),
            Obx(() {
              final cnt = Get.find<RideController>();
              return cnt.selectedTab.value == 0
                  ? ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: cnt.drivers.length,
                itemBuilder: (context, index) {
                  final cardDetails = cnt.drivers[index];
                  return _buildDriverCard(cnt, cardDetails);
                },
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                padding: EdgeInsets.only(bottom: 16.h),
              )
                  : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: cnt.favouriteDrivers.length,
                itemBuilder: (context, index) {
                  final cardDetails = cnt.favouriteDrivers[index];
                  return _buildDriverCard(cnt, cardDetails);
                },
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                padding: EdgeInsets.only(bottom: 16.h),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number == 0) return '00';
    return number < 10 ? '0$number' : '$number';
  }

  Widget _buildDriverCard(RideController cnt, dynamic cardDetails) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
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
                    borderRadius: BorderRadius.circular(50.r),
                    child: Image.network(
                      '${ApiUrls.imageBaseUrl}${cardDetails.image}',
                      height: 85.h,
                      width: 85.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: 85.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardDetails.name?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: FontFamily.poppins,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.yellow, size: 16),
                          SizedBox(width: 4.w),
                          Text(
                            '${cardDetails.rating ?? 0} (${cardDetails.totalRatings ?? 0})',
                            style: TextStyle(
                              fontFamily: FontFamily.poppins,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBText,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 2.w,
                            height: 15.h,
                            color: Colors.black.withOpacity(0.30),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${cardDetails.trips ?? 0} Trips',
                            style: TextStyle(
                              fontFamily: FontFamily.poppins,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.call, color: AppColors.greenColor, size: 16),
                          SizedBox(width: 4.w),
                          Text(
                            cardDetails.phone?.toString() ?? 'N/A',
                            style: TextStyle(
                              fontFamily: FontFamily.poppins,
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
                onTap: () {
                  final phone = cardDetails.phone?.toString();
                  if (phone != null && phone.isNotEmpty) {
                    launchUrl(Uri.parse("tel:$phone"));
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SvgPicture.asset(
                    Assets.icons.driverCardPhone,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: AppColors.successColor, height: 1.h),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardDetails.vehicle?.carName ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.poppins,
                        fontSize: 14.sp,
                        color: AppColors.favoriteRitesCarText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${cardDetails.vehicle?.numberOfSeat ?? 0} Seat',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.poppins,
                        fontSize: 14.sp,
                        color: AppColors.favoriteRitesCarText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      cardDetails.vehicle?.carPlateNumber ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.poppins,
                        fontSize: 14.sp,
                        color: AppColors.favoriteRitesCarText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    FutureBuilder<String>(
                      future: DirectionsService.calculateDistance(
                        cardDetails.location?.coordinates?[0],
                        cardDetails.location?.coordinates?[1],
                      ),
                      builder: (context, snapshot) {
                        final distanceText = snapshot.data ?? 'Calculating...';
                        return Text(
                          '$distanceText away from you.',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: FontFamily.poppins,
                            fontSize: 14.sp,
                            color: AppColors.dottedBorderColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  cardDetails.vehicle?.carImage?.filename != null
                      ? '${ApiUrls.imageBaseUrl}${cardDetails.vehicle?.carImage?.filename}'
                      : '',
                  width: 92.w,
                  height: 92.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.directions_car, size: 92.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          RequestRideHandler(cnt: cnt, cardDetails: cardDetails),
        ],
      ),
    );
  }
}