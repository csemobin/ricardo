import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/sign_in_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_review_screen.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_screen.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_setting_screen.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_support_screen.dart';
import 'package:ricardo/feature/view/profile/screens/favourites_ride_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> screen = [
    {
      "icon": Assets.images.editProfileProfileScreen.path,
      "screenName": "Edit Profile",
      "route": EditProfileScreen(),
    },
    {
      "icon": Assets.images.viewReviewsProfileScreen.path,
      "screenName": "View Reviews",
      "route": EditProfileReviewScreen(),
    },
    {
      "icon": Assets.images.supportProfileScreen.path,
      "screenName": "Support",
      "route": EditProfileSupportScreen(),
    },
    {
      "icon": Assets.images.settingsProfileScreen.path,
      "screenName": "Settings",
      "route": EditProfileSettingScreen(),
    },
    {
      "icon": Assets.images.editProfileProfileScreen.path,
      "screenName": "Favorites rides",
      "route": FavouritesRideScreen(),
    },
    {
      "icon": Assets.images.logoutProfileScreen.path,
      "screenName": "LogOut",
      "route": 'logout',
    },
  ];

  void confirmationPopupModal(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
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
                    Image.asset(
                      Assets.images.logout.path,
                      height: 50,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyColor500,
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      'Do you want to log out your account?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            width: double.maxFinite,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: AppColors.greyColor500,
                              borderRadius: BorderRadius.circular(50.r),
                              border: Border.all(
                                color: AppColors.greyColor500,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                            // child: CustomPrimaryButton(
                            //   title: 'Cancel',
                            //   onHandler: () {
                            //     Navigator.pop(context);
                            //     // Get.offAllNamed(AppRoutes.customBottomNavBar);
                            //     // Get.find<CustomBottomNavBarController>().onChange(0);
                            //   },
                            // ),
                            ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Expanded(
                          child: CustomPrimaryButton(
                            title: 'Log Out',
                            onHandler: () {
                              SignInController().logOut();
                              // Get.offAllNamed(AppRoutes.customBottomNavBar);
                              // Get.find<CustomBottomNavBarController>().onChange(0);
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bgColor,
          forceMaterialTransparency: true,
          centerTitle: true,
          title: Text(
            'Profile',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        Assets.images.profileImage.path,
                        height: 85.h,
                        width: 85.w,
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
                          'Rakibul Hasan K',
                          style: TextStyle(
                              fontFamily: FontFamily.poppins,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
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
                                  color: AppColors.blackBText),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.call, color: AppColors.greenColor),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              '+123 456 789',
                              style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.labelTextColor),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: AppColors.greenColor,
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
                                  color: AppColors.labelTextColor),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 28.h,
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (screen[index]['route'] == 'logout') {
                        confirmationPopupModal(context);
                      } else {
                        Get.to(screen[index]['route']);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(screen[index]['icon']),
                              SizedBox(width: 16.w),
                              Text(
                                screen[index]['screenName'],
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackButton,
                                ),
                              ),
                            ],
                          ),
                          Image.asset(Assets.images.arrowDropDown.path),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                  height: 16.h,
                ),
                itemCount: screen.length,
                padding: EdgeInsets.only(bottom: 90.h),
              ),
            ],
          ),
        ));
  }
}
