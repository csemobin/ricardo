import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/profile/favourite_rides_controller.dart';
import 'package:ricardo/feature/simmer/favourite_rider_shimmer.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/glass_morphishm_widget.dart';

class FavouritesRideScreen extends StatefulWidget {
  const FavouritesRideScreen({super.key});

  @override
  State<FavouritesRideScreen> createState() => _FavouritesRideScreenState();
}

class _FavouritesRideScreenState extends State<FavouritesRideScreen> {
  final controller = Get.put(FavouriteRidesController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFavouriteRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
        title: Text(
          'Favorites Riders',
          style: TextStyle(
            color: AppColors.cardTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
        forceMaterialTransparency: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchFavouriteRides();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Obx(() {
              if (controller.isLoadingStatus.value == true) {
                return FavouriteRiderShimmer();
              }

              if (controller.favouriteRiderModel.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No Favourite Rides',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Added Yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.favouriteRiderModel.length,
                itemBuilder: (context, index) {
                  final user = controller.favouriteRiderModel[index];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.h, vertical: 16.h),
                        decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: AppColors.successColor)),
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
                                        // Assets.images.favoritesProfileImage.path,
                                        '${ApiUrls.imageBaseUrl}${user.driverProfileImage?.filename}',
                                        height: 85.h,
                                        width: 85.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.w,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.driverName.toString(),
                                          style: TextStyle(
                                              fontFamily: FontFamily.poppins,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.successColor),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              weight: 12,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              '${user.driverRating} ( ${user.driverTotalRating} )',
                                              style: TextStyle(
                                                fontFamily: FontFamily.poppins,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.blackBText,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8.w,
                                            ),
                                            Container(
                                                width: 2.w,
                                                height: 15.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.30),
                                                )),
                                            SizedBox(
                                              width: 8.w,
                                            ),
                                            Text(
                                              '${user.totalCompletedRides} Trips',
                                              style: TextStyle(
                                                fontFamily: FontFamily.poppins,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.blackBText,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.call,
                                                color: AppColors.greenColor),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              '${user.driverPhone}',
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
                                    )
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      deleteFavouriteRideHandler(user.driverId),
                                  child: Image.asset(
                                      Assets.images.favoriteDusbin.path),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Divider(
                              color: AppColors.successColor,
                              height: 1.h,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              'Car info.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontFamily.poppins,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user.vehicleName}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 14.sp,
                                        color: AppColors.favoriteRitesCarText,
                                      ),
                                    ),
                                    Text(
                                      '${user.vehicleSeats} Seat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 14.sp,
                                        color: AppColors.favoriteRitesCarText,
                                      ),
                                    ),
                                    Text(
                                      '${user.vehiclePlateNumber}',
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
                                    )
                                  ],
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    // Assets.images.favoriteRidesCar.path,

                                    '${ApiUrls.imageBaseUrl}${user.vehicleImage?.filename}',
                                    width: 92.w,
                                    height: 92.h,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8.h);
                },
                padding: EdgeInsets.only(bottom: 16.h),
              );
            }),
          ),
        ),
      ),
    );
  }

  void deleteFavouriteRideHandler(riderId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.15),
                    border: Border.all(color: Colors.white.withOpacity(0.8))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 32.h)),
                    SvgPicture.asset(Assets.images.glassmorphismLogo),
                    SizedBox(
                      height: 30.h,
                    ),
                    Text(
                      'Are you want to delete Ride ??',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    // CustomPrimaryButton(
                    //   title: 'Back to Home',
                    //   onHandler: () {
                    //     Get.toNamed(AppRoutes.signInScreen);
                    //   },
                    // )
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.greyColor500),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: Obx((){
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.errorColor),
                              onPressed: () {
                                controller.deleteFavouriteRide(riderId);
                                Navigator.pop(context);
                              },
                              child: Text(
                                controller.deleteFavouriteRideStatus.value ==
                                    true
                                    ? 'Delete...'
                                    : 'Delete',
                                style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
