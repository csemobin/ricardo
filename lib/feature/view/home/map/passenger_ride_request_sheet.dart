import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/accepted_ride_button.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';

class PassengerRideRequestSheet extends StatelessWidget {
  const PassengerRideRequestSheet({super.key});

  TextStyle _textStyle() {
    return TextStyle(
      color: AppColors.primaryHeadingTextColor,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.poppins,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapOPTController = Get.find<MapOPTController>();

    return GlassBackgroundMultipleChildrenWidget(
      blurOne: 20,
      blurTwo: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Handle bar ──────────────────────────
        Center(
          child: Container(
            width: 50,
            height: 5,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFB9C0C9),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        const SizedBox(height: 10),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                final cnt = Get.find<RideController>();

                // cnt.cancelRequest(cnt.rideId.value, cnt.acceptRideModel.value!.driverCar!.driverId!);
                cnt.cancelRequest(mapOPTController.rideStatusData.value!.ride!.id!, mapOPTController.rideStatusData.value!.ride!.driver!.id!);

                // _cancelAutoTimer();
                //
                // _isWaitingDialogOpen = false;
                // if (Navigator.of(dialogContext).canPop()) {
                //   Navigator.of(dialogContext).pop();
                // }

                mapOPTController.isPassengerRequest.value = false;
                mapOPTController.cancelRideRequestTimer();
                // userController.userModel.value?.driverProfile?.isOnline = true;
              },
              icon: Icon(
                Icons.clear,
                fontWeight: FontWeight.w600,
                size: 25,
                color: AppColors.blackColor,
              ),
            )
          ],
        ),*/
        // ── Passenger Info ──────────────────────
        Obx(() => Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      (mapOPTController.rideDetailsData.value?.passengerImage !=
                                  null &&
                              mapOPTController.rideDetailsData.value!
                                  .passengerImage!.isNotEmpty)
                          ? '${ApiUrls.imageBaseUrl}${mapOPTController.rideDetailsData.value?.passengerImage}'
                          : '',
                      // Fallback network image
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/default_image.jpg',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mapOPTController.rideDetailsData.value?.passengerName ??
                          '',
                      style: TextStyle(
                        color: const Color(0xff171717),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.poppins,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '\$${mapOPTController.rideDetailsData.value?.fare ?? 0.0} ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '(${((mapOPTController.rideDetailsData.value?.destinationMeters ?? 0) * 0.000621371).toStringAsFixed(2)} Miles)',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )),
        const SizedBox(height: 20),

        // ── Divider ─────────────────────────────
        Divider(height: 1, color: Colors.black.withOpacity(0.2)),
        const SizedBox(height: 6),

        // ── Pickup / Dropoff ────────────────────
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(Assets.images.directRight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PICK UP',
                            style: TextStyle(
                              color: AppColors.labelTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.poppins,
                            ),
                          ),
                          Text(
                            mapOPTController
                                    .rideDetailsData.value?.pickupAddress ??
                                'Pickup location not specified',
                            style: _textStyle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                  child: Container(
                    width: 4,
                    height: 40,
                    decoration: const BoxDecoration(color: Colors.white),
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(Assets.images.location),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DROP OFF',
                            style: TextStyle(
                              color: AppColors.labelTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.poppins,
                            ),
                          ),
                          Text(
                            mapOPTController.rideDetailsData.value
                                    ?.destinationAddress ??
                                'Destination not specified',
                            style: _textStyle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
        const SizedBox(height: 6),

        // ── Divider ─────────────────────────────
        Divider(height: 1, color: Colors.black.withOpacity(0.2)),
        const SizedBox(height: 8),

        // ── Passenger Note ──────────────────────
        Text(
          'Passengers Note',
          style: TextStyle(
            color: const Color(0xff5E5E5E).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => Text(
              mapOPTController.rideDetailsData.value?.note?.trim().isNotEmpty ==
                      true
                  ? mapOPTController.rideDetailsData.value!.note!
                  : 'No note provided',
            )),
        const SizedBox(height: 18),

        // ── Button ───────────────────────
        Obx(() {
          if (mapOPTController.isRideAcceptStatusLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          final rideId = mapOPTController.rideDetailsData.value?.rideId;
          final hasRideDetails =
              rideId != null && rideId.isNotEmpty;

          return AcceptRideButton(
            onPressed: hasRideDetails
                ? () {
                    mapOPTController.rideAcceptRide(rideId);
                  }
                : () {
                    showSnackbar(
                      'Error',
                      'Ride details are missing. Please wait for the request to reload.',
                    );
                  },
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }
}
