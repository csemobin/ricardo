import 'package:flutter/material.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';

class SwipeToSearchButton extends StatelessWidget {
  const SwipeToSearchButton({
    super.key,
    required this.userController,
    required this.googleSearchLocationController,
    required this.rideController,
    required this.mapOPTController,
  });

  final UserController userController;
  final GoogleSearchLocationController googleSearchLocationController;
  final RideController rideController;
  final MapOPTController mapOPTController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = userController.userModel.value?.userProfile?.role;
      final status = mapOPTController.rideStatusData.value;

      final swipedButton = role == AppConstants.passenger &&
          googleSearchLocationController.isModalOn.value == false &&
          rideController.isSwippedButtonShow.value == false &&
          rideController.viewInMap.value == true &&
          rideController.isRideAccepted.value == false &&
          status?.acceptRide != true &&
          status?.ongoingRide != true &&
          status?.arrivingRide != true &&
          status?.startRide != true &&
          status?.driverCancel != true &&
          status?.passengerCancel != true &&
          status?.completeRide != true;

      if (!swipedButton) {
        final checks = <String, bool>{
          'isPassenger': role == AppConstants.passenger,
          'isModalOff': googleSearchLocationController.isModalOn.value == false,
          'isSwippedButtonShowFalse':
              rideController.isSwippedButtonShow.value == false,
          'viewInMap': rideController.viewInMap.value == true,
          'isRideAcceptedFalse': rideController.isRideAccepted.value == false,
          'noAcceptRide': status?.acceptRide != true,
          'noOngoingRide': status?.ongoingRide != true,
          'noArrivingRide': status?.arrivingRide != true,
          'noStartRide': status?.startRide != true,
          'noDriverCancel': status?.driverCancel != true,
          'noPassengerCancel': status?.passengerCancel != true,
          'noCompleteRide': status?.completeRide != true,
        };
        final failed = checks.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList();
        debugPrint(
          'LetsGo swipe hidden | failed: $failed | values: '
          'role=$role, isModalOn=${googleSearchLocationController.isModalOn.value}, '
          'isSwippedButtonShow=${rideController.isSwippedButtonShow.value}, '
          'viewInMap=${rideController.viewInMap.value}, '
          'viewInMapReturn=${rideController.viewInMapReturn.value}, '
          'isRideAccepted=${rideController.isRideAccepted.value}, '
          'acceptRide=${status?.acceptRide}, ongoingRide=${status?.ongoingRide}, '
          'arrivingRide=${status?.arrivingRide}, startRide=${status?.startRide}, '
          'driverCancel=${status?.driverCancel}, passengerCancel=${status?.passengerCancel}, '
          'completeRide=${status?.completeRide}',
        );
      } else {
        debugPrint(
          'LetsGo swipe visible | wallet=${userController.userModel.value?.userProfile?.wallet ?? 0}',
        );
      }

      if (swipedButton) {
        return Column(
          children: [
            (userController.userModel.value?.userProfile?.wallet ?? 0) > 6
                ? _buildSwipedButton()
                : Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.errorColor.withAlpha(50)),
                    child: Center(
                      child: Text(
                        'Your account balance is too low. \n A minimum of \$5 is required to book a ride.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorColor,
                            fontSize: 14),
                      ),
                    ),
                  ),
            const SizedBox(height: 100),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildSwipedButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SlideAction(
        sliderButtonYOffset: 0,
        onSubmit: () => Get.toNamed(AppRoutes.searchLocationScreen,
            arguments: {'back_disable': true}),
        text: 'Lets Go...',
        textStyle: TextStyle(
          fontSize: 20,
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.poppins,
        ),
        innerColor: AppColors.greenColor,
        outerColor: AppColors.blackButton,
        sliderButtonIcon: const Icon(
          Icons.arrow_right_alt,
          color: Color(0XFFF6F6F6),
          size: 24,
          weight: 900,
        ),
        sliderRotate: false,
        height: 56,
        sliderButtonIconPadding: 8,
      ),
    );
  }
}
