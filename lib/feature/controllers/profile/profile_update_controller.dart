import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class ProfileUpdateController extends GetxController {
  final userController = Get.find<UserController>();

  final formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final textController = TextEditingController();
  final aboutTEController = TextEditingController();
  final nameTEController = TextEditingController();

  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxString profileImageUrl = ''.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  RxString selectedGender = 'Male'.obs;
  RxInt wordCount = 0.obs;
  RxBool canSubmit = false.obs;
  RxBool isLoading = false.obs;

  final List<String> genderList = ['Male', 'Female', 'Others'];

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();

    nameTEController.addListener(checkFormValidity);
    phoneController.addListener(checkFormValidity);
    aboutTEController.addListener(() {
      _countWords();
      checkFormValidity();
    });
    textController.addListener(checkFormValidity);
  }

  void loadUserProfile() {
    final profile = userController.userModel?.value?.userProfile;
    if (profile == null) return;

    if (profile.name != null) nameTEController.text = profile.name!;
    if (profile.phone != null && profile.phone!.isNotEmpty) phoneController.text = profile.phone!;

    if (profile.dob != null && profile.dob!.isNotEmpty) {
      try {
        DateTime d = profile.dob!.contains('T')
            ? DateTime.parse(profile.dob!).toLocal()
            : DateFormat('yyyy-MM-dd').parse(profile.dob!);
        selectedDate.value = d;
        textController.text = DateFormat('dd-MM-yyyy').format(d);
      } catch (e) {
        debugPrint('Error parsing DOB: $e');
      }
    }

    if (profile.aboutMe != null) aboutTEController.text = profile.aboutMe!;

    if (profile.gender != null && profile.gender!.isNotEmpty) {
      String gender = profile.gender!.toLowerCase();
      if (gender == 'male') selectedGender.value = 'Male';
      else if (gender == 'female') selectedGender.value = 'Female';
      else selectedGender.value = 'Others';
    }

    if (profile.image?.filename != null && profile.image!.filename!.isNotEmpty) {
      profileImageUrl.value = profile.image!.filename!;
    }

    _countWords();
    checkFormValidity();
  }

  void updateDateOfBirth(DateTime date) {
    selectedDate.value = date;
    textController.text = DateFormat('dd-MM-yyyy').format(date);
    checkFormValidity();
  }

  void setGender(String? value) {
    if (value != null) {
      selectedGender.value = value;
      checkFormValidity();
    }
  }

  void _countWords() {
    final text = aboutTEController.text.trim();
    wordCount.value = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  void checkFormValidity() {
    canSubmit.value =
        nameTEController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty &&
            textController.text.trim().isNotEmpty &&
            selectedDate.value != null &&
            aboutTEController.text.trim().isNotEmpty;
  }

  Future<void> updateUserProfile() async {
    if (!canSubmit.value) return;

    try {
      isLoading.value = true;

      final dob = DateFormat('dd-MM-yyyy').parse(textController.text.trim());

      final data = {
        "name": nameTEController.text.trim(),
        "phone": phoneController.text.trim(),
        "dob": DateFormat('yyyy-MM-dd').format(dob),
        "gender": selectedGender.value.toLowerCase(),
        "about": aboutTEController.text.trim(),
        "role": userController.userModel.value?.userProfile?.role ?? 'user',
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        await userController.fetchUser();
        Get.back();
        Get.snackbar('Success', 'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        String errorMessage = 'Failed to update profile';
        if (response.body?['data'] != null) {
          errorMessage = response.body['data']['message'] ?? errorMessage;
        }
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.clear();
    textController.clear();
    aboutTEController.clear();
    nameTEController.clear();

    phoneController.dispose();
    textController.dispose();
    aboutTEController.dispose();
    nameTEController.dispose();
    super.onClose();
  }
}