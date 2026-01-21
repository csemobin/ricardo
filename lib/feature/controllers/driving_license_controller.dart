import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class DrivingLicenseController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController licenseNoTEController = TextEditingController();
  final selectedDrivingLicenseFront = Rx<XFile?>(null);
  final selectedDrivingLicenseBack = Rx<XFile?>(null);

  static const maxFileSizeMB = 25;

  Future<void> selectLicense(XFile file, String side) async {
    final sizeMB = (await file.length()) / 1048576;

    if (sizeMB > maxFileSizeMB) {
      Get.snackbar('Error', 'File too large! Max $maxFileSizeMB MB',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Get file extension
    final extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!allowedExtensions.contains(extension)) {
      Get.snackbar(
        'Invalid Format',
        'Only JPG, PNG, and WEBP images are allowed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (side == 'front') {
      selectedDrivingLicenseFront.value = file;
    } else {
      selectedDrivingLicenseBack.value = file;
    }
  }

  // Api related work are here
  RxBool isUploadDrivingLicenseController = false.obs;

  // Api Call are here

  Future<void> addedDrivingLicense() async {
    try {
      isUploadDrivingLicenseController.value = true;

      final reqData = {
        "drivingLicenseNumber": licenseNoTEController.text.toString(),
      };

      final data = jsonEncode(reqData);

      List<MultipartBody>? multipartBody;

      if (selectedDrivingLicenseFront != null &&
          selectedDrivingLicenseBack != null) {
        multipartBody = [
          MultipartBody('licenseFront', File(selectedDrivingLicenseFront.value!.path)),
          MultipartBody('licenseBack', File(selectedDrivingLicenseBack.value!.path)),
        ];
      }

      final response = await ApiClient.postMultipartData(
          ApiUrls.registrationLicense,
          {
            "data": data,
          },
          multipartBody: multipartBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        UserController().fetchUser();
        Get.back();
      } else {
        Get.snackbar('Error', response.body['data']['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isUploadDrivingLicenseController.value = false;
    }
  }

  void removeImage(String side) {
    (side == 'front' ? selectedDrivingLicenseFront : selectedDrivingLicenseBack)
        .value = null;
  }

  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();

    licenseNoTEController.addListener(_validateForm);
    ever(selectedDrivingLicenseFront, (_) => _validateForm());
    ever(selectedDrivingLicenseBack, (_) => _validateForm());
  }

  void _validateForm() {
    isFormValid.value = licenseNoTEController.text.length == 16 &&
        selectedDrivingLicenseFront.value != null &&
        selectedDrivingLicenseBack.value != null;
  }
}
