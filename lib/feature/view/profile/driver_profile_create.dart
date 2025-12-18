import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class DriverProfileCreate extends StatelessWidget {
  DriverProfileCreate({super.key});

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body: LayoutBuilder(builder: (context, containers) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: containers.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Center(
                  child: CustomHeadingText(
                    firstText: 'Complete Your ',
                    secondText: 'Profile',
                    isColumn: true,
                    isSwipedColor: true,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Center(
                  child: CustomSecondaryText(text: 'Fill in your information'),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Stack(
                  children: [
                    Image.asset(
                      Assets.images.vector.path,
                      height: 122,
                      width: 122,
                    ),
                    Positioned(
                      bottom: 10.h,
                      right: 15.h,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Color(0XffEDEDED),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(Assets.images.editPencil.path),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Enter Your Number',
                  labelText: 'Phone No.',
                  prefixIcon: Icon(Icons.flag),
                ),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'DD-MM-YY',
                  labelText: 'Date of Birth',
                  isDatePicker: true,
                  suffixIcon: Icon(Icons.date_range),
                ),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Male',
                  labelText: 'Gender',
                  suffixIcon: Icon(Icons.keyboard_arrow_down),
                ),
                CustomTextField(
                  controller: phoneController,
                  labelText: 'About Me',
                  minLines: 5,
                ),
                SizedBox(
                  height: 100.h,
                ),
                // CustomPrimaryButton(title: 'Continue', onHandler: ()=> Get.toNamed(AppRoutes.uploadRequirementScreen)),
                CustomPrimaryButton(
                  title: 'Continue',
                  onHandler: () {
                    Get.toNamed(AppRoutes.uploadRequirementScreen);
                  },
                ),
                SizedBox(height: 10.h,)
              ],
            ),
          ),
        ),
      );
    }));
  }
}
