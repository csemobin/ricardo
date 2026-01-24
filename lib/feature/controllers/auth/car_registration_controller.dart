import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class CarRegistrationController extends GetxController {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // =================== Text Editing Controllers ===================
  final TextEditingController carNameController = TextEditingController();
  final TextEditingController carPlateNoController = TextEditingController();
  final TextEditingController carRegistrationDateController = TextEditingController();
  final TextEditingController noOfSeatController = TextEditingController();

  // =================== Image Observables ===================
  final Rx<XFile?> carPicture = Rx<XFile?>(null);
  final Rx<XFile?> registrationCardPicture = Rx<XFile?>(null);
  final Rx<XFile?> numberPlatePicture = Rx<XFile?>(null);

  // =================== Validation Observables ===================
  final RxBool isFormValid = false.obs;
  final RxBool isLoading = false.obs;

  final RxString carNameError = RxString('');
  final RxString carPlateError = RxString('');
  final RxString dateError = RxString('');
  final RxString seatError = RxString('');
  final RxString carPictureError = RxString('');
  final RxString registrationCardError = RxString('');
  final RxString numberPlateError = RxString('');

  // =================== Constants ===================
  static const int maxFileSizeMB = 25;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const String vehicleType = 'car'; // Change to 'bike' if needed

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    // _performInitialValidation();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // =================== Setup Methods ===================
  void _setupListeners() {
    // Text field listeners
    carNameController.addListener(_validateForm);
    carPlateNoController.addListener(_validateForm);
    carRegistrationDateController.addListener(_validateForm);
    noOfSeatController.addListener(_validateForm);

    // Image listeners
    ever(carPicture, (_) => _validateForm());
    ever(registrationCardPicture, (_) => _validateForm());
    ever(numberPlatePicture, (_) => _validateForm());
  }

  void _performInitialValidation() {
    _validateForm();
  }

  void _disposeControllers() {
    carNameController.dispose();
    carPlateNoController.dispose();
    carRegistrationDateController.dispose();
    noOfSeatController.dispose();
  }

  // =================== Validation Methods ===================
  void _validateCarName() {
    final text = carNameController.text.trim();
    carNameError.value = text.isEmpty ? 'Car name is required' : '';
  }

  void _validateCarPlate() {
    final text = carPlateNoController.text.trim();
    carPlateError.value = text.isEmpty ? 'Plate number is required' : '';
  }

  void _validateRegistrationDate() {
    final text = carRegistrationDateController.text.trim();
    dateError.value = text.isEmpty ? 'Registration date is required' : '';
  }

  void _validateSeats() {
    final text = noOfSeatController.text.trim();

    if (text.isEmpty) {
      seatError.value = 'Number of seats is required';
    } else if (int.tryParse(text) == null) {
      seatError.value = 'Enter a valid number';
    } else if (int.parse(text) <= 0) {
      seatError.value = 'Seats must be greater than 0';
    } else {
      seatError.value = '';
    }
  }

  void _validateImages() {
    carPictureError.value = carPicture.value == null ? 'Car picture is required' : '';
    registrationCardError.value = registrationCardPicture.value == null ? 'Registration card is required' : '';
    numberPlateError.value = numberPlatePicture.value == null ? 'Number plate picture is required' : '';
  }

  void _validateForm() {
    // Validate all fields
    _validateCarName();
    _validateCarPlate();
    _validateRegistrationDate();
    _validateSeats();
    _validateImages();

    // Check if form is completely valid
    final isTextValid = carNameError.value.isEmpty &&
        carPlateError.value.isEmpty &&
        dateError.value.isEmpty &&
        seatError.value.isEmpty;

    final isImagesValid = carPicture.value != null &&
        registrationCardPicture.value != null &&
        numberPlatePicture.value != null;

    isFormValid.value = isTextValid && isImagesValid;
  }

  // =================== Image Handling Methods ===================
  Future<void> selectImage(XFile file, String imageType) async {
    try {
      // Validate file size
      final double sizeMB = (await file.length()) / 1048576;
      if (sizeMB > maxFileSizeMB) {
        _showErrorSnackbar('File too large! Maximum size is $maxFileSizeMB MB');
        return;
      }

      // Validate file extension
      final String extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        _showErrorSnackbar('Invalid file format. Allowed: ${allowedExtensions.join(', ').toUpperCase()}');
        return;
      }

      // Assign image based on type
      switch (imageType) {
        case 'carPicture':
          carPicture.value = file;
          break;
        case 'registrationCard':
          registrationCardPicture.value = file;
          break;
        case 'numberPlate':
          numberPlatePicture.value = file;
          break;
        default:
          throw ArgumentError('Invalid image type: $imageType');
      }

      _validateForm();

    } catch (error) {
      debugPrint('Error selecting image: $error');
      _showErrorSnackbar('Failed to select image');
    }
  }

  void removeImage(String imageType) {
    switch (imageType) {
      case 'carPicture':
        carPicture.value = null;
        break;
      case 'registrationCard':
        registrationCardPicture.value = null;
        break;
      case 'numberPlate':
        numberPlatePicture.value = null;
        break;
    }
    _validateForm();
  }

  // =================== Form Submission ===================
  Future<void> submitCarRegistration() async {
    // Validate form before submission
    if (!isFormValid.value) {
      _showErrorSnackbar('Please fill all required fields correctly');
      return;
    }

    try {
      isLoading.value = true;

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "carName": carNameController.text.trim(),
        "carPlateNumber": carPlateNoController.text.trim(),
        "carRegistrationDate": carRegistrationDateController.text.trim(),
        "numberOfSeat": noOfSeatController.text.trim(),
        // "vehicleType": vehicleType,
      };

      // Prepare multipart images
      final List<MultipartBody> multipartImages = [
        MultipartBody('car', File(carPicture.value!.path)),
        MultipartBody('registrationCard', File(registrationCardPicture.value!.path)),
        MultipartBody('numberPlate', File(numberPlatePicture.value!.path)),
      ];

      final String jsonData = jsonEncode(requestBody);

      final response = await ApiClient.postMultipartData(
        ApiUrls.registrationVehicle,
        {"data": jsonData},
        multipartBody: multipartImages,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await UserController().fetchUser();
        Get.back();
      } else {
        final String errorMessage = response.body['data']['message'] ?? 'Registration failed';
        _showErrorSnackbar(errorMessage);
      }
    } catch (error) {
      debugPrint('Registration Error: $error');
      _showErrorSnackbar('Registration failed: ${error.toString()}');
    } finally {
      isLoading.value = false;
      resetForm();
    }
  }

  // =================== Helper Methods ===================
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void resetForm() {
    // Clear text fields
    carNameController.clear();
    carPlateNoController.clear();
    carRegistrationDateController.clear();
    noOfSeatController.clear();

    // Clear images
    carPicture.value = null;
    registrationCardPicture.value = null;
    numberPlatePicture.value = null;

    // Reset validation
    _validateForm();
  }

  // =================== Public Getters ===================
  bool get isFormValidated => isFormValid.value;
  bool get isSubmitting => isLoading.value;
  bool get hasAnyError => carNameError.isNotEmpty ||
      carPlateError.isNotEmpty ||
      dateError.isNotEmpty ||
      seatError.isNotEmpty ||
      carPictureError.isNotEmpty ||
      registrationCardError.isNotEmpty ||
      numberPlateError.isNotEmpty;
}