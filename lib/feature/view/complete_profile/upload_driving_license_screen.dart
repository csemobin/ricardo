import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_image_uploader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class UploadDrivingLicenseScreen extends StatelessWidget {
  UploadDrivingLicenseScreen({super.key});

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Driving License',
                style: AppCustomDesign.headingTextStyle,
              ),
            ),
            SizedBox(
              height: 77.h,
            ),
            CustomTextField(
              controller: nameController,
              labelText: 'Driving License No',
              hintText: 'Enter your NID no.',
            ),
            SizedBox(
              height: 10.h,
            ),
            CustomImageUploader(
              label: 'Upload Your Driving License picture (Front)',
              uploadedTitle: 'Upload files',
              fileSize: '25',
              buttonTitle: 'Browse Files',
            ),
            SizedBox(
              height: 20.h,
            ),
            CustomImageUploader(
              label: 'Upload Your Driving License picture (Back)',
              uploadedTitle: 'Upload files',
              fileSize: '25',
              buttonTitle: 'Browse Files',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 24.w),
          child: CustomPrimaryButton(
            title: 'Submit',
            onHandler: () {
              Get.toNamed(AppRoutes.carRegistrationScreen);
            },
          ),
        ),
      ),
    );
  }
}
