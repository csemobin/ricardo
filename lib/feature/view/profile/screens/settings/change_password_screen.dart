import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/widgets.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  final TextEditingController nameTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
        title: Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.primaryHeadingTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30.h,
          ),
          Center(
            child: Text(
              textAlign: TextAlign.center,
              'Password must be Min 8 characters, include letters & numbers.',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.poppins,
                fontWeight: FontWeight.w500,
                color: AppColors.labelTextColor,
              ),
            ),
          ),
          SizedBox(height: 48.h,),
          CustomTextField(
            controller: nameTEController,
            labelText: 'Current Password',
            hintText: 'Enter your password',
            isPassword: true,
          ),
          CustomTextField(
            controller: nameTEController,
            labelText: 'New Password',
            hintText: 'Enter your password',
            isPassword: true,
          ),
          CustomTextField(
            controller: nameTEController,
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            isPassword: true,
          ),
          SizedBox(height: 30.h,),
          CustomPrimaryButton(title: 'Update', onHandler: (){}),

        ],
      ),
    );
  }
}
