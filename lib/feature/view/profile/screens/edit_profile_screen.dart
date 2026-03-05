import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/profile/profile_update_controller.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/image_handler.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  // final controller = Get.put(ProfileUpdateController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileUpdateController>();
    return CustomScaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.selectedImage.value != null) {
                      return _circleImage(Image.file(
                          File(controller.selectedImage.value!.path)));
                    } else if (controller.profileImageUrl.value.isNotEmpty) {
                      return _circleImage(Image.network(
                        '${ApiUrls.imageBaseUrl}${controller.profileImageUrl.value}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _circleImage(
                                Image.asset(Assets.images.vector.path)),
                      ));
                    } else {
                      return _circleImage(
                          Image.asset(Assets.images.vector.path));
                    }
                  }),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        ImageHandler.bottomImageSelector(
                          context,
                          onImageSelected: (file) {
                            controller.selectedImage.value = file;
                            controller.checkFormValidity();
                          },
                        );
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20.h),

            /// FULL NAME
            CustomTextField(
              controller: controller.nameTEController,
              labelText: 'Full Name',
              hintText: 'Enter Your Name',
              onChanged: (value) => controller.checkFormValidity(),
            ),
            SizedBox(height: 20.h),

            /// PHONE NUMBER
            CustomTextField(
              controller: controller.phoneController,
              labelText: 'Phone Number',
              hintText: 'Enter Your Phone Number',
              keyboardType: TextInputType.phone,
              inputFormatter: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => controller.checkFormValidity(),
            ),
            SizedBox(height: 20.h),

            /// DATE OF BIRTH
            CustomTextField(
              controller: controller.textController,
              readOnly: true,
              keyboardType: TextInputType.none,
              hintText: 'DD - MM - YYYY',
              labelText: 'Date of Birth',
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate.value ?? DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  controller.updateDateOfBirth(pickedDate);
                }
              },
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.appGreyColor,
              ),
            ),
            SizedBox(height: 20.h),

            /// GENDER
            _GenderDropdown(controller: controller),
            SizedBox(height: 20.h),

            /// ABOUT
            CustomTextField(
              controller: controller.aboutTEController,
              labelText: 'About You',
              hintText: 'Tell us about yourself...',
              minLines: 4,
              maxLines: 4,
              onChanged: (value) => controller.checkFormValidity(),
            ),
            SizedBox(height: 6.h),

            /// WORD COUNT
            Obx(() => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${controller.wordCount.value}/200 words',
                    style: TextStyle(
                      color: controller.wordCount.value > 200
                          ? Colors.red
                          : Colors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                )),

            SizedBox(height: 30.h),

            /// UPDATE BUTTON
            Obx(() => CustomPrimaryButton(
                  title: controller.isLoading.value
                      ? 'Updating...'
                      : 'Update Profile',
                  onHandler:
                      controller.canSubmit.value && !controller.isLoading.value
                          ? controller.updateUserProfile
                          : null,
                )),
          ],
        ),
      ),
    );
  }

  Widget _circleImage(Image image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60.r),
      child: SizedBox(height: 120.w, width: 120.w, child: image),
    );
  }
}

/// Separate StatefulWidget for Gender to avoid Obx rebuild resetting dropdown
class _GenderDropdown extends StatefulWidget {
  final ProfileUpdateController controller;

  const _GenderDropdown({required this.controller});

  @override
  State<_GenderDropdown> createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<_GenderDropdown> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.controller.selectedGender.value;

    ever(widget.controller.selectedGender, (val) {
      if (mounted && _selected != val) {
        setState(() => _selected = val);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label — same as CustomTextField label style
        CustomText(
          text: 'Gender',
          fontName: FontFamily.poppins,
          bottom: 4.h,
          color: AppColors.labelTextColor,
          fontSize: 12.h,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 4.h),
        DropdownButtonFormField<String>(
          value: _selected,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(
            color: AppColors.appGreyColor,
            fontSize: 12.h,
            fontWeight: FontWeight.w400,
            fontFamily: FontFamily.poppins,
          ),
          dropdownColor: AppColors.whiteColor,
          items: widget.controller.genderList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selected = value);
              widget.controller.setGender(value);
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
            fillColor: AppColors.whiteColor,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: 1,
                color: AppColors.grayShade100,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: 0.8,
                color: AppColors.grayShade100,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                width: 1,
                color: AppColors.grayShade100,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
