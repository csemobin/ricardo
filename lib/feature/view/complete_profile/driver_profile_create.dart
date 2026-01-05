import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/driver_profile_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_secondary_text.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/image_handler.dart';

class DriverProfileCreate extends GetView<DriverProfileController> {
  DriverProfileCreate({super.key});

  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverProfileController());
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
                    GetBuilder<DriverProfileController>(builder: (cnt) {
                      return cnt.selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                File(cnt.selectedImage!.path),
                                height: 122,
                                width: 122,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              Assets.images.vector.path,
                              height: 122,
                              width: 122,
                            );
                    }),
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
                        child:
                            GetBuilder<DriverProfileController>(builder: (cnt) {
                          return GestureDetector(
                            child: Image.asset(Assets.images.editPencil.path),
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
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.h),
                      child: CustomTextField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter about yourself';
                          }
                          int words = value.trim().split(RegExp(r'\s+')).length;
                          if (words > 200) {
                            return 'Maximum 200 words allowed';
                          }
                          return null;
                        },
                        controller: controller.textController,
                        labelText: 'About Me',
                        minLines: 5,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,

                      // padding: EdgeInsets.only(top: 100, right: 8),
                      child: Obx(
                        () => Text(
                          '${controller.wordCount.value}/200 words',
                          style: TextStyle(
                            color: controller.wordCount.value > 200
                                ? Colors.red
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                SizedBox(
                  height: 10.h,
                )
              ],
            ),
          ),
        ),
      );
    }));
  }
}
