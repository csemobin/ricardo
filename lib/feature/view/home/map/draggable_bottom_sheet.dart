import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/models/socket/accept_ride_model.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';

class DraggableBottomSheet extends StatefulWidget {
  final AcceptRideModel? acceptRideModel;

  const DraggableBottomSheet({super.key, this.acceptRideModel});

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.49,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      expand: false,
      // ✅ FIX 1: Required when used inside showModalBottomSheet
      builder: (context, scrollController) {
        return GlassBackgroundWidget(
          blurNumber: 25,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ────────────────────────────────────────
                // HEADER SECTION (drag handle + status row)
                // ────────────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(vertical: 11, horizontal: 18),
                  decoration: BoxDecoration(
                    // color: Colors.white.withOpacity(0.7),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Drag handle indicator
                      Center(
                        child: Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Status row: "Rider is on the way" + "1 min" badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'Rider is on the way to pickup',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackColor,
                                  fontFamily: FontFamily.poppins,
                                ),
                              ),
                            ],
                          ),
                          /*Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.darkColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '1 min',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                fontFamily: FontFamily.poppins,
                                color: Colors.white,
                              ),
                            ),
                          ),*/
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.darkColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '1 min',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                fontFamily: FontFamily.poppins,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ────────────────────────────────────────
                // GLASS BODY SECTION (driver info + car info)
                // ────────────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.h,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      // ── Driver info row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Driver avatar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  '${ApiUrls.imageBaseUrl}${widget.acceptRideModel?.driver?.driverImage}',
                                  height: 62.h,
                                  width: 62.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      // 'assets/images/default_driver.png',
                                      Assets.images.defaultImage.path,
                                      // fallback image
                                      height: 62.h,
                                      width: 62.w,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // Driver name, rating, trips, phone
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.acceptRideModel?.driver?.driverName}',
                                    style: TextStyle(
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: AppColors.orangeColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.acceptRideModel?.driver?.totalRatings ?? 0} ( ${widget.acceptRideModel?.driver?.ratingAverage ?? 0.0} )',
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
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.30),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '${widget.acceptRideModel?.driver?.totalCompletedRides ?? 0} Trips',
                                        style: TextStyle(
                                          fontFamily: FontFamily.poppins,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.blackBText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.call,
                                          color: AppColors.greenColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.acceptRideModel?.driver?.driverPhone}',
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

                          // Phone call button (SVG icon)
                          GestureDetector(
                            onTap: () {},
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
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ── Car info row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.acceptRideModel?.driverCar?.carName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  color: AppColors.favoriteRitesCarText,
                                ),
                              ),
                              Text(
                                '${widget.acceptRideModel?.driverCar?.numberOfSeat} Seat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  color: AppColors.favoriteRitesCarText,
                                ),
                              ),
                              Text(
                                '${widget.acceptRideModel?.driverCar?.carPlateNumber}',
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
                            child: Image.asset(
                              Assets.images.favoriteRidesCar.path,
                              width: 92.w,
                              height: 92.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      CustomPrimaryButton(
                          title: 'Provide a review',
                          onHandler: (){
                            Get.toNamed(AppRoutes.rateReviewDriver);
                          }
                      ),
                      SizedBox(height: 14.h,),
                      GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (context) {
                            return AboutDialog(
                              children: [
                                GlassBackgroundWidget(child: Text('maruf'))
                              ],
                            );
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: double.maxFinite,
                          height: 56.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(  // ✅ Gradient border
                              colors: [
                                Color(0xff1BB600),
                                Color(0xff007635),
                                Color(0xff01AF44),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Provide a Tip',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
