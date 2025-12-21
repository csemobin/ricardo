import 'package:get/get.dart';

class CustomBottomNavBarController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void onChange(int index) {
    selectedIndex.value = index;
  }
}
