import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_intl_phone_field/phone_number.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';

class DriverProfileController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final TextEditingController aboutTEController = TextEditingController();

  RxInt wordCount = 0.obs;
  RxString selectedGender = 'Male'.obs;
  Rx<PhoneNumber?> phoneNumber = Rx<PhoneNumber?>(null);
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxBool canSubmit = false.obs;
  RxBool isCreateUserProfileStatus = false.obs;

  final List<String> myList = ['Male', 'Female', 'Others'];
  final int maxWords = 200;

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkFormValidity();
    });
  }

  void _initializeListeners() {
    aboutTEController.addListener(() {
      _updateWordCount();
      checkFormValidity();
    });
    textController.addListener(checkFormValidity);
    ever(selectedImage, (_) => checkFormValidity());
    ever(selectedGender, (_) => checkFormValidity());
    ever(phoneNumber, (_) => checkFormValidity());
    ever(wordCount, (_) => checkFormValidity());
    _updateWordCount();
  }

  void updatePhoneNumber(PhoneNumber? number) {
    phoneNumber.value = number;
  }

  void setGender(String value) {
    selectedGender.value = value;
    update();
  }

  void _updateWordCount() {
    String text = aboutTEController.text.trim();
    if (text.isEmpty) {
      wordCount.value = 0;
    } else {
      wordCount.value = text
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;
    }
  }

  void checkFormValidity() {
    bool hasValidPhone = false;
    if (phoneNumber.value != null) {
      hasValidPhone = phoneNumber.value!.isValidNumber();
    }

    bool hasValidDob = false;
    String dobText = textController.text.trim();
    if (dobText.isNotEmpty && dobText != 'DD-MM-YYYY') {
      try {
        DateFormat('dd-MM-yyyy').parseStrict(dobText);
        hasValidDob = true;
      } catch (e) {
        hasValidDob = false;
      }
    }

    bool hasAboutMe = aboutTEController.text.trim().isNotEmpty &&
        wordCount.value <= maxWords &&
        wordCount.value > 0;

    bool hasImage = selectedImage.value != null;
    bool hasGender = selectedGender.value.isNotEmpty;

    canSubmit.value =
        hasValidPhone && hasValidDob && hasAboutMe && hasImage && hasGender;
  }

  Future<void> createUserProfile() async {
    if (isCreateUserProfileStatus.value) return;

    if (!canSubmit.value || !(formKey.currentState?.validate() ?? false)) {
      showSnackbar('Error', 'Please fill all required fields correctly');
      return;
    }

    isCreateUserProfileStatus.value = true;

    try {
      String backendDob;
      try {
        DateTime parsedDate =
            DateFormat('dd-MM-yyyy').parse(textController.text.trim());
        backendDob = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        showSnackbar('Error', 'Invalid date format');
        return;
      }

      final Map<String, dynamic> data = {
        "phone": phoneNumber.value!.completeNumber,
        "dob": backendDob,
        "gender": selectedGender.value.toLowerCase(),
        "aboutMe": aboutTEController.text.trim(),
      };

      final String jsonData = jsonEncode(data);

      List<MultipartBody>? multipartBody;
      if (selectedImage.value != null) {
        multipartBody = [
          MultipartBody('file', File(selectedImage.value!.path)),
        ];
      }

      final response = await ApiClient.patchMultipartData(
        ApiUrls.createUserProfile,
        {"data": jsonData},
        multipartBody: multipartBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _handleSuccessResponse();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _handleException(e);
    } finally {
      isCreateUserProfileStatus.value = false;
    }
  }

  Future<void> _handleSuccessResponse() async {
    showSnackbar(
      'Success',
      'Profile created successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    final userController = Get.find<UserController>();
    await userController.fetchUser();

    final role = userController.userModel.value?.userProfile?.role;

    // Navigate only after a successful create — never clear fields first
    // (clearing while still on this route causes rebuild/overflow during transition).
    if (role == 'driver') {
      Get.offAllNamed(AppRoutes.uploadRequirementScreen);
    } else {
      Get.offAllNamed(AppRoutes.customBottomNavBar);
    }
  }

  void _handleErrorResponse(dynamic response) {
    String errorMessage = 'Failed to create profile';
    final body = response.body;

    if (body is Map) {
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['error'] != null) {
        errorMessage = body['error'].toString();
      } else if (body['data'] is Map && body['data']['message'] != null) {
        errorMessage = body['data']['message'].toString();
      }
    } else if (response.statusText != null &&
        response.statusText.toString().isNotEmpty) {
      errorMessage = response.statusText.toString();
    }

    showSnackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleException(dynamic e) {
    debugPrint('Create Profile Exception: $e');
    showSnackbar(
      'Error',
      'An unexpected error occurred',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void clearFieldHandler() {
    textController.clear();
    phoneController.clear();
    aboutTEController.clear();
    selectedGender.value = 'Male';
    selectedImage.value = null;
    phoneNumber.value = null;
    wordCount.value = 0;
    canSubmit.value = false;
  }

  @override
  void onClose() {
    textController.dispose();
    phoneController.dispose();
    aboutTEController.dispose();
    super.onClose();
  }
}
