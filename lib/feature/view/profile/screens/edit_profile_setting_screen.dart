import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/view/profile/screens/settings/about_us_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/change_password_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/legal_policy_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/privacy_policy_screen.dart';
import 'package:ricardo/feature/view/profile/screens/settings/terms_condition_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class EditProfileSettingScreen extends StatelessWidget{
  EditProfileSettingScreen({super.key});

  final List<Map<String, dynamic>> screen = [
    {
      "icon": Assets.images.settingLockIcon.path,
      "screenName": "Change Password",
      "route" : ChangePasswordScreen(),
    },
    {
      "icon": Assets.images.settingAboutIcon.path,
      "screenName": "About Us",
      "route" : LegalPolicyScreen(),
    },
    {
      "icon": Assets.images.settingTermsAndConditionIcon.path,
      "screenName": "Terms & Conditions",
      "route" : LegalPolicyScreen(),
    },
    {
      "icon": Assets.images.settingPrivacyPolicyIcon.path,
      "screenName": "Privacy Policy",
      "route" : LegalPolicyScreen(),
    },
    {
      "icon": Assets.images.settingDeleteIcon.path,
      "screenName": 'Delete Account',
      "route" : PrivacyPolicyScreen(),
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
                  onTap: (){
                    final route = screen[index]['screenName'];
                    if(route == "About Us" || route == "Terms & Conditions" || route == "Privacy Policy"){
                      if( route == "About Us" ){
                        Get.to(screen[index]['route'], arguments: {'title': route, 'route' : 'about'});
                      }else if(route == "Terms & Conditions"){
                        Get.to(screen[index]['route'], arguments: {'title': route, 'route' : 'terms'});
                      }else{
                        Get.to(screen[index]['route'], arguments: {'title': route, 'route' : 'privacy'});
                      }
                    } else {
                      Get.to(screen[index]['route']);
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