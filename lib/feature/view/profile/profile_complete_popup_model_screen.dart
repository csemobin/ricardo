import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';

class ProfileCompletePopupModalScreen extends StatelessWidget {
  const ProfileCompletePopupModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Spacer(),
          Center(
            child: Image.asset(Assets.images.varifyIcon.path),
          ),
          SizedBox(
            height: 44.h,
          ),
          CustomHeadingText(
            firstText: 'Application',
            secondText: 'Submitted!',
            isSwipedColor: true,
          ),
          SizedBox(
            height: 30.h,
          ),
          CustomSecondaryText(
              text:
                  'Thank you for applying to become a driver on SleeKnit. Our admin team will review your application and contact you via email within 1-2 business days.'),
          Spacer(),
          CustomPrimaryButton(title: 'OK', onHandler: (){
            Get.toNamed(AppRoutes.signInScreen);
          }),
          SizedBox(height: 10.h,)
        ],
      ),
    );
  }
}
