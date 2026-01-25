import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/models/user_model.dart';

class ProfileUpdateController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final nameTEController = TextEditingController();
  late final phoneTEController = TextEditingController();
  late final dobTEController = TextEditingController();
  late final aboutTEController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Listen to changes in UserController
    final userController = Get.find<UserController>();
    ever(userController.userModel, (UserModel? user) {
      if (user != null) {
        _updateControllers(user);
      }
    });

    // Load initial data
    _updateControllers(userController.userModel.value);
  }

  void _updateControllers(UserModel? user) {
    if (user != null) {
      nameTEController.text = user.userProfile?.name ?? '';
      phoneTEController.text = user.userProfile?.phone ?? '';
      // dobTEController.text = user.userProfile.da ?? '';
      // aboutTEController.text = user.userProfile?.about ?? '';
    }
  }

  @override
  void onClose() {
    nameTEController.dispose();
    phoneTEController.dispose();
    dobTEController.dispose();
    aboutTEController.dispose();
    super.onClose();
  }
}