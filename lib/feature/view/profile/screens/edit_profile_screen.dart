import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/widgets.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.primaryHeadingTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: LayoutBuilder(builder: (context, containers) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: containers.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                 SizedBox(height: 53.h,),
                  CustomTextField(
                    controller: phoneController,
                    hintText: 'Enter your name',
                    labelText: 'Full Name',
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
                    title: 'Update',
                    onHandler: () {
                      Get.toNamed(AppRoutes.uploadRequirementScreen);
                    },
                  ),
                  SizedBox(
                    height: 10.h,
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
