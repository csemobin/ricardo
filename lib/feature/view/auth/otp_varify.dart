import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/otp_varify_controller.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_pin_code_text_field.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';

class OtpVarify extends StatefulWidget {
  const OtpVarify({super.key});

  @override
  State<OtpVarify> createState() => _OtpVarifyState();
}

class _OtpVarifyState extends State<OtpVarify> {
  final email = Get.arguments['email'];
  final route = Get.arguments['route'];

  final controller = Get.find<OtpVerifyController>();

  @override
  void initState() {
    super.initState();
    // controller.startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startTimer();
    });
    // controller.startTimerSafely();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 125.h),
                  CustomHeadingText(
                    firstText: 'Verify your ',
                    secondText: 'email',
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Obx((){
                      return CustomSecondaryText(
                        text: controller.isTimerActive.value == true ? "We've sent $email an mail with an activation Opt Code" : "We've sent an mail with an activation code to your Email",
                      );
                    }),
                  ),
                  SizedBox(height: 53.h),
                  CustomPinCodeTextField(
                    textEditingController: controller.pinTEController,
                  ),
                  SizedBox(height: 16.h),

                  // Timer or Resend Button
                  Obx(() {
                    return controller.isTimerActive.value
                        ? Text(
                      controller.formattedTime,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: controller.secondsRemaining.value < 60
                            ? AppColors.errorColor
                            : AppColors.blackBText,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomSecondaryText(text: "Didn't get the code?"),
                        TextButton(
                          onPressed: () {
                            controller.otpEmail.value = email;
                            controller.resendOtp(email);
                          },
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: AppColors.greenColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Section
          Column(
            children: [
              SizedBox(height: 22.h),

              // Verify Button - FIXED: Move the variable INSIDE Obx
              Obx(() {
                // Move this line INSIDE Obx so it can observe the text changes
                final isButtonEnabled = controller.otpText.value.length == 6;

                return Opacity(
                  opacity: isButtonEnabled ? 1 : 0.6,
                  child: CustomPrimaryButton(
                    title: 'Verify',
                    onHandler: isButtonEnabled
                        ? () {
                      controller.varifyOtp(route, email);
                    }
                        : null,
                  ),
                );
              }),

              SizedBox(height: 12.h),

              // Note Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Note: ',
                        style: TextStyle(color: Colors.red, fontSize: 12.h),
                      ),
                      TextSpan(
                        text: 'If you have not received the email in your inbox, please check your spam or junk folder.',
                        style: TextStyle(color: Color(0Xff808085), fontSize: 12.h),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ],
      ),
    );
  }
}