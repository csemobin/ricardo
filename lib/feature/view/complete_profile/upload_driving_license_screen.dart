import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/feature/controllers/driving_license_controller.dart';
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
    final controller = Get.find<DrivingLicenseController>();
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
            SizedBox(height: 77.h),

            CustomTextField(
              controller: nameController,
              labelText: 'Driving License No',
              hintText: 'Enter your NID no.',
              keyboardType: TextInputType.number,
              inputFormatter: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                FilteringTextInputFormatter.digitsOnly
              ],
            ),

            SizedBox(height: 10.h),

            // FRONT SIDE
            Obx(() {
              return controller.selectedDrivingLicenseFront.value != null
                  ? _buildImagePreview(
                      controller.selectedDrivingLicenseFront.value!,
                      () => controller.removeImage(
                            'front',
                          ),
                      'Upload Your Driving License picture (Front)')
                  : CustomImageUploader(
                      label: 'Upload Your Driving License picture (Front)',
                      uploadedTitle: 'Upload files',
                      fileSize: '25',
                      buttonTitle: 'Browse Files',
                      onImageSelected: (file) =>
                          controller.selectLicense(file, 'front'),
                    );
            }),

            SizedBox(height: 20.h),

            // BACK SIDE
            Obx(() {
              return controller.selectedDrivingLicenseBack.value != null
                  ? _buildImagePreview(
                      controller.selectedDrivingLicenseBack.value!,
                      () => controller.removeImage('back'),
                      'Upload Your Driving License picture (Back)',
                    )
                  : CustomImageUploader(
                      label: 'Upload Your Driving License picture (Back)',
                      uploadedTitle: 'Upload files',
                      fileSize: '25',
                      buttonTitle: 'Browse Files',
                      onImageSelected: (file) =>
                          controller.selectLicense(file, 'back'),
                    );
            }),
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

  // Helper method to avoid code duplication
  Widget _buildImagePreview(XFile file, VoidCallback onDelete, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textAlign: TextAlign.start,
          label.toString(),
          style: TextStyle(
            color: AppColors.labelTextColor,
            fontSize: 12.h,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(15),
          dashPattern: [8, 10],
          color: AppColors.dottedBorderColor,
          strokeWidth: 1,
          child: Container(
            height: 110.h,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Container(
                  height: 110.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, color: AppColors.errorColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
