import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';

class AcceptRideButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AcceptRideButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final mapOPTController = Get.find<MapOPTController>();
    final userController = Get.find<UserController>();

    return Obx(() {
      final isExpired = mapOPTController.isRideRequestExpired.value;
      final progress = mapOPTController.timerProgress.value;

      return GestureDetector(
        onTap: isExpired
            ? () {
          mapOPTController.isPassengerRequest.value = false;
          mapOPTController.cancelRideRequestTimer();
          userController.userModel.value?.driverProfile?.isOnline = true;
        }
            : onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 60,
            child: isExpired
                ? Container(
              color: Colors.grey,
              alignment: Alignment.center,
              child: const Text(
                'Expired',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF3A3A3A),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      color: const Color(0xFF00C853),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Accept Ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}