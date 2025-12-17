import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/logo_widget.dart';

class Backuptemp extends StatefulWidget {
  const Backuptemp({super.key});

  @override
  State<Backuptemp> createState() => _BackuptempState();
}

class _BackuptempState extends State<Backuptemp> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.r),
        child: Column(
          children: [
            Center(
              child: LogoWidget(),
            ),
            CustomHeadingText(
              firstText: 'Welcome!',
              secondText: 'Are you a...',
              isColumn: true,
            ),
            SizedBox(
              height: 50.h,
            ),
            Spacer(),
            CustomPrimaryButton(title: 'Next',onHandler: (){},),
            SizedBox(
              height: 20.h,
            ),
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
                  onTap: () {},
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
