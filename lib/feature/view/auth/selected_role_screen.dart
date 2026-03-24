import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/sign_up_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class SelectedRoleScreen extends StatefulWidget {
  const SelectedRoleScreen({super.key});

  @override
  State<SelectedRoleScreen> createState() => _SelectedRoleScreenState();
}

class _SelectedRoleScreenState extends State<SelectedRoleScreen> {
  final controller = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Center(
                        child: LogoWidget(),
                      ),
                      CustomHeadingText(
                        firstText: 'Welcome!',
                        secondText: 'Are you a...',
                        isColumn: true,
                      ),
                      SizedBox(height: 30.h),

                      // Driver Option
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Obx(() {
                          return GestureDetector(
                            onTap: () {
                              controller.selectedRoleHandler('driver');
                            },
                            child: Container(
                              padding: EdgeInsets.all(20.r),
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: AppColors.whiteColor,
                                border: Border.all(
                                  color:
                                      controller.selectedRole.value == 'driver'
                                          ? AppColors.primaryColor
                                          : Color(0Xff0F0F0D).withAlpha(9),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          Assets.images.driver,
                                          width: 36.w,
                                          height: 36.h,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(width: 8.w),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    color: AppColors.greyColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 20.h),

                      // Passenger Option
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Obx(() {
                          return GestureDetector(
                            onTap: () {
                              controller.selectedRoleHandler('passenger');
                            },
                            child: Container(
                              padding: EdgeInsets.all(20.r),
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: AppColors.whiteColor,
                                border: Border.all(
                                  color: controller.selectedRole.value ==
                                          'passenger'
                                      ? AppColors.primaryColor
                                      : Color(0Xff0F0F0D).withAlpha(9),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          Assets.images.passenger,
                                          width: 36.w,
                                          height: 36.h,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(width: 8.w),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    color: AppColors.greyColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      Spacer(),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: CustomPrimaryButton(
                          title: 'Next',
                          onHandler: () {
                            Get.toNamed(AppRoutes.signUpScreen);
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),

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
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
