import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class AuthInitialScreen extends StatelessWidget {
  const AuthInitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      body: Column(
        children: [
          SizedBox(height: 60.h,),
          Center(
            child: LogoWidget(
              height: 80,
            ),
          ),
          SizedBox(height: 30.h,),
          Lottie.asset(Assets.lotties.carpool, fit: BoxFit.cover),
          CustomHeadingText(
            firstText: 'WELCOME TO ',
            secondText: 'THIS APP',
            letterSpacing: 1.2,
          ),
          SizedBox(
            height: 8.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.r),
            child: CustomSecondaryText(
                text:
                    'Seamless, affordable, and reliable ride-sharing at your fingertips.'),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              left: 25.w,
              right: 25.w,
            ),
            child: CustomPrimaryButton(
              title: 'Sign In',
              onHandler: () {
                Get.toNamed(AppRoutes.signInScreen);
              },
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Padding(
              padding: EdgeInsets.only(
                right: 25.w,
                left: 25.w
              ),
            child: GestureDetector(
              child: Container(
                alignment: Alignment.center,
                width: double.maxFinite,
                height: 56.h,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.greenColor,
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(50.r)),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.greenColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              onTap: () => Get.toNamed(AppRoutes.selectedRoleScreen),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
