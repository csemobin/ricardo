import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/view/profile/screens/settings/change_password_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/legal_policy_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/privacy_policy_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class EditProfileSettingScreen extends StatelessWidget {
  EditProfileSettingScreen({super.key});

  final List<Map<String, dynamic>> screen = [
    {
      "icon": Assets.images.settingLockIcon.path,
      "screenName": "Change Password",
      "route": ChangePasswordScreen(),
    },
    {
      "icon": Assets.images.settingAboutIcon.path,
      "screenName": "About Us",
      "route": LegalPolicyScreen(),
    },
    {
      "icon": Assets.images.settingTermsAndConditionIcon.path,
      "screenName": "Terms & Conditions",
      "route": LegalPolicyScreen(),
    },
    {
      "icon": Assets.images.settingPrivacyPolicyIcon.path,
      "screenName": "Privacy Policy",
      "route": LegalPolicyScreen(),
    },
    {
      "icon": Assets.images.settingDeleteIcon.path,
      "screenName": 'Delete Account',
      "route": PrivacyPolicyScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 28.h,
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    final route = screen[index]['screenName'];
                    if (route == "About Us" ||
                        route == "Terms & Conditions" ||
                        route == "Privacy Policy") {
                      if (route == "About Us") {
                        Get.to(screen[index]['route'],
                            arguments: {'title': route, 'route': 'about'});
                      } else if (route == "Terms & Conditions") {
                        Get.to(screen[index]['route'],
                            arguments: {'title': route, 'route': 'terms'});
                      } else {
                        Get.to(screen[index]['route'],
                            arguments: {'title': route, 'route': 'privacy'});
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding:
                                EdgeInsets.symmetric(horizontal: 24.w),
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
                                      color: AppColors.whiteColor
                                          .withOpacity(0.15),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.8))),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: 10.h)),
                                      Image.asset(
                                        Assets.images.removeBusket.path,
                                        width: 50.w,
                                        height: 50.h,
                                        fit: BoxFit.fill,
                                      ),
                                      SizedBox(
                                        height: 30.h,
                                      ),
                                      Text(
                                        'Are you want to delete account ??',
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
                                                  backgroundColor:
                                                      AppColors.greyColor500),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: AppColors.whiteColor,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.errorColor),
                                              onPressed: () {
                                                // controller.deleteFavouriteRide(riderId);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              // child: Text(
                                              //   controller.deleteFavouriteRideStatus.value ==
                                              //       true
                                              //       ? 'Delete...'
                                              //       : 'Delete',
                                              //   style: TextStyle(
                                              //       color: AppColors.whiteColor,
                                              //       fontWeight: FontWeight.w500),
                                              // ),
                                            ),
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
                      // Get.to(screen[index]['route']);
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
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
            ),
          ),
        ],
      ),
    );
  }
}
