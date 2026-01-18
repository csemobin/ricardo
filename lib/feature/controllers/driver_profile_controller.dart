import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DriverProfileController extends GetxController {
  RxInt wordCount = 0.obs;
  final int maxWords = 200;
  XFile? selectedImage;
  final myList = [
    'maruf',
    'muhammad',
    'ali',
    'salman',
  ];

  String selectedGender = 'maruf';

  void setGender(String value) {
    selectedGender = value;
    update();
  }

  final TextEditingController dateTime = TextEditingController(
      text : 'DD-MM-YYYY',
  );

  final TextEditingController textController = TextEditingController(text: ' ');

  @override
  void onInit() {
    super.onInit();
    textController.addListener(updateWordCount);
  }

  void updateWordCount() {
    String text = textController.text.trim();
    if (text.isEmpty) {
      wordCount.value = 0;
    } else {
      wordCount.value = text.split(RegExp(r'\s+')).length;
    }
  }
  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
