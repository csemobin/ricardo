import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

/// Returns the passenger-specific overlays inserted as direct children of the
/// MapScreen's root Stack. Returned as a list so they remain top-level Stack
/// children (preserving the original layout semantics).
List<Widget> buildPassengerOverlays({
  required UserController userController,
  required GoogleSearchLocationController googleSearchLocationController,
  required RideController rideController,
  required MapOPTController mapOPTController,
}) {
  return [
    Obx(() {
      final role = userController.userModel.value?.userProfile?.role;
      final rideStatus = mapOPTController.rideStatusData.value;
      final acceptRideModel = rideController.acceptRideModel.value;

      final shouldShow = role == AppConstants.passenger &&
          (acceptRideModel?.isRideAccepted == true ||
              rideStatus?.acceptRide == true ||
              rideStatus?.ongoingRide == true ||
              rideStatus?.startRide == true ||
              rideStatus?.arrivingRide == true ||
              rideStatus?.completeRide == true);

      if (!shouldShow) {
        if (role == AppConstants.passenger) {
          debugPrint(
            '🧳❌ passenger panel HIDDEN | acceptRideModel=${acceptRideModel?.isRideAccepted} '
            'acceptRide=${rideStatus?.acceptRide} ongoing=${rideStatus?.ongoingRide} '
            'arriving=${rideStatus?.arrivingRide} startRide=${rideStatus?.startRide} '
            'completeRide=${rideStatus?.completeRide}',
          );
        }
        return const SizedBox.shrink();
      }

      debugPrint(
        '🧳✅ passenger panel VISIBLE | completeRide=${rideStatus?.completeRide} '
        'startRide=${rideStatus?.startRide} rideId=${rideStatus?.ride?.id}',
      );

      return DraggableBottomSheet(
        rideStatus: rideStatus,
        controller: mapOPTController,
      );
    }),
    Obx(() {
      if (googleSearchLocationController.isModalOn.value &&
          rideController.viewInMap.value &&
          rideController.viewInMapReturn.value == false &&
          userController.userModel.value?.userProfile?.role ==
              AppConstants.passenger) {
        return Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomSheet(
            onClosing: () {},
            backgroundColor: Colors.transparent,
            enableDrag: false,
            builder: (context) {
              return RideRequestBottomSheet(
                pickupLocation:
                    googleSearchLocationController.pickupController.text,
                dropLocation:
                    googleSearchLocationController.dropController.text,
                distance: googleSearchLocationController.distance.value
                    .toString(),
                rideFare:
                    googleSearchLocationController.fare.value.toString(),
              );
            },
          ),
        );
      }
      return const SizedBox.shrink();
    }),
    if (userController.userModel.value?.userProfile?.role ==
        AppConstants.passenger)
      Obx(() {
        final rideStatus = mapOPTController.rideStatusData.value;
        final showRideHeader =
            (rideController.viewInMap.value == true &&
                rideController.viewInMapReturn.value == false) ||
            rideStatus?.acceptRide == true ||
            rideStatus?.ongoingRide == true ||
            rideStatus?.startRide == true ||
            rideStatus?.arrivingRide == true ||
            rideStatus?.completeRide == true;

        if (showRideHeader) {
          return CustomHeader(mapOPTController: mapOPTController);
        }
        return MapCustomHeaderBack(rideController: rideController);
      }),
  ];
}
