import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/change_password_controller.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final controller = Get.find<ChangePasswordController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: AppColors.primaryHeadingTextColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.primaryHeadingTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Obx(
        () {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Instructions
                  Text(
                    'Password Requirements:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: FontFamily.poppins,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryHeadingTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '• Minimum 8 characters\n• Try to include letters & numbers\n• New password must be different from current',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.poppins,
                      fontWeight: FontWeight.w400,
                      color: AppColors.labelTextColor,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Current Password Field
                  CustomTextField(
                    controller: controller.currentPasswordTEController,
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                    isPassword: true,
                    validator: (value) {
                      return controller.validateCurrentPassword(value);
                    },
                    onChanged: (_) => controller.validateForm(),
                  ),

                  SizedBox(height: 20.h),

                  // New Password Field
                  CustomTextField(
                    controller: controller.newPasswordTEController,
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                    isPassword: true,
                    validator: (value) {
                      return controller.validateNewPassword(value);
                    },
                    onChanged: (_) => controller.validateForm(),
                  ),

                  SizedBox(height: 20.h),

                  // Confirm Password Field
                  CustomTextField(
                    controller: controller.confirmPasswordTEController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter new password',
                    isPassword: true,
                    validator: (value) {
                      return controller.validateConfirmPassword(value);
                    },
                    onChanged: (_) => controller.validateForm(),
                  ),

                  SizedBox(height: 8.h),

                  // Error Message Display
                  if (controller.errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  SizedBox(height: 32.h),

                  // Submit Button
                  Obx(() {
                    return CustomPrimaryButton(
                      title: controller.isLoading.value
                          ? 'Submitting...'
                          : 'Update Password',
                      onHandler: controller.isFormValid.value &&
                              !controller.isLoading.value
                          ? () => _submitForm()
                          : null,
                      // isLoading: controller.isLoading.value,
                    );
                  }),

                  SizedBox(height: 20.h),

                  // Additional Info
                  Text(
                    'Note: After changing your password, you will be logged out and need to sign in again.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.poppins,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
          // return Stack(
          //   children: [
          //
          //
          //     // Loading Overlay
          //     // if (controller.isLoading.value)
          //     //   Container(
          //     //     color: Colors.black.withOpacity(0.3),
          //     //     child: Center(
          //     //       child: CircularProgressIndicator(
          //     //         color: AppColors.primaryColor,
          //     //       ),
          //     //     ),
          //     //   ),
          //   ],
          // );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate and submit
    await controller.changePassword();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
