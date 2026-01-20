import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class DriverProfileController extends GetxController {
  RxInt wordCount = 0.obs;
  final int maxWords = 200;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final myList = ['Male', 'Female', 'Others'];

  String selectedGender = 'Male';

  void setGender(String value) {
    selectedGender = value;
    update();
  }

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateTime = TextEditingController(
    text: 'YYYY-MM-DD',
  );
  final TextEditingController textController = TextEditingController();
  final TextEditingController aboutTEController = TextEditingController();

  RxString completePhoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    aboutTEController.addListener(checkFormValidity);
    dateTime.addListener(checkFormValidity);
  }

  void updateWordCount() {
    String text = aboutTEController.text.trim();
    if (text.isEmpty) {
      wordCount.value = 0;
    } else {
      wordCount.value = text.split(RegExp(r'\s+')).length;
    }
  }

  RxBool canSubmit = false.obs;

  void checkFormValidity() {
    updateWordCount();

    canSubmit.value = completePhoneNumber.value.isNotEmpty &&
        dateTime.text.trim() != 'YYYY-MM-DD' &&
        dateTime.text.trim().isNotEmpty &&
        aboutTEController.text.trim().isNotEmpty &&
        wordCount.value <= 200 &&
        wordCount.value > 0 &&
        selectedImage != null;
  }

  RxBool isCreateUserProfileStatus = false.obs;
  XFile? selectedImage;

  Future<void> createUserProfile() async {
    try {
      isCreateUserProfileStatus.value = true;

      final String backendDob = DateFormat('yyyy-MM-dd').format(
        DateFormat('dd-MM-yyyy').parse(textController.text.trim()),
      );

      final Map<String, dynamic> data = {
        "phone": completePhoneNumber.value,
        "dob": backendDob,
        "gender": selectedGender.toLowerCase(),
        "aboutMe": aboutTEController.text.trim(),
      };

      final String jsonData = jsonEncode(data);

      List<MultipartBody>? multipartBody;

      if (selectedImage != null) {
        multipartBody = [
          MultipartBody('file', File(selectedImage!.path)),
        ];
      }
      // print('=====================>>>>>>>>>>>>>>>>> $jsonData');

      final response = await ApiClient.patchMultipartData(
        ApiUrls.createUserProfile,
        {
          "data": jsonData,
        },
        multipartBody: multipartBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userController = Get.find<UserController>();
        await userController.fetchUser();

        if (userController.userModel?.userProfile?.role == 'driver') {
          Get.toNamed(AppRoutes.uploadRequirementScreen);
        } else {
          Get.offAllNamed(AppRoutes.customBottomNavBar);
        }
      } else {
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isCreateUserProfileStatus.value = false;
    }
  }

  void clearFieldHandler() {
    textController.clear();
    phoneController.clear();
    aboutTEController.clear();
    dateTime.text = 'DD-MM-YYYY';
    selectedGender = 'Male';
    selectedImage = null;
    completePhoneNumber.value = '';
    canSubmit.value = false;
    update();
  }

  @override
  void onClose() {
    textController.dispose();
    phoneController.dispose();
    aboutTEController.dispose();
    dateTime.dispose();
    super.onClose();
  }
}
