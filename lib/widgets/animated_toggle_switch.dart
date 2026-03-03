import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  const AnimatedToggleSwitch({super.key});

  @override
  State<AnimatedToggleSwitch> createState() =>
      _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState
    extends State<AnimatedToggleSwitch> {

  final mapController = Get.find<MapOPTController>();
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      final bool isOnline =
          userController.userModel.value?.driverProfile?.isOnline == true;

      final bool isLoading =
          mapController.isDriverSwitchAvailabilityStatus.value;

      return GestureDetector(
        onTap: () {
          if (isLoading) return; // prevent double tap

          if (isOnline) {
            _showOfflineDialog(context);
          } else {
            mapController.driverSwitchAvailabilityStatus();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 150,
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isOnline
                ? Colors.green
                : Colors.grey.shade700,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [

              /// CENTER TEXT OR LOADER
              if (isLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Text(
                  isOnline ? "Online" : "Offline",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

              /// SLIDING CIRCLE
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: isOnline
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: isOnline
                        ? Colors.green
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 5,
          backgroundColor: Colors.transparent,
          child: GlassBackgroundMultipleChildrenWidget(
            blurOne: 8,
            blurTwo: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'X',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Icon(
                  Icons.wifi_off,
                  size: 50.r,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Are you sure you would like to go Offline?',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Color(0xff171717),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      mapController.driverSwitchAvailabilityStatus();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Go Offline',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  /*
  void _showOfflineDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Go Offline?",
      middleText:
      "Are you sure you want to go offline?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        mapController.driverSwitchAvailabilityStatus();
      },
    );
  }
  */
}