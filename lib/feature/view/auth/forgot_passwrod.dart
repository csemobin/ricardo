import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

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
                    SizedBox(height: 126.h,),
                    CustomHeadingText(
                      firstText: "Forget Your",
                      secondText: ' Password?',
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.r),
                      child: const CustomSecondaryText(
                        text:
                            'Enter your email address to reset your password.',
                      ),
                    ),
                    SizedBox(height: 57.h),
                    CustomTextField(
                      controller: emailTEController,
                      labelText: 'Email',
                      hintText: 'Enter Your email',
                    ),
                    const Spacer(),
                    CustomPrimaryButton(
                      title: 'Get Verification Code',
                      onHandler: () {
                        Get.toNamed(AppRoutes.otpVarifyScreen);
                      },
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
