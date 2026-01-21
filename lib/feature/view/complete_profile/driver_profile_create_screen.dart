import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/driver_profile_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/image_handler.dart';

class DriverProfileCreateScreen extends GetView<DriverProfileController> {
  const DriverProfileCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverProfileController());
    return CustomScaffold(
      body: LayoutBuilder(
        builder: (context, containers) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: containers.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: CustomSecondaryText(
                            text: 'Fill in your information'),
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      Center(
                        child: Stack(
                          children: [
                            GetBuilder<DriverProfileController>(builder: (cnt) {
                              return cnt.selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.file(
                                        File(cnt.selectedImage!.path),
                                        height: 122.h,
                                        width: 122.w,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      Assets.images.vector.path,
                                      height: 122.h,
                                      width: 122.w,
                                    );
                            }),
                            Positioned(
                              bottom: 10.h,
                              right: 15.h,
                              child: Container(
                                width: 35.w,
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: Color(0XffEDEDED),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: GetBuilder<DriverProfileController>(
                                    builder: (cnt) {
                                  return GestureDetector(
                                    child: Image.asset(
                                        Assets.images.editPencil.path),
                                    onTap: () {
                                      ImageHandler.bottomImageSelector(context,
                                          onImageSelected: (file) {
                                        cnt.selectedImage = file;
                                        cnt.update();
                                      });
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontFamily: FontFamily.poppins,
                              color: AppColors.labelTextColor,
                              fontSize: 12.h,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          IntlPhoneField(
                            validator: (val) {
                              if (val == null || val.completeNumber.isEmpty) {
                                return "Please Enter your Number";
                              }
                              return null;
                            },
                            controller: controller.phoneController,
                            initialCountryCode: 'BD',
                            // Optional: Set default country
                            // ✅ CORRECT WAY - Store in separate RxString variable
                            onChanged: (phone) {
                              phone.isValidNumber();
                              controller.completePhoneNumber.value =
                                  phone.completeNumber;

                              controller
                                  .checkFormValidity(); // ✅ Trigger validation

                              print(
                                  'Complete Phone: ${phone.completeNumber}'); // +8801936694536
                              print(
                                  'Country Code: ${phone.countryCode}'); // +880
                              print(
                                  'Number Only: ${phone.number}'); // 1936694536
                            },

                            dropdownTextStyle: TextStyle(
                              color: AppColors.greyColor500,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownIcon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.greyColor500,
                              size: 14.h,
                            ),
                            style: TextStyle(
                              color: AppColors.greyColor500,
                              fontSize: 14.sp,
                            ),
                            keyboardType: TextInputType.number,
                            cursorColor: AppColors.greyColor,
                            flagsButtonMargin: EdgeInsets.only(left: 10),
                            dropdownIconPosition: IconPosition.trailing,
                            decoration: InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: EdgeInsets.all(6),
                              filled: true,
                              counterStyle:
                                  TextStyle(color: AppColors.greyColor),
                              fillColor: AppColors.whiteColor,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.8.w,
                                  color: AppColors.grayShade100,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.8.w,
                                  color: AppColors.grayShade100,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.8.w,
                                  color: AppColors.grayShade100,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.8.w,
                                  color: AppColors.grayShade100,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            languageCode: "en",
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date of Birth',
                                style: TextStyle(
                                  fontFamily: FontFamily.poppins,
                                  color: AppColors.labelTextColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              TextFormField(
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Please Enter your DOB";
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: AppColors.greyColor500,
                                  fontSize: 12.sp,
                                ),
                                cursorColor: AppColors.appGreyColor,
                                controller: controller.textController,
                                decoration: InputDecoration(
                                  fillColor: AppColors.whiteColor,
                                  filled: true,
                                  hintText: 'YYYY-MM-DD',
                                  hintStyle: TextStyle(color: Colors.red),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime.now(),
                                        initialDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        String formattedData =
                                            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                        controller.textController.text =
                                            formattedData;
                                      }
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0.8.w,
                                      color: AppColors.grayShade100,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0.8.w,
                                      color: AppColors.grayShade100,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0.8.w,
                                      color: AppColors.grayShade100,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0.8.w,
                                      color: AppColors.grayShade100,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                keyboardType: TextInputType.datetime,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          GetBuilder<DriverProfileController>(builder: (cnt) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontFamily: FontFamily.poppins,
                                    color: AppColors.labelTextColor,
                                    fontSize: 12.h,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 4.h,
                                ),
                                GestureDetector(
                                  onTapDown: (TapDownDetails details) async {
                                    final RenderBox overlay =
                                        Overlay.of(context)
                                            .context
                                            .findRenderObject() as RenderBox;
                                    final String? selected =
                                        await showMenu<String>(
                                      context: context,
                                      color: Colors.white,
                                      constraints: BoxConstraints(
                                        maxHeight: 200.h,
                                        minWidth: 120.w,
                                        maxWidth: 180.w,
                                      ),
                                      position: RelativeRect.fromRect(
                                        Rect.fromPoints(
                                          details.globalPosition,
                                          details.globalPosition,
                                        ),
                                        Offset.zero & overlay.size,
                                      ),
                                      items: cnt.myList
                                          .map(
                                            (e) => PopupMenuItem<String>(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                    );

                                    if (selected != null) {
                                      cnt.setGender(selected);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.r),
                                        ),
                                        border: Border.all(
                                            color: AppColors.greyColor300)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 12.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          cnt.selectedGender,
                                          style: TextStyle(
                                            color: AppColors.greyColor500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.greyColor500,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          SizedBox(
                            height: 4.h,
                          ),
                          Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 0.h),
                                child: CustomTextField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter about yourself';
                                    }
                                    int words = value
                                        .trim()
                                        .split(RegExp(r'\s+'))
                                        .length;
                                    if (words > 200) {
                                      return 'Maximum 200 words allowed';
                                    }
                                    return null;
                                  },
                                  controller: controller.aboutTEController,
                                  labelText: 'About Me',
                                  minLines: 5,
                                ),
                              ),
                              Positioned(
                                bottom: 10.r,
                                right: 10.r,

                                // padding: EdgeInsets.only(top: 100, right: 8),
                                child: Obx(
                                  () => Text(
                                    '${controller.wordCount.value}/200 words',
                                    style: TextStyle(
                                      color: controller.wordCount.value > 200
                                          ? Colors.red
                                          : Colors.grey,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 100.h,
                          ),
                          Obx(() {
                            return Opacity(
                              opacity:
                                  controller.canSubmit.value == true ? 1 : 0.5,
                              child: CustomPrimaryButton(
                                title: 'Continue',
                                onHandler: _createUserProfile,
                                // onHandler: () {
                                //   Get.toNamed(AppRoutes.uploadRequirementScreen);
                                // },
                              ),
                            );
                          }),
                          SizedBox(
                            height: 10.h,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _createUserProfile() {
    if (!controller.formKey.currentState!.validate()) return;
    controller.checkFormValidity();
    print('yess');
    // controller.createUserProfile();
  }
}
