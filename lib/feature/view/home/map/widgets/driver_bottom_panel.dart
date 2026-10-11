import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/feature/view/home/map/widgets/driver_active_ride_panel.dart';
import 'package:ricardo/feature/view/home/map/widgets/glass_design.dart';
import 'package:ricardo/services/connectivity_service.dart';

class DriverBottomPanel extends StatelessWidget {
  const DriverBottomPanel({
    super.key,
    required this.userController,
    required this.rideController,
    required this.mapOPTController,
    required this.onRideCancelled,
  });

  final UserController userController;
  final RideController rideController;
  final MapOPTController mapOPTController;
  final Future<void> Function() onRideCancelled;

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();
    return Obx(() {
      final role = userController.userModel.value?.userProfile?.role;
      final status = mapOPTController.rideStatusData.value;
      final isAcceptedDriver = mapOPTController
              .acceptedRideDriverData.value?.isRideAcceptedDriver ??
          false;
      final bool isOnline = connectivity.isConnected.value;

      final showPassengerGif = isOnline &&
          role == AppConstants.driver &&
          mapOPTController.isPassengerRequest.value == false &&
          userController.userModel.value?.driverProfile?.isOnline == true &&
          mapOPTController.acceptedRideDriverDataStatus.value == false &&
          rideController.isRideAccepted.value == false &&
          status?.acceptRide != true &&
          status?.ongoingRide != true &&
          status?.arrivingRide != true &&
          status?.startRide != true &&
          status?.driverCancel != true &&
          status?.passengerCancel != true;

      if (showPassengerGif) {
        return Container(
          margin: const EdgeInsets.only(bottom: 90),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: GlassDesignContainer(child: CustomPassengerWaitingGif()),
        );
      }

      if (role == AppConstants.driver &&
          mapOPTController.isPassengerRequest.value == true &&
          mapOPTController.acceptedRideDriverDataStatus.value == false &&
          rideController.isRideAccepted.value == false &&
          status?.acceptRide != true &&
          status?.ongoingRide != true &&
          status?.startRide != true &&
          status?.arrivingRide != true &&
          status?.driverCancel != true &&
          status?.passengerCancel != true ) {
        return const PassengerRideRequestSheet();
      }

      final showActiveRide = role == AppConstants.driver &&
          (isAcceptedDriver ||
              mapOPTController.acceptedRideDriverDataStatus.value == true ||
              status?.acceptRide == true ||
              status?.ongoingRide == true ||
              status?.arrivingRide == true ||
              status?.driverCancel == true ||
              status?.passengerCancel == true ||
              status?.startRide == true);

      if (showActiveRide) {
        return DriverActiveRidePanel(
          mapOPTController: mapOPTController,
          onRideCancelled: onRideCancelled,
        );
      }

      return const SizedBox.shrink();
    });
  }
}
