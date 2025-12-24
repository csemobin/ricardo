import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController nameTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 25.h,
            ),
          ),
          Center(
            child: LogoWidget(
              width: 200.w,
              height: 100.h,
            ),
          ),
          Center(
            child: CustomHeadingText(
              firstText: 'Create An',
              secondText: ' Account',
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Center(
            child: CustomSecondaryText(text: 'Fill in your information.'),
          ),
          SizedBox(
            height: 32.h,
          ),
          CustomTextField(
            controller: nameTEController,
            labelText: 'Name',
            hintText: 'Enter Your Name',
          ),
          CustomTextField(
            controller: nameTEController,
            labelText: 'Email',
            hintText: 'Enter Your Email',
          ),
          CustomTextField(
            controller: nameTEController,
            labelText: 'New password',
            hintText: 'Enter Your Password',
            isPassword: true,
          ),
          CustomTextField(
            controller: nameTEController,
            labelText: 'Confirm Password',
            hintText: 'Enter your Confirm Password',
            isPassword: true,
          ),
          SizedBox(
            height: 30.h,
          ),
          Row(
            children: [
              Checkbox(
                value: true,
                checkColor: AppColors.whiteColor,
                activeColor: AppColors.greenColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.r)),
                onChanged: (val) {},
              ),
              Text(
                'I agree with this ',
                style: TextStyle(fontSize: 12.sp),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.termsAndConditionScreen);
                },
                child: Text(
                  'Terms of Use ',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.greenColor),
                ),
              ),
              Text(
                'and ',
                style: TextStyle(fontSize: 12.sp),
              ),
              GestureDetector(
                child: Text(
                  'Privacy Policy.',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.greenColor),
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.privacyPolicyScreen);
                },
              )
            ],
          ),
          SizedBox(
            height: 33.h,
          ),
          CustomPrimaryButton(title: 'Sign Up',onHandler: (){
            Get.toNamed(AppRoutes.otpVarifyScreen);
          },),
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
                onTap: (){
                  Get.toNamed(AppRoutes.signInScreen);
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
