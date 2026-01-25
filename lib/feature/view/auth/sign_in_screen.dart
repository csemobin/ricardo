import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/sign_in_controller.dart';
import 'package:ricardo/feature/view/auth/forgot_passwrod.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_loader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final controller = Get.find<SignInController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: controller.emailTextEditingController,
                            labelText: 'Email',
                            hintText: 'Enter Your email',
                            isEmail: true,
                          ),
                          CustomTextField(
                            controller:
                                controller.passwordTextEditingController,
                            labelText: 'Password',
                            hintText: 'Enter Your Password',
                            isPassword: true,
                          ),
                        ],
                      ),
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

                    // const Spacer(),
                    SizedBox(
                      height: 50.h,
                    ),
                    Obx(
                      () {
                        if (controller.isLoginStatus.value) {
                          return CustomLoader();
                        }

                        return Opacity(
                          opacity: controller.canSubmit.value ? 1 : 0.6,
                          child: CustomPrimaryButton(
                            title: 'Sign In',
                            onHandler: controller.canSubmit.value
                              ? () => _signIn(controller, context )
                            : null,
                            // onHandler: () {
                            //
                            //   // Get.toNamed(AppRoutes.driverProfileCreateScreen);
                            // },
                          ),
                        );
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
                          onTap: () {
                            Get.toNamed(AppRoutes.selectedRoleScreen);
                          },
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _signIn(SignInController controller, BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    controller.logInUser();
  }
}
