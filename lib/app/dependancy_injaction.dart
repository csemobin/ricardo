import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';

class DependencyInjection implements Bindings{
  @override
  void dependencies(){
    Get.put(CustomBottomNavBarController());
  }
}