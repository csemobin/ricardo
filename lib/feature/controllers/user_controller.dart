import 'package:get/get.dart';
import 'package:ricardo/feature/models/user_model.dart';
import 'package:ricardo/services/api_client.dart';
import 'package:ricardo/services/api_urls.dart';

class UserController extends GetxController {
  UserModel? userModel;
  RxBool isUserDataLoadingStatus = false.obs;

  Future<void> fetchUser() async {
    isUserDataLoadingStatus.value = true;

    final response = await ApiClient.getData(ApiUrls.getMe);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.body['data'];
      userModel = UserModel.fromJson(data);
      update();
    }
    isUserDataLoadingStatus.value = false;
    update();
  }
}