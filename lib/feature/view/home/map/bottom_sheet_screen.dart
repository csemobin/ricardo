import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';

class BottomSheetScreen extends StatefulWidget {
  const BottomSheetScreen({super.key});

  @override
  State<BottomSheetScreen> createState() => _BottomSheetScreenState();
}

class _BottomSheetScreenState extends State<BottomSheetScreen> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.49,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 11, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Color(0xFFB9C0C9),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          // color: Colors.red,
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                'Rider is on the way to pickup',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.blackColor,
                                    fontFamily: FontFamily.poppins),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: AppColors.darkColor,
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(
                              '1 min',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  fontFamily: FontFamily.poppins,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              GlassBackgroundWidget(
                padding: EdgeInsets.all(0),
                borderRadius: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
                  decoration: BoxDecoration(
                      // color: Colors.black.withOpacity(0.1),
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
                                child: Image.asset(
                                  Assets.images.favoritesProfileImage.path,
                                  // '',
                                  height: 62.h,
                                  width: 62.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                width: 12.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MD RAKIB',
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
                                        color: AppColors.orangeColor,
                                        weight: 12,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${40} ( ${3.2} )',
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
                                            color:
                                                Colors.black.withOpacity(0.30),
                                          )),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      Text(
                                        '${100} Trips',
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
                                        '${12121212121212}',
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
                      SizedBox(
                        height: 10.h,
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
                                'BMW',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  color: AppColors.favoriteRitesCarText,
                                ),
                              ),
                              Text(
                                '${4} Seat',
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
                              // '${ApiUrls.imageBaseUrl}${user.vehicleImage?.filename}',
                              width: 92.w,
                              height: 92.h,
                              fit: BoxFit.cover,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 36.h,
                      ),
                      Container(
                        height: 35,
                        width: 156,
                        padding: EdgeInsets.symmetric(
                            vertical: 10.w, horizontal: 12.h),
                        decoration: BoxDecoration(
                            color: Color(0xff1BB600).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(9.r)),
                        child: Row(
                          children: [
                            Text(
                              'Waiting Time ',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Text(
                              '(min)',
                              style: TextStyle(fontSize: 8.sp),
                            ),
                            Text(
                              ': 00:07',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greenColor,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 17.h,
                      ),
                      Text(
                        'If you have entered the car, please confirm with your\n driver to start the ride in the app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.greenColor,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    // return Obx(() {
    //   // if (rideController.isSwippedButtonShow.value == false) {
    //   bool isTrue = true;
    //   if( isTrue ){
    //     return Text('maruf');
    //   }
    //   return SizedBox.shrink();
    // });
  }
}
