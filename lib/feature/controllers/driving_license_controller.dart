import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DrivingLicenseController extends GetxController {
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

  void removeImage(String side) {
    (side == 'front'
        ? selectedDrivingLicenseFront
        : selectedDrivingLicenseBack
    ).value = null;
  }
}