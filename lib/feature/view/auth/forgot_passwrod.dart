import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/auth/forget_password_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_loader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final controller = Get.find<ForgetPasswordController>();
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
                    Form(
                      key: _formKey,
                      child: CustomTextField(
                        controller: controller.forgetPasswordTEController,
                        labelText: 'Email',
                        hintText: 'Enter Your email',
                        isEmail: true,
                      ),
                    ),
                    const Spacer(),
                    Obx((){
                      return controller.isForgetPasswordStatus.value == true ? CustomLoader() : CustomPrimaryButton(
                        title: 'Get Verification Code',
                        onHandler: _varifyButtonHandler,
                        // onHandler: () {
                        //   // Get.toNamed(AppRoutes.resetPasswordScreen);
                        //
                        // },
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
  void _varifyButtonHandler(){
    if( !_formKey.currentState!.validate()) return;
    controller.forgetPassword();
  }
}
