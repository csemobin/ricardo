import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 25.h),

                    LogoWidget(
                      width: 200.w,
                      height: 100.h,
                    ),

                    CustomHeadingText(
                      firstText: "Let’s",
                      secondText: ' Sign In.',
                    ),

                    SizedBox(height: 10.h),

                    const CustomSecondaryText(
                      text: 'Fill in your information.',
                    ),

                    SizedBox(height: 32.h),

                    CustomTextField(
                      controller: emailTEController,
                      labelText: 'Email',
                      hintText: 'Enter Your email',
                    ),

                    CustomTextField(
                      controller: passwordTEController,
                      labelText: 'Password',
                      hintText: 'Enter Your Password',
                      isPassword: true,
                    ),

                    SizedBox(height: 15.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.forgotPasswordScreen);
                          },
                          child: Text(
                            'Forgot Password ?',
                            style: TextStyle(
                              color: AppColors.secondaryTextColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    CustomPrimaryButton(
                      title: 'Sign In',
                      onHandler: () {
                        Get.toNamed(AppRoutes.otpVarifyScreen);
                      },
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don’t have an account? ',
                          style: TextStyle(
                            color: AppColors.richTextColor,
                            fontSize: 15.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.greenColor,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
