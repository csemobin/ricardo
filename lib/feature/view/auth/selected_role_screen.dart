import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_tost_message.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class SelectedRoleScreen extends StatefulWidget {
  const SelectedRoleScreen({super.key});

  @override
  State<SelectedRoleScreen> createState() => _SelectedRoleScreenState();
}

class _SelectedRoleScreenState extends State<SelectedRoleScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Center(
            child: LogoWidget(),
          ),
          CustomHeadingText(
            firstText: 'Welcome!',
            secondText: 'Are you a...',
            isColumn: true,
          ),
          SizedBox(
            height: 50.h,
          ),
          Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.whiteColor,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 2,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(Assets.images.driver.path),
                              SizedBox(
                                width: 8.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Driver',
                                    style: TextStyle(
                                      color: AppColors.greenColor,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Earn Extra Income',
                                    style: TextStyle(
                                      color: AppColors.greyColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: AppColors.greyColor,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      return setState(() {
                        showToast('Driver Selected');
                      });
                    },
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.whiteColor,
                          border: Border.all(
                              color: Color(0Xff0F0F0D).withAlpha(9), width: 2)
                          // border: Border.all(
                          //   color: AppColors.primaryColor,
                          //   width: 2,
                          // ),
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(Assets.images.passenger.path),
                              SizedBox(
                                width: 8.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Passenger',
                                    style: TextStyle(
                                      color: AppColors.greenColor,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Earn extra income',
                                    style: TextStyle(
                                      color: AppColors.greyColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios_sharp,
                            color: AppColors.greyColor,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      return setState(() {
                        showToast('Passenger Selected');
                      });
                    },
                  )
                ],
              )
            ],
          ),
          Spacer(),
          Spacer(),
          Spacer(),
          Spacer(),
          CustomPrimaryButton(
            title: 'Next',
            onHandler: () {
              Get.toNamed(AppRoutes.signUpScreen);
            },
          ),
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?  ',
                style: TextStyle(
                  color: AppColors.richTextColor,
                  fontSize: 15,
                ),
              ),
              GestureDetector(
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.greenColor,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.signInScreen);
                },
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
