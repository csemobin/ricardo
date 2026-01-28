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

class DriverProfileController extends GetxController {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController textController = TextEditingController(); // For DOB
  final TextEditingController aboutTEController = TextEditingController();

  // Reactive variables
  RxInt wordCount = 0.obs;
  RxString selectedGender = 'Male'.obs;
  Rx<PhoneNumber?> phoneNumber = Rx<PhoneNumber?>(null);
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxBool canSubmit = false.obs;
  RxBool isCreateUserProfileStatus = false.obs;

  // Constants
  final List<String> myList = ['Male', 'Female', 'Others'];
  final int maxWords = 200;

  @override
  void onInit() {
    super.onInit();

    // Initialize listeners
    _initializeListeners();

    // Initial validation check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkFormValidity();
    });
  }

  void _initializeListeners() {
    // Listen to about text changes
    aboutTEController.addListener(() {
      _updateWordCount();
      checkFormValidity();
    });

    // Listen to DOB changes
    textController.addListener(checkFormValidity);

    // Listen to reactive variables
    ever(selectedImage, (_) => checkFormValidity());
    ever(selectedGender, (_) => checkFormValidity());
    ever(phoneNumber, (_) => checkFormValidity());
    ever(wordCount, (_) => checkFormValidity());

    // Initial word count
    _updateWordCount();
  }

  // Update phone number from widget
  void updatePhoneNumber(PhoneNumber? number) {
    phoneNumber.value = number;
  }

  // Update gender
  void setGender(String value) {
    selectedGender.value = value;
  }

  // Word count calculation
  void _updateWordCount() {
    String text = aboutTEController.text.trim();
    if (text.isEmpty) {
      wordCount.value = 0;
    } else {
      wordCount.value = text.split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;
    }
  }

  // Form validation logic
  void checkFormValidity() {
    // Check 1: Phone number validation
    bool hasValidPhone = false;
    if (phoneNumber.value != null) {
      hasValidPhone = phoneNumber.value!.isValidNumber();
    }

    // Check 2: Date of birth validation
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

    // Check 3: About me validation
    bool hasAboutMe = aboutTEController.text.trim().isNotEmpty &&
        wordCount.value <= maxWords &&
        wordCount.value > 0;

    // Check 4: Image validation
    bool hasImage = selectedImage.value != null;

    // Check 5: Gender validation
    bool hasGender = selectedGender.value.isNotEmpty;

    // Update canSubmit
    canSubmit.value = hasValidPhone &&
        hasValidDob &&
        hasAboutMe &&
        hasImage &&
        hasGender;
  }

  // API call to create user profile
  Future<void> createUserProfile() async {
    try {
      // Final validation check
      if (!canSubmit.value || !formKey.currentState!.validate()) {
        Get.snackbar('Error', 'Please fill all required fields correctly');
        return;
      }

      // Start loading
      isCreateUserProfileStatus.value = true;

      // Prepare date for backend (DD-MM-YYYY to YYYY-MM-DD)
      String backendDob;
      try {
        DateTime parsedDate = DateFormat('dd-MM-yyyy')
            .parse(textController.text.trim());
        backendDob = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        Get.snackbar('Error', 'Invalid date format');
        isCreateUserProfileStatus.value = false;
        return;
      }

      // Prepare request data
      final Map<String, dynamic> data = {
        "phone": phoneNumber.value!.completeNumber,
        "dob": backendDob,
        "gender": selectedGender.value.toLowerCase(),
        "aboutMe": aboutTEController.text.trim(),
      };

      final String jsonData = jsonEncode(data);

      // Prepare multipart data for image
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

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        _handleSuccessResponse();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _handleException(e);
    } finally {
      isCreateUserProfileStatus.value = false;
    }
  }

  void _handleSuccessResponse() async {
    Get.snackbar('Success', 'Profile created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);

    // Fetch updated user data
    final userController = Get.find<UserController>();
    await userController.fetchUser();

    // Navigate based on user role
    if (userController.userModel?.value?.userProfile?.role == 'driver') {
      Get.offAllNamed(AppRoutes.uploadRequirementScreen);
    } else {
      Get.offAllNamed(AppRoutes.customBottomNavBar);
    }
  }

  void _handleErrorResponse(dynamic response) {
    String errorMessage = 'Failed to create profile';
    if (response.body != null && response.body['message'] != null) {
      errorMessage = response.body['message'];
    } else if (response.body != null && response.body['error'] != null) {
      errorMessage = response.body['error'];
    }

    Get.snackbar('Error', errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }

  void _handleException(dynamic e) {
    debugPrint('Create Profile Exception: $e');
    Get.snackbar('Error', 'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }

  // Clear all form fields
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
    // Dispose controllers
    textController.dispose();
    phoneController.dispose();
    aboutTEController.dispose();
    super.onClose();
  }
}