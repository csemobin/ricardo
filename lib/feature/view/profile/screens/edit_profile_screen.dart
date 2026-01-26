import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/auth/profile_update_controller.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/image_handler.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final controller = Get.put(ProfileUpdateController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.selectedImage.value != null) {
                        return _circleImage(
                            Image.file(File(controller.selectedImage.value!.path)));
                      } else if (controller.profileImageUrl.value.isNotEmpty) {
                        return _circleImage(
                            Image.network('${ApiUrls.imageBaseUrl}${controller.profileImageUrl.value}',fit: BoxFit.cover,));
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
              CustomTextField(
                controller: controller.nameTEController,
                labelText: 'Full Name',
                hintText: 'Enter You Name',
              ),
              SizedBox(height: 20.h),

              /// PHONE
              IntlPhoneField(
                controller: controller.phoneController,
                initialCountryCode: 'BD',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (phone) =>
                phone == null || !phone.isValidNumber()
                    ? 'Invalid phone'
                    : null,
                onChanged: controller.updatePhoneNumber,
                decoration: _inputDecoration('Phone number'),
                dropdownIconPosition: IconPosition.trailing,
                 flagsButtonPadding: EdgeInsets.only(
                   left: 10.w
                 ),
              ),

              SizedBox(height: 12.h),

              /// DOB
              TextFormField(
                controller: controller.textController,
                readOnly: true,
                validator: (v) => v == null || v.isEmpty ? 'Select DOB' : null,
                decoration: _inputDecoration('DD-MM-YYYY').copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        initialDate: DateTime.now(),
                      );
                      if (date != null) {
                        controller.textController.text =
                            DateFormat('dd-MM-yyyy').format(date);
                        controller.checkFormValidity();
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(r'[0-9]')
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              SizedBox(height: 12.h),

              /// GENDER
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedGender.value,
                items: controller.genderList
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: controller.setGender,
                decoration: _inputDecoration('Gender'),
              )),

              SizedBox(height: 12.h),

              /// ABOUT
              TextFormField(
                controller: controller.aboutTEController,
                minLines: 4,
                maxLines: 4,
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
                decoration: _inputDecoration('About you'),
              ),

              SizedBox(height: 6.h),

              Obx(() => Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${controller.wordCount.value}/200 words',
                  style: TextStyle(
                    color: controller.wordCount.value > 200
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              )),

              SizedBox(height: 30.h),

              /// BUTTON
              Obx(() => CustomPrimaryButton(
                title: controller.isLoading.value
                    ? 'Updating...'
                    : 'Update Profile',
                onHandler: controller.canSubmit.value
                    ? controller.updateUserProfile
                    : null,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleImage(Image image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: SizedBox(height: 120, width: 120, child: image),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.whiteColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
