import 'package:flutter/material.dart';
import 'package:ricardo/app/helpers/ride_distance_formatter.dart';
import 'package:ricardo/app/helpers/ride_eta_resolver.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/widgets.dart';

class DraggableBottomSheet extends StatefulWidget {
  final RideStatusModel? rideStatus;
  final MapOPTController? controller;

  const DraggableBottomSheet({
    super.key,
    this.rideStatus,
    this.controller,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  final controller = Get.find<MapOPTController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.rideStatusData.value;

      final isComplete = data?.completeRide == true;

      debugPrint(
        '🧳📋 bottom sheet build | completeRide=${data?.completeRide} '
        'startRide=${data?.startRide} isComplete=$isComplete rideId=${data?.ride?.id}',
      );

      return DraggableScrollableSheet(
        initialChildSize: isComplete ? 0.56 : 0.42,
        minChildSize: 0.12,
        maxChildSize: isComplete ? 0.78 : 0.62,
        expand: false,
        builder: (context, scrollController) {
          final rideData = data ?? widget.rideStatus;
          return GlassBackgroundWidget(
            blurNumber: 12,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            child: Container(
              color: Colors.white.withValues(alpha: 0.94),
              child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildSheetHeader(rideData),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12.h,
                      right: 12.h,
                      top: 16.h,
                      // Keeps the action buttons clear of the sheet's bottom
                      // edge and the device's home indicator.
                      bottom: 32.h + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        _buildDriverCard(rideData),
                        SizedBox(height: 14.h),
                        _buildVehicleCard(rideData),
                        if (rideData?.arrivingRide == true &&
                            rideData?.completeRide != true) ...[
                          SizedBox(height: 18.h),
                          Text(
                            'If you have entered the car, please confirm with your driver to start the ride in the app.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xff007635),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        /// COMPLETE BUTTON
                        Obx(() {
                          final complete =
                              controller.rideStatusData.value?.completeRide ==
                                  true;

                          if (!complete) {
                            debugPrint(
                              '🔘❌ Review/Tips/BackToHome HIDDEN | '
                              'completeRide=${controller.rideStatusData.value?.completeRide} '
                              'startRide=${controller.rideStatusData.value?.startRide} '
                              'ride.status=${controller.rideStatusData.value?.ride?.status}',
                            );
                            return const SizedBox();
                          }

                          debugPrint(
                            '🔘✅ Review/Tips/BackToHome VISIBLE | '
                            'completeRide=true rideId=${controller.rideStatusData.value?.ride?.id}',
                          );

                          return Column(
                            children: [
                              if (Get.find<UserController>()
                                      .userModel
                                      .value
                                      ?.userProfile
                                      ?.role ==
                                  AppConstants.passenger)
                                Obx(() {
                                  final liveRide =
                                      controller.rideStatusData.value;
                                  final reviewId = liveRide?.ride?.reviewId;
                                  final alreadyReviewed = reviewId != null &&
                                      reviewId.toString().isNotEmpty;
                                  final rideId = liveRide?.ride?.id;
                                  // Touch the set so Obx rebuilds after tip success.
                                  final tippedIds = controller.tippedRideIds;
                                  final alreadyTipped = rideId != null &&
                                      tippedIds.contains(rideId);
                                  final driverId = liveRide?.ride?.driver?.id ??
                                      liveRide?.driver?.id ??
                                      liveRide?.driverCar?.driverId;

                                  return Row(
                                    children: [
                                      Flexible(
                                        child: CustomPrimaryButton(
                                          title: alreadyReviewed
                                              ? 'Reviewed'
                                              : 'review',
                                          onHandler: alreadyReviewed
                                              ? null
                                              : () {
                                                  controller
                                                      .prepareFavouriteForDriver(
                                                    driverId,
                                                  );
                                                  Get.toNamed(
                                                    AppRoutes.rateReviewDriver,
                                                    arguments: {
                                                      'name':
                                                          liveRide?.driver?.name,
                                                      'driverId': driverId,
                                                      'rideId': rideId,
                                                      'alreadyReviewed':
                                                          alreadyReviewed,
                                                    },
                                                  );
                                                },
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Flexible(
                                        child: _outlineSheetButton(
                                          title: alreadyTipped
                                              ? 'Tipped'
                                              : 'Tips',
                                          onTap: alreadyTipped
                                              ? null
                                              : () {
                                                  _buildTipsShowDialog(context);
                                                },
                                        ),
                                      )
                                    ],
                                  );
                                }),
                              SizedBox(
                                height: 16.h,
                              ),
                              _filledSheetButton(
                                title: 'Back To Home',
                                background: const Color(0xFF4A4A4A),
                                onTap: () async {
                                  debugPrint(
                                      '🏠👆 passenger tapped Back to Home');
                                  final rideId =
                                      controller.rideStatusData.value?.ride?.id;
                                  if (rideId != null && rideId.isNotEmpty) {
                                    controller.markRideFinished(rideId);
                                  }
                                  controller.clearRideSession();
                                  final rideController =
                                      Get.find<RideController>();
                                  rideController.returnToNormalView();
                                  rideController.isSwippedButtonShow.value =
                                      false;
                                  Get.find<GoogleSearchLocationController>()
                                      .isModalOn
                                      .value = false;
                                  await Get.find<UserController>()
                                      .fetchActiveRideStatus();
                                  Get.offAllNamed(AppRoutes.customBottomNavBar);
                                  Get.find<CustomBottomNavBarController>()
                                      .onChange(0);
                                  debugPrint(
                                      '🏠✅ Back to Home done → navbar home');
                                },
                              )
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      );
    });
  }

  Widget _outlineSheetButton({
    required String title,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: enabled
                ? const Color(0xff1BB600)
                : const Color(0xff1BB600).withValues(alpha: 0.35),
            width: 1.4,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: enabled
                ? const Color(0xff007635)
                : const Color(0xff007635).withValues(alpha: 0.45),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _filledSheetButton({
    required String title,
    required Color background,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _etaLabel(int seconds) {
    if (seconds <= 0) return '--';
    final minutes = (seconds / 60).ceil();
    return '$minutes min';
  }

  Widget _buildSheetHeader(RideStatusModel? data) {
    controller.currentLatitudePosition?.value;
    controller.currentLongitudePosition?.value;
    final metrics = RideEtaResolver.resolve(
      controller: controller,
      rideStatus: data,
    );
    final isComplete = data?.completeRide == true;
    final isNear = metrics.distanceMeters > 0 && metrics.distanceMeters <= 500;

    final String statusText;
    if (data == null) {
      statusText = 'Updating your ride';
    } else if (data.completeRide == true) {
      statusText = 'Ride completed';
    } else if (data.arrivingRide == true) {
      statusText = 'Rider Arrive';
    } else if (data.startRide == true) {
      statusText = 'Heading to your destination';
    } else {
      statusText = 'Rider is on the way to pickup';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD7D9DE),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: const BoxDecoration(
                  color: Color(0xff00C853),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.poppins,
                    color: AppColors.darkColor,
                  ),
                ),
              ),
              if (!isComplete) ...[
                SizedBox(width: 10.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: (data?.arrivingRide == true || isNear)
                        ? const Color(0xff00C853)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _etaLabel(metrics.durationSeconds),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              if (isComplete)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22.r),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.reportScreen,
                        arguments: {'rideId': data?.ride?.id},
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: const Color(0xFFFF4D4F)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 16.r,
                            color: const Color(0xFFFF4D4F),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Report',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontFamily.poppins,
                              color: const Color(0xFFFF4D4F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(RideStatusModel? data) {
    final driver = data?.driver;
    final imageName = driver?.image?.filename;
    final imageUrl = imageName != null && imageName.isNotEmpty
        ? '${ApiUrls.imageBaseUrl}$imageName'
        : null;
    final phone = driver?.phone ?? '';
    final rating = driver?.averageRating ?? 0;
    final ratingCount = driver?.totalRatings ?? 0;
    final trips = driver?.totalCompletedRides ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: imageUrl == null
              ? Image.asset(
                  Assets.images.defaultImage.path,
                  height: 52.r,
                  width: 52.r,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imageUrl,
                  height: 52.r,
                  width: 52.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    Assets.images.defaultImage.path,
                    height: 52.r,
                    width: 52.r,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver?.name?.isNotEmpty == true
                    ? driver!.name!
                    : 'Your driver',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff007635),
                  fontFamily: FontFamily.poppins,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(Icons.star_rounded,
                      size: 15.r, color: const Color(0xFFFFC107)),
                  SizedBox(width: 3.w),
                  Flexible(
                    child: Text(
                      '${rating > 0 ? rating.toStringAsFixed(1) : 'New'} ($ratingCount)  |  $trips Trips',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (phone.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 13.r,
                      color: const Color(0xff00C853),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xff00C853),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Material(
          color: const Color(0xFFF3F4F6),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: phone.isEmpty
                ? null
                : () => launchUrl(Uri.parse('tel:$phone')),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Icon(
                Icons.phone,
                size: 20.r,
                color: const Color(0xff00C853),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(RideStatusModel? data) {
    final carName = data?.driverCar?.carName;
    final plateNumber = data?.driverCar?.carPlateNumber;
    final seats = data?.driverCar?.numberOfSeat;
    final carImageName = data?.driverCar?.carImage?.filename;
    final carImageUrl = carImageName != null && carImageName.isNotEmpty
        ? '${ApiUrls.imageBaseUrl}$carImageName'
        : null;
    final metrics = RideEtaResolver.resolve(
      controller: controller,
      rideStatus: data,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                carName?.isNotEmpty == true ? carName! : 'Driver vehicle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkColor,
                ),
              ),
              if (seats != null) ...[
                SizedBox(height: 4.h),
                Text(
                  '$seats Seat',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
              if (plateNumber?.isNotEmpty == true) ...[
                SizedBox(height: 2.h),
                Text(
                  plateNumber!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkColor,
                  ),
                ),
              ],
              SizedBox(height: 4.h),
              Text(
                '${RideDistanceFormatter.formatDistance(metrics.distanceMeters)} away from you.',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff00C853),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: carImageUrl == null
              ? Container(
                  width: 86.w,
                  height: 64.h,
                  color: const Color(0xFFF3F4F6),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: AppColors.darkColor,
                    size: 28.r,
                  ),
                )
              : Image.network(
                  carImageUrl,
                  width: 86.w,
                  height: 64.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 86.w,
                    height: 64.h,
                    color: const Color(0xFFF3F4F6),
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      color: AppColors.darkColor,
                      size: 28.r,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<dynamic> _buildTipsShowDialog(BuildContext context) {
    const presets = ['5', '10', '15', '20'];
    controller.provideTips.clear();
    final selectedPreset = Rxn<String>();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          color: AppColors.primaryColor,
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Say thanks with a tip',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: FontFamily.poppins,
                                color: AppColors.darkColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '100% goes to your driver',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (controller.isLoading.value) return;
                          Navigator.of(dialogContext).pop();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.secondaryTextColor,
                          size: 22.r,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Obx(() {
                    final selected = selectedPreset.value;
                    return Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: presets.map((amount) {
                        final isSelected = selected == amount;
                        return InkWell(
                          borderRadius: BorderRadius.circular(30.r),
                          onTap: controller.isLoading.value
                              ? null
                              : () {
                                  selectedPreset.value = amount;
                                  controller.provideTips.text = amount;
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : const Color(0xFFF3F5F7),
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : const Color(0xFFE2E5EA),
                              ),
                            ),
                            child: Text(
                              amount,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.darkColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Or enter a custom amount',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: controller.provideTips,
                    labelText: 'Amount',
                    hintText: 'e.g. 25',
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      final typed = controller.provideTips.text.trim();
                      if (!presets.contains(typed)) {
                        selectedPreset.value = null;
                      } else {
                        selectedPreset.value = typed;
                      }
                    },
                  ),
                  SizedBox(height: 20.h),
                  Obx(() {
                    final loading = controller.isLoading.value;
                    return CustomPrimaryButton(
                      title: 'Send Tip',
                      isLoading: loading,
                      onHandler: loading
                          ? null
                          : () async {
                              final rideId =
                                  controller.rideStatusData.value?.ride?.id ??
                                      '';
                              final ok =
                                  await controller.provideTipsHandler(rideId);
                              if (ok && dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                                showSnackbar(
                                  'Thank you',
                                  'Your tip was sent to the driver',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
