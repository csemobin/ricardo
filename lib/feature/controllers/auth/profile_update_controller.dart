import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_intl_phone_field/phone_number.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class ProfileUpdateController extends GetxController {
  final userController = Get.put(UserController());

  final formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final textController = TextEditingController();
  final aboutTEController = TextEditingController();
  final nameTEController = TextEditingController();

  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxString profileImageUrl = ''.obs;
  Rx<PhoneNumber?> phoneNumber = Rx<PhoneNumber?>(null);

  RxString selectedGender = 'Male'.obs;
  RxInt wordCount = 0.obs;
  RxBool canSubmit = false.obs;
  RxBool isLoading = false.obs;

  final List<String> genderList = ['Male', 'Female', 'Others'];

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();

    aboutTEController.addListener(() {
      _countWords();
      checkFormValidity();
    });

    textController.addListener(checkFormValidity);
  }

  /// LOAD EXISTING USER DATA
  void loadUserProfile() {
    final profile = userController.userModel?.value?.userProfile;
    if (profile == null) return;

    if( profile.aboutMe != null ){
      aboutTEController.text = profile.aboutMe!;
    }

    if( profile.name != null ){
      nameTEController.text = profile.name!;
    }
    // Phone
    if (profile.phone != null) {
      phoneController.text = profile.phone!;
      phoneNumber.value = PhoneNumber(
        countryISOCode: 'BD',
        countryCode: '+880',
        number: profile.phone!.replaceFirst('+880', ''),
      );
    }

    // DOB
    if (profile.dob != null) {
      DateTime d = DateFormat('yyyy-MM-dd').parse(profile.dob!);
      textController.text = DateFormat('dd-MM-yyyy').format(d);
    }

    // About
    aboutTEController.text = profile.aboutMe ?? '';

    // Gender
    if (profile.gender != null) {
      selectedGender.value =
          profile.gender![0].toUpperCase() + profile.gender!.substring(1);
    }

    // Profile Image URL
    if (profile.image != null && profile.image!.filename!.isNotEmpty) {
      profileImageUrl.value = profile.image!.filename!;
    }

    _countWords();
    checkFormValidity();
  }

  void updatePhoneNumber(PhoneNumber number) {
    phoneNumber.value = number;
    checkFormValidity();
  }

  void setGender(String? value) {
    if (value != null) {
      selectedGender.value = value;
      checkFormValidity();
    }
  }

  void _countWords() {
    wordCount.value = aboutTEController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
  }

  void checkFormValidity() {
    final isPhoneValid =
        phoneNumber.value != null && phoneNumber.value!.isValidNumber();

    final isDobValid = textController.text.isNotEmpty;

    final isAboutValid =
        aboutTEController.text.trim().isNotEmpty && wordCount.value <= 200;

    canSubmit.value = isPhoneValid && isDobValid && isAboutValid;
  }

  /// UPDATE PROFILE API
  Future<void> updateUserProfile() async {
    if (!formKey.currentState!.validate() || !canSubmit.value) return;

    try {
      isLoading.value = true;

      DateTime dob =
      DateFormat('dd-MM-yyyy').parse(textController.text.trim());
      final data = {
        "name": nameTEController.text.trim(),
        "phone": phoneNumber.value!.completeNumber,
        "dob": DateFormat('yyyy-MM-dd').format(dob),
        "gender": selectedGender.value.toLowerCase(),
        "about": aboutTEController.text.trim(),
        "role": userController.userModel.value?.userProfile?.role
      };

      List<MultipartBody>? image;
      if (selectedImage.value != null) {
        image = [MultipartBody('file', File(selectedImage.value!.path))];
      }

      final response = await ApiClient.patchMultipartData(
        ApiUrls.updateProfile,
        {"data": jsonEncode(data)},
        multipartBody: image,
      );

      if (response.statusCode == 200 || response.statusCode == 201 ) {
        await userController.fetchUser();
        Get.back();
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        Get.snackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    textController.dispose();
    aboutTEController.dispose();
    super.onClose();
  }
}
