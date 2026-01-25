import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_custom_design.dart';
import 'package:ricardo/feature/controllers/auth/car_registration_controller.dart';
import 'package:ricardo/widgets/custom_image_uploader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class CarRegistrationScreen extends StatelessWidget {
  CarRegistrationScreen({super.key});

  final CarRegistrationController controller = Get.find<CarRegistrationController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'Car Registration',
          style: AppCustomDesign.headingTextStyle.copyWith(
            fontSize: 20.sp,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: 0.w, vertical: 20.h
      ),
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormFields(),
            SizedBox(height: 20.h),
            _buildImageSections(),
            SizedBox(height: 20.h),
            _buildSubmitButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Name Field
        _buildTextFieldWithError(
          controller: controller.carNameController,
          label: 'Car Name',
          hint: 'Enter car name',
          error: controller.carNameError,
        ),
        SizedBox(height: 16.h),

        // Car Plate Number Field
        _buildTextFieldWithError(
          controller: controller.carPlateNoController,
          label: 'Car Plate Number',
          hint: 'Enter plate number',
          error: controller.carPlateError,
        ),
        SizedBox(height: 16.h),

        // Registration Date Field
        _buildTextFieldWithError(
          controller: controller.carRegistrationDateController,
          label: 'Registration Date',
          hint: 'DD-MM-YYYY',
          error: controller.dateError,
          onTap: () => _showDatePicker(),
        ),
        SizedBox(height: 16.h),

        // Number of Seats Field
        _buildTextFieldWithError(
          controller: controller.noOfSeatController,
          label: 'Number of Seats',
          hint: 'Enter seat count',
          error: controller.seatError,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextFieldWithError({
    required TextEditingController controller,
    required String label,
    required String hint,
    required RxString error,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          labelText: label,
          hintText: hint,
          onTap: onTap,
          keyboardType: keyboardType,
        ),
        Obx(() => error.value.isNotEmpty
            ? Padding(
          padding: EdgeInsets.only(top: 4.h, left: 8.w),
          child: Text(
            error.value,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp,
            ),
          ),
        )
            : SizedBox(height: 4.h)),
      ],
    );
  }

  Widget _buildImageSections() {
    return Column(
      children: [
        // Car Picture
        _buildImageSection(
          title: 'Car Picture',
          description: 'Upload a clear picture of your car',
          imageType: 'carPicture',
          imageObservable: controller.carPicture,
          errorObservable: controller.carPictureError,
        ),
        SizedBox(height: 20.h),

        // Registration Card
        _buildImageSection(
          title: 'Registration Card',
          description: 'Upload your vehicle registration card',
          imageType: 'registrationCard',
          imageObservable: controller.registrationCardPicture,
          errorObservable: controller.registrationCardError,
        ),
        SizedBox(height: 20.h),

        // Number Plate
        _buildImageSection(
          title: 'Number Plate',
          description: 'Upload a clear picture of your number plate',
          imageType: 'numberPlate',
          imageObservable: controller.numberPlatePicture,
          errorObservable: controller.numberPlateError,
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required String title,
    required String description,
    required String imageType,
    required Rx<XFile?> imageObservable,
    required RxString errorObservable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.labelTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 12.h),

        Obx(() {
          if (imageObservable.value != null) {
            return _buildImagePreview(
              file: imageObservable.value!,
              onDelete: () => controller.removeImage(imageType),
            );
          } else {
            return Column(
              children: [
                CustomImageUploader(
                  label: title,
                  buttonTitle: 'Browse Files',
                  fileSize: '25',
                  onImageSelected: (file) => controller.selectImage(file, imageType),
                ),
                _buildErrorText(errorObservable),
              ],
            );
          }
        }),
      ],
    );
  }

  Widget _buildImagePreview({
    required XFile file,
    required VoidCallback onDelete,
  }) {
    return DottedBorder(
      padding: EdgeInsets.all(12.r),
      borderType: BorderType.RRect,
      radius: Radius.circular(16.r),
      dashPattern: const [6, 8],
      color: AppColors.dottedBorderColor,
      strokeWidth: 1.5,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                File(file.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 40.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Unable to load image',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dark overlay for better text visibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // File name
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 50.w,
              child: Text(
                file.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            // Delete button
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorText(RxString error) {
    return Obx(() => error.value.isNotEmpty
        ? Padding(
      padding: EdgeInsets.only(top: 6.h, left: 8.w),
      child: Text(
        error.value,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.sp,
          fontStyle: FontStyle.italic,
        ),
      ),
    )
        : const SizedBox.shrink());
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      // Show error summary if form has errors
      if (controller.hasAnyError && !controller.isFormValidated) {
        return Column(
          children: [
            _buildErrorSummary(),
            SizedBox(height: 20.h),
            _buildSubmitButtonWidget(),
          ],
        );
      }

      return _buildSubmitButtonWidget();
    });
  }

  Widget _buildSubmitButtonWidget() {
    return CustomPrimaryButton(
      title: controller.isSubmitting ? 'Submitting...' : 'Submit Registration',
      onHandler: controller.isFormValidated && !controller.isSubmitting
          ? _submitForm
          : null,
      // isLoading: controller.isSubmitting,
      // borderRadius: 12.r,
    );
  }

  Widget _buildErrorSummary() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Fields Missing',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Please complete all fields and upload all required images',
                  style: TextStyle(
                    color: Colors.red.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================== Helper Methods ===================
  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final formattedDate = '${pickedDate.year}-'
          '${pickedDate.month.toString().padLeft(2, '0')}-'
          '${pickedDate.day.toString().padLeft(2, '0')}';
      controller.carRegistrationDateController.text = formattedDate;
    }
  }

  void _submitForm() {
    if (!controller.formKey.currentState!.validate()) {
      return;
    }
    controller.submitCarRegistration();
  }
}