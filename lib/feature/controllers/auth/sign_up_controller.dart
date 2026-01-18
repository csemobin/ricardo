import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class SignUpController extends GetxController {
  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController = TextEditingController();

  RxBool isSelected = false.obs;
  RxBool isRegistrationStatus = false.obs;
  RxString selectedRole = 'driver'.obs;
  RxBool canSubmit = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(isSelected, (_) => updateFormValidity());
  }

  void isSelectedCheckbox(bool value) {
    isSelected.value = value;
  }

  void selectedRoleHandler(String role) {
    selectedRole.value = role;
  }

  void updateFormValidity() {
    canSubmit.value = nameTEController.text.trim().isNotEmpty &&
        emailTEController.text.trim().isNotEmpty &&
        passwordTEController.text.isNotEmpty &&
        confirmPasswordTEController.text.isNotEmpty &&
        isSelected.value;
  }

  void inputFiledHandlerClear() {
    nameTEController.clear();
    emailTEController.clear();
    passwordTEController.clear();
    confirmPasswordTEController.clear();
    isSelected.value = false;
    updateFormValidity();
  }

  Future<void> userRegistration() async {
    isRegistrationStatus.value = true;

    final data = {
      "name": nameTEController.text.trim(),
      "email": emailTEController.text.trim(),
      "password": passwordTEController.text,
      "role": selectedRole.value
    };

    try {
      final response = await ApiClient.postData(ApiUrls.registration, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        inputFiledHandlerClear();
        Get.toNamed(AppRoutes.otpVarifyScreen,arguments: {'email': response.body['data']['user']['email']});
      } else {
        Get.snackbar('Error Massage', response.body['message']);
      }
    } catch (e) {
      Get.snackbar('Error Massage', e.toString());
      // showToast('Error: ${e.toString()}');
    } finally {
      isRegistrationStatus.value = false;
    }

  }

  @override
  void onClose() {
    nameTEController.dispose();
    emailTEController.dispose();
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    super.onClose();
  }
}