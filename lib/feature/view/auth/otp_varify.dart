import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_pin_code_text_field.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';

class OtpVarify extends StatelessWidget {
  const OtpVarify({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                SizedBox(
                height: 125.h,
              ),
              CustomHeadingText(
                  firstText: 'Verify your ', secondText: 'email'),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: CustomSecondaryText(
                    text:
                    "We've sent an mail with an activation code to your Email"),
                ),
                SizedBox(
                  height: 53.h,
                ),
                CustomPinCodeTextField(),
                SizedBox(
                  height: 16.h,
                ),
                Text('00:07'),
                SizedBox(
                  height: 6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSecondaryText(text: "Didn't get the code?"),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.resetPasswordScreen);
                      },
                      child: Text(
                        'Resend',
                        style: TextStyle(
                            color: AppColors.greenColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 22.h,
              ),
              CustomPrimaryButton(
                  title: 'Verify',
                  onHandler: () {
                    Get.toNamed(AppRoutes.signInScreen);
                  },
              ),
              SizedBox(
                height: 12.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Note: ',
                        style: TextStyle(color: Colors.red, fontSize: 12.h),
                      ),
                      TextSpan(
                        text:
                        'If you have not received the email in your inbox, please check your spam or junk folder.',
                        style:
                        TextStyle(color: Color(0Xff808085), fontSize: 12.h),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}