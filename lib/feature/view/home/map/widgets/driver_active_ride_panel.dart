import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/ride_distance_formatter.dart';
import 'package:ricardo/app/helpers/ride_eta_resolver.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/feature/view/home/map/dialogs/cancel_reason_sheet.dart';
import 'package:ricardo/widgets/custom_loader.dart';

String _formatWaitingDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

class DriverActiveRidePanel extends StatelessWidget {
  const DriverActiveRidePanel({
    super.key,
    required this.mapOPTController,
    required this.onRideCancelled,
  });

  final MapOPTController mapOPTController;
  final Future<void> Function() onRideCancelled;

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundWidget(
      child: Obx(() {
        final rideStatus = mapOPTController.rideStatusData.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  // Keep GPS position in the Obx subscription so distance
                  // updates while the driver moves, even without socket data.
                  mapOPTController.currentLatitudePosition?.value;
                  mapOPTController.currentLongitudePosition?.value;

                  final metrics = RideEtaResolver.resolve(
                    controller: mapOPTController,
                    rideStatus: mapOPTController.rideStatusData.value,
                  );

                  return Text(
                    RideDistanceFormatter.formatEtaLine(
                      durationSeconds: metrics.durationSeconds,
                      distanceMeters: metrics.distanceMeters,
                    ),
                    style: TextStyle(
                      color: AppColors.timeAndDurationColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontFamily.poppins,
                      fontSize: 20.sp,
                    ),
                  );
                }),
                const SizedBox(width: 10),
                Visibility(
                  visible: rideStatus?.acceptRide == true ||
                      rideStatus?.ongoingRide == true ||
                      rideStatus?.arrivingRide == true,
                  child: GestureDetector(
                    onTap: () {
                      mapOPTController.showCancelReasonDialog.value = true;
                      showCancelReasonSheet(
                        context,
                        mapOPTController: mapOPTController,
                        onConfirmed: onRideCancelled,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.block, color: Colors.red, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 28),
            Divider(height: 1, color: Colors.black.withOpacity(0.2)),
            const SizedBox(height: 16),
            Obx(() {
              final rideStatus = mapOPTController.rideStatusData.value;

              if (rideStatus == null) {
                return const SizedBox(
                  height: 70,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final filename = rideStatus.ride?.passenger?.image?.filename;
              final hasImage = filename != null && filename.isNotEmpty;
              final imageUrl =
                  hasImage ? '${ApiUrls.imageBaseUrl}$filename' : null;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
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
                              )
                            : Image.asset(
                                'assets/images/default_image.jpg',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rideStatus.ride?.passenger?.name ??
                                'Unknown Passenger',
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
                                '\$${rideStatus.ride?.fare ?? 0.0} ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '(${((rideStatus.ride?.destinationMeters ?? 0) / 1000).toStringAsFixed(2)} KM)',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      launchUrl(
                        Uri.parse("tel:${rideStatus.passenger?.phone}"),
                      );
                    },
                    child: RepaintBoundary(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.greyColor200),
                        ),
                        child: SvgPicture.asset(Assets.icons.driverCardPhone),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            Obx(() {
              final metrics = RideEtaResolver.resolve(
                controller: mapOPTController,
                rideStatus: mapOPTController.rideStatusData.value,
              );
              final rideStatus = mapOPTController.rideStatusData.value;

              final bool enableArriveInPlace =
                  (rideStatus?.ongoingRide == true) &&
                      metrics.distanceMeters <= 200;

              final bool enableComplete = (rideStatus?.startRide == true) &&
                  metrics.distanceMeters <= 200;

              String getButtonTitle() {
                if (rideStatus == null) return 'Loading...';
                if (rideStatus.acceptRide == true) return 'On the way';
                if (rideStatus.ongoingRide == true) return 'Arrive in Place';
                if (rideStatus.arrivingRide == true) return 'Start Ride';
                if (rideStatus.startRide == true) return 'Complete';
                return 'Loading...';
              }

              bool isButtonEnabled() {
                if (rideStatus == null) return false;
                if (rideStatus.acceptRide == true) return true;
                if (rideStatus.ongoingRide == true) {
                  return enableArriveInPlace;
                }
                if (rideStatus.arrivingRide == true) return true;
                if (rideStatus.startRide == true) return enableComplete;
                return false;
              }

              if (mapOPTController.isRideStatusChangeLoading.value == true ||
                  mapOPTController.isCompleteRideLoading.value == true) {
                return CustomLoader();
              }

              return Column(
                children: [
                  CustomPrimaryButton(
                    title: getButtonTitle(),
                    onHandler: isButtonEnabled()
                        ? () async {
                            final rideId = rideStatus?.ride?.id;
                            if (rideId == null) return;

                            if (rideStatus?.acceptRide == true) {
                              debugPrint('🚕 accepted → ongoing');
                              await mapOPTController.rideStatusChange(
                                  rideId, 'ongoing');
                            } else if (rideStatus?.ongoingRide == true) {
                              debugPrint('🚕 ongoing → arriving');
                              await mapOPTController.rideStatusChange(
                                  rideId, 'arriving');
                            } else if (rideStatus?.arrivingRide == true) {
                              debugPrint('🚕 arriving → start_ride');
                              final started =
                                  await mapOPTController.rideStatusChange(
                                rideId,
                                'start_ride',
                              );
                              if (started) {
                                await mapOPTController.finalizeWaitingFine();
                              }
                            } else if (rideStatus?.startRide == true) {
                              debugPrint('🚕 start_ride → complete');
                              mapOPTController.isPassengerRequest.value = false;
                              final completed =
                                  await mapOPTController.completeRideHandler(
                                rideId,
                                waitingTime:
                                    mapOPTController.waitingTimeForCompletion,
                              );
                              debugPrint(
                                '🚗🏁 driver Complete tapped | apiSuccess=$completed',
                              );
                              if (completed) {
                                debugPrint(
                                    '🚗🧹 driver → onRideCancelled/finishRide');
                                await onRideCancelled();
                              }
                            }
                          }
                        : null,
                  ),
                  if (rideStatus?.arrivingRide == true) ...[
                    const SizedBox(height: 12),
                    if (mapOPTController.isWaitingFineRunning.value)
                      Text(
                        'Waiting time: ${_formatWaitingDuration(mapOPTController.waitingFineSeconds.value)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      )
                    else if (mapOPTController.isWaitingFineAvailable.value)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: mapOPTController.startWaitingFine,
                          child: const Text(
                            'Start Waiting Fine',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Free waiting time: ${_formatWaitingDuration(mapOPTController.freeWaitingSeconds.value)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }
}
