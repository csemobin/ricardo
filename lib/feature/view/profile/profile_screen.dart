import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_review_screen.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_screen.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_setting_screen.dart';
import 'package:ricardo/feature/view/profile/screens/edit_profile_support_screen.dart';
import 'package:ricardo/feature/view/profile/screens/favourites_ride_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final List<Map<String, dynamic>> screen = [
    {
      "icon": Assets.images.editProfileProfileScreen.path,
      "screenName": "Edit Profile",
      "route" : EditProfileScreen(),
    },
    {
      "icon": Assets.images.viewReviewsProfileScreen.path,
      "screenName": "View Reviews",
      "route" : EditProfileReviewScreen(),
    },
    {
      "icon": Assets.images.supportProfileScreen.path,
      "screenName": "Support",
      "route" : EditProfileSupportScreen(),
    },
    {
      "icon": Assets.images.settingsProfileScreen.path,
      "screenName": "Settings",
      "route" : EditProfileSettingScreen(),
    },
    {
      "icon": Assets.images.editProfileProfileScreen.path,
      "screenName": "Favorites rides",
      "route" : FavouritesRideScreen(),
    },
    {
      "icon": Assets.images.logoutProfileScreen.path,
      "screenName": "LogOut",
      "route" : EditProfileSupportScreen(),
    },
  ];

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
                  onTap: (){
                    Get.to(screen[index]['route']);
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
              padding: EdgeInsets.only(
                bottom: 90.h
              ),
            ),
          ],
        ),
      )
    );
  }
}
