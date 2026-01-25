import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/sign_up_controller.dart';
import 'package:ricardo/feature/view/profile/screens/settings/legal_policy_screen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_loader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/logo_widget.dart';
import 'package:ricardo/widgets/custom_tost_message.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final GlobalKey<FormState> _globalFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpController>();
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _globalFormKey,
          child: Column(
            children: [
              SizedBox(height: 25.h),
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
              SizedBox(height: 10.h),
              Center(
                child: CustomSecondaryText(text: 'Fill in your information.'),
              ),
              SizedBox(height: 32.h),
              CustomTextField(
                controller: controller.nameTEController,
                labelText: 'Name',
                hintText: 'Enter Your Name',
                onChanged: (value) => controller.updateFormValidity(),
              ),
              CustomTextField(
                controller: controller.emailTEController,
                labelText: 'Email',
                hintText: 'Enter Your Email',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => controller.updateFormValidity(),
                isEmail: true,
              ),
              CustomTextField(
                controller: controller.passwordTEController,
                labelText: 'New password',
                hintText: 'Enter Your Password',
                isPassword: true,
                onChanged: (value) => controller.updateFormValidity(),
              ),
              CustomTextField(
                controller: controller.confirmPasswordTEController,
                labelText: 'Confirm Password',
                hintText: 'Enter your Confirm Password',
                isPassword: true,
                onChanged: (value) => controller.updateFormValidity(),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your password';
                  }
                  // ✅ Fixed: Compare .text instead of .value
                  if (controller.passwordTEController.text != val) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Obx(() {
                    return Checkbox(
                      value: controller.isSelected.value,
                      checkColor: AppColors.whiteColor,
                      activeColor: AppColors.greenColor,
                      side: WidgetStateBorderSide.resolveWith((state) {
                        if (state.contains(WidgetState.selected)) {
                          return BorderSide(
                            color: AppColors.greenColor,
                            width: 2,
                          );
                        }
                        return BorderSide(
                            color: AppColors.greenColor, width: 2);
                      }),
                      onChanged: (val) => controller.isSelectedCheckbox(val!),
                    );
                  }),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          'I agree with this ',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Get.toNamed(AppRoutes.termsAndConditionScreen);
                            Get.toNamed( AppRoutes.legalPolicyScreen, arguments: {'title': 'Terms & Conditions', 'route' : 'terms'});
                          },
                          child: Text(
                            'Terms of Use ',
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColors.greenColor),
                          ),
                        ),
                        Text(
                          'and ',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        GestureDetector(
                          child: Text(
                            'Privacy Policy.',
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColors.greenColor),
                          ),
                          onTap: () {
                            // Get.toNamed(AppRoutes.privacyPolicyScreen);
                            Get.toNamed( AppRoutes.legalPolicyScreen, arguments: {'title': 'Privacy Policy', 'route' : 'privacy'});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 33.h),
              Obx(() {
                if (controller.isRegistrationStatus.value) {
                  return CustomLoader();
                }

                return Opacity(
                  opacity: controller.canSubmit.value ? 1.0 : 0.6,
                  child: CustomPrimaryButton(
                    title: 'Sign Up',
                    onHandler: controller.canSubmit.value
                        ? () => _signUp(controller)
                        : null,
                  ),
                );
              }),
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp(SignUpController controller) {
    if (!_globalFormKey.currentState!.validate()) return;

    if (controller.passwordTEController.text !=
        controller.confirmPasswordTEController.text) {
      showToast('Passwords do not match');
      return;
    }

    if (!controller.isSelected.value) {
      showToast('Please accept Terms and Privacy Policy');
      return;
    }

    controller.userRegistration();
  }
}
