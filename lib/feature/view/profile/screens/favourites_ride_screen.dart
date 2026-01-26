import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/favourite_rides_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

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
          'Favorites Rides',
          style: TextStyle(
            color: AppColors.cardTitle,
            fontWeight: FontWeight.w700,
          ),
        ),
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.favouriteRiderModel.length,
              itemBuilder: (context, index) {
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
                                    child: Image.asset(
                                      Assets.images.favoritesProfileImage.path,
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
                                        'Rakibul Hasan K',
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
                                            '4.5 (40)',
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
                                            '253 Trips',
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
                                            '+123 456 789',
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
                              Image.asset(Assets.images.favoriteDusbin.path),
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
                                    'Suzuki Alto 800',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    '4 Seat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      color: AppColors.favoriteRitesCarText,
                                    ),
                                  ),
                                  Text(
                                    'DHK METRO HA 64-8888',
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
                                child: Image.asset(
                                  Assets.images.favoriteRidesCar.path,
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
            ),
          ),
        ),
      ),
    );
  }
}
