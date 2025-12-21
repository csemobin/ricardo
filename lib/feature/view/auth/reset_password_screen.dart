
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
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
                    SizedBox(
                      height: 126.h,
                    ),
                    CustomHeadingText(
                      firstText: "Reset Your ",
                      secondText: ' Password',
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.r),
                      child: const CustomSecondaryText(
                        text: 'Password  must have 6-8 characters.',
                      ),
                    ),
                    SizedBox(height: 57.h),
                    CustomTextField(
                      controller: emailTEController,
                      labelText: 'New Password',
                      hintText: 'Enter Your Password',
                    ),
                    CustomTextField(
                      controller: emailTEController,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                    ),
                    const Spacer(),
                    CustomPrimaryButton(
                      title: 'Reset Password',
                      onHandler: (){
                        showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.2),
                            builder: (_)=> const GlassmorphismWidget()
                        );
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
