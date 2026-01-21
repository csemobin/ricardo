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
import 'package:ricardo/widgets/custom_image_uploader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class UploadDrivingLicenseScreen extends StatelessWidget {
  UploadDrivingLicenseScreen({super.key});

  final controller = Get.find<DrivingLicenseController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    'Driving License',
                    style: AppCustomDesign.headingTextStyle,
                  ),
                ),
                SizedBox(height: 40.h),

                // License Number Field
                CustomTextField(
                  controller: controller.licenseNoTEController,
                  labelText: 'Driving License No',
                  hintText: 'Enter your driving license number',
                  keyboardType: TextInputType.number,
                  inputFormatter: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter driving license number";
                    }
                    if (val.length != 16) {
                      return "Driving License No must be exactly 16 digits";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30.h),

                // FRONT SIDE
                _buildImageSection(
                  'Upload Your Driving License (Front Side)',
                  controller.selectedDrivingLicenseFront,
                  'front',
                ),

                SizedBox(height: 30.h),

                // BACK SIDE
                _buildImageSection(
                  'Upload Your Driving License (Back Side)',
                  controller.selectedDrivingLicenseBack,
                  'back',
                ),

                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  // Build image section
  Widget _buildImageSection(String label, Rx<XFile?> imageFile, String side) {
    return Obx(() {
      if (imageFile.value != null) {
        return _buildImagePreview(
          imageFile.value!,
              () => controller.removeImage(side),
          label,
        );
      } else {
        return CustomImageUploader(
          label: label,
          uploadedTitle: 'Upload files',
          fileSize: '25',
          buttonTitle: 'Browse Files',
          onImageSelected: (file) => controller.selectLicense(file, side),
        );
      }
    });
  }

  // Build image preview
  Widget _buildImagePreview(XFile file, VoidCallback onDelete, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.labelTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        DottedBorder(
          padding: EdgeInsets.all(8.r),
          borderType: BorderType.RRect,
          radius: Radius.circular(15.r),
          dashPattern: const [8, 10],
          color: AppColors.dottedBorderColor,
          strokeWidth: 1,
          child: Container(
            height: 140.h,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: double.maxFinite,
                    height: double.maxFinite,
                  ),
                ),

                // Delete button
                Positioned(
                  right: 10.w,
                  top: 10.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete,
                        color: AppColors.whiteColor,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build submit button
  Widget _buildSubmitButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
        child: Obx(() {
          final bool isLoading = controller.isUploadDrivingLicenseController.value;
          final bool isValid = controller.isFormValid.value;

          return CustomPrimaryButton(
            title: isLoading ? 'Uploading...' : 'Submit',
            onHandler: isValid && !isLoading ? _onSubmit : null,
          );
        }),
      ),
    );
  }

  // Submit handler
  void _onSubmit() {
    if (!controller.formKey.currentState!.validate()) return;
    controller.addedDrivingLicense();
  }
}