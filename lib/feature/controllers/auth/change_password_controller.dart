import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/auth/sign_in_controller.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class ChangePasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final currentPasswordTEController = TextEditingController();
  final newPasswordTEController = TextEditingController();
  final confirmPasswordTEController = TextEditingController();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isFormValid = false.obs;

  // Add listeners to enable/disable submit button
  @override
  void onInit() {
    super.onInit();

    // Add listeners to all text controllers
    currentPasswordTEController.addListener(validateForm);
    newPasswordTEController.addListener(validateForm);
    confirmPasswordTEController.addListener(validateForm);
  }

  // Validate form in real-time
  void validateForm() {
    final currentPass = currentPasswordTEController.text;
    final newPass = newPasswordTEController.text;
    final confirmPass = confirmPasswordTEController.text;

    // Basic validation for enabling submit button
    bool isValid = currentPass.isNotEmpty &&
        newPass.isNotEmpty &&
        confirmPass.isNotEmpty &&
        newPass.length >= 8 &&
        newPass == confirmPass &&
        newPass != currentPass &&
        _hasLettersAndNumbers(newPass);

    isFormValid.value = isValid;

    // Clear error message when user starts typing
    if (errorMessage.isNotEmpty && (currentPass.isNotEmpty || newPass.isNotEmpty || confirmPass.isNotEmpty)) {
      errorMessage.value = '';
    }
  }

  // Check if password contains both letters and numbers
  bool _hasLettersAndNumbers(String password) {
    final hasLetters = RegExp(r'[0-9]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return hasLetters && hasNumbers;
  }

  // Field validators
  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter current password';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter new password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for letters and numbers
    if (!_hasLettersAndNumbers(value)) {
      return 'Password must include letters & numbers';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != newPasswordTEController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Validate passwords before submission
  bool validatePasswords() {
    // Clear previous error
    errorMessage.value = '';

    // Check if new password matches confirm password
    if (newPasswordTEController.text != confirmPasswordTEController.text) {
      errorMessage.value = 'New password and confirm password do not match';
      return false;
    }

    // Check if new password is same as current
    if (newPasswordTEController.text == currentPasswordTEController.text) {
      errorMessage.value = 'New password must be different from current password';
      return false;
    }

    return true;
  }

  Future<void> changePassword() async {
    try {
      // First validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Then validate passwords logic
      if (!validatePasswords()) {
        return;
      }

      isLoading.value = true;

      final data = {
        "oldPassword": currentPasswordTEController.text,
        "newPassword": newPasswordTEController.text
      };

      final response = await ApiClient.postData(ApiUrls.changePassword, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show success message
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Logout and redirect to sign in
        await SignInController().logOut();
        Get.offAllNamed(AppRoutes.signInScreen);

      } else {
        String errorMsg = 'Failed to change password';
        if (response.body != null && response.body['data'] != null) {
          errorMsg = response.body['data']['message'] ?? errorMsg;
        }
        errorMessage.value = errorMsg;
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      errorMessage.value = 'An error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearControllers() {
    currentPasswordTEController.clear();
    newPasswordTEController.clear();
    confirmPasswordTEController.clear();
    isFormValid.value = false;
  }

  @override
  void onClose() {
    currentPasswordTEController.removeListener(validateForm);
    newPasswordTEController.removeListener(validateForm);
    confirmPasswordTEController.removeListener(validateForm);

    currentPasswordTEController.dispose();
    newPasswordTEController.dispose();
    confirmPasswordTEController.dispose();
    super.onClose();
  }
}