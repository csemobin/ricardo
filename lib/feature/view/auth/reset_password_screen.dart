import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/auth/reset_password_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_loader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/glass_morphishm_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final controller = Get.find<ResetPasswordController>();
  final email = Get.arguments['email'];

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
                    SizedBox(
                      height: 126.h,
                    ),
                    CustomHeadingText(
                      firstText: "Reset Your ",
                      secondText: 'Password',
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.r),
                      child: const CustomSecondaryText(
                        text: 'Password  must have 6-8 characters.',
                      ),
                    ),
                    SizedBox(height: 57.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: controller.resetNewPasswordTEController,
                            labelText: 'New Password',
                            hintText: 'Enter Your Password',
                            isPassword: true,
                          ),
                          CustomTextField(
                            controller:
                                controller.confirmNewPasswordTEController,
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            isPassword: true,
                            validator: (val) {
                              if (controller
                                      .resetNewPasswordTEController.text !=
                                  val) {
                                return "Password does not match";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      if (controller.isResetPasswordStatus.value) {
                        return CustomLoader();
                      }

                      return CustomPrimaryButton(
                        title: 'Reset Password',
                        onHandler: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final success =
                              await controller.resetPasswordHandler(email);

                          if (success && mounted) {
                            await showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.2),
                              builder: (_) => GlassmorphismWidget(),
                            );
                            await Future.delayed(const Duration(seconds: 3));
                            if (mounted) {
                              Navigator.of(context).pop();
                              Get.toNamed(AppRoutes.signInScreen);
                            }
                          }
                        },
                      );
                    }),
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
