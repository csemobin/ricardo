import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ricardo/feature/models/home/ride_status_model.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class DraggableBottomSheet extends StatefulWidget {
  final RideStatusModel? rideStatus;
  final MapOPTController? controller;

  const DraggableBottomSheet(
      {super.key, this.rideStatus, this.controller});

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.49,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      expand: false,
      // ✅ FIX 1: Required when used inside showModalBottomSheet
      builder: (context, scrollController) {
        return GlassBackgroundWidget(
          blurNumber: 25,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ────────────────────────────────────────
                // HEADER SECTION (drag handle + status row)
                // ────────────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(vertical: 11, horizontal: 18),
                  decoration: BoxDecoration(
                    // color: Colors.white.withOpacity(0.7),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Drag handle indicator
                      Center(
                        child: Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Status row: "Rider is on the way" + "1 min" badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                 'Rider is on the way to pickup',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkColor,
                                  fontFamily: FontFamily.poppins,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.darkColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '100 min',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                fontFamily: FontFamily.poppins,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ────────────────────────────────────────
                // GLASS BODY SECTION (driver info + car info)
                // ────────────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.h,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      // ── Driver info row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Driver avatar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  '${ApiUrls.imageBaseUrl}${widget.rideStatus?.driver?.image?.filename}',
                                  height: 62.h,
                                  width: 62.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      Assets.images.defaultImage.path,
                                      height: 62.h,
                                      width: 62.w,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // ── Driver name, rating, trips, phone
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.rideStatus?.driver?.name}',
                                    style: TextStyle(
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.successColor,
                                    ),
                                  ),

                                  // ✅ Extract variables once instead of repeating null checks
                                  Builder(builder: (context) {
                                    final totalRatings = widget.rideStatus
                                            ?.driver?.totalRatings ??
                                        0;
                                    final ratingAverage = widget.rideStatus
                                            ?.driver?.averageRating ??
                                        0.0;
                                    final totalRides = widget.rideStatus
                                            ?.driver?.totalCompletedRides ??
                                        0;

                                    return Row(
                                      children: [
                                        if (totalRatings > 0) ...[
                                          Icon(Icons.star,
                                              color: AppColors.orangeColor,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$totalRatings ( $ratingAverage )',
                                            style: TextStyle(
                                              fontFamily: FontFamily.poppins,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.blackBText,
                                            ),
                                          ),
                                        ],
                                        if (totalRides > 0) ...[
                                          SizedBox(width: 8.w),
                                          Container(
                                            width: 2.w,
                                            height: 15.h,
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.30),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '$totalRides Trips',
                                            style: TextStyle(
                                              fontFamily: FontFamily.poppins,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.blackBText,
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  }),

                                  Row(
                                    children: [
                                      Icon(Icons.call,
                                          color: AppColors.greenColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.rideStatus?.driver?.phone}',
                                        style: TextStyle(
                                          fontFamily: FontFamily.poppins,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.blackBText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Phone call button (SVG icon)
                          GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "tel:${widget.rideStatus?.driver?.phone}"));
                            },
                            child: RepaintBoundary(
                              // ✅ isolates rendering
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(50),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: SvgPicture.asset(
                                  Assets.icons.driverCardPhone,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ── Car info row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.rideStatus?.driverCar?.carName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  color: AppColors.favoriteRitesCarText,
                                ),
                              ),
                              Text(
                                '${widget.rideStatus?.driverCar?.numberOfSeat} Seat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  color: AppColors.favoriteRitesCarText,
                                ),
                              ),
                              Text(
                                '${widget.rideStatus?.driverCar?.carPlateNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.poppins,
                                  fontSize: 14.sp,
                                  color: AppColors.favoriteRitesCarText,
                                ),
                              ),
                              FutureBuilder<String>(
                                future: DirectionsService.calculateDistance(
                                  widget.rideStatus?.driver?.location
                                      ?.coordinates?[0],
                                  widget.rideStatus?.driver?.location
                                      ?.coordinates?[1],
                                ),
                                builder: (context, snapshot) {
                                  final distanceText =
                                      snapshot.data ?? 'Calculating...';
                                  return Text(
                                    '$distanceText away from you.',
                                    overflow: TextOverflow.ellipsis,
                                    // ✅ safety for long text
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.poppins,
                                      fontSize: 16.sp,
                                      color: AppColors.dottedBorderColor,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              Assets.images.favoriteRidesCar.path,
                              width: 92.w,
                              height: 92.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      CustomPrimaryButton(
                          title: 'Provide a review',
                          onHandler: () {
                            Get.toNamed(
                              AppRoutes.rateReviewDriver,
                              arguments: {
                                'name':
                                    widget.rideStatus?.driver?.name,
                                'driverId' : widget.rideStatus?.driverCar?.driverId,
                                'rideId' : widget.rideStatus?.ride?.id
                              },
                            );
                          }),
                      SizedBox(
                        height: 14.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            useSafeArea: false,
                            barrierDismissible: false,
                            barrierColor: Colors.white.withOpacity(0.1),
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                              ), // ✅ side padding only
                              child: GlassBackgroundWidget(
                                borderLeftRightRadius: 24,
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  // ✅ wrap content height
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            Icons.close,
                                            color: AppColors.secondaryTextColor,
                                            size: 22,
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Tips',
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: FontFamily.poppins,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'Enjoyed your ride?',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: FontFamily.poppins,
                                          color: AppColors.secondaryTextColor),
                                    ),
                                    SizedBox(
                                      height: 34.h,
                                    ),
                                    CustomTextField(
                                      labelText: 'Enter Amount',
                                      hintText: 'Enter Amount',
                                      filColor: AppColors.whiteColor,
                                      controller:
                                          widget.controller!.provideTips,
                                    ),
                                    Text(
                                      'Tips will go completely to driver',
                                      style: TextStyle(
                                        fontFamily: FontFamily.poppins,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.secondaryTextColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 26.h,
                                    ),
                                    Obx(
                                      () {
                                        if (widget
                                            .controller!.isLoading.value) {
                                          return CircularProgressIndicator();
                                        }
                                        return CustomPrimaryButton(
                                          title: 'Submit',
                                          onHandler: () async {
                                            String? rideId = widget
                                                .rideStatus?.ride?.id;

                                            if (rideId == null ||
                                                rideId.isEmpty) {
                                              final dataString =
                                                  PrefsHelper.getString(
                                                      'ride-accepted-data');

                                              if (dataString != null) {
                                                final Map<String, dynamic>
                                                    dataMap = jsonDecode(
                                                        await dataString);
                                                rideId =
                                                    dataMap['ride']?['_id'];
                                              }
                                            }

                                            if (rideId == null ||
                                                rideId.isEmpty) {
                                              debugPrint(
                                                  "Ride ID still null ❌");
                                              Get.snackbar(
                                                  "Error", "Ride ID not found");
                                              return;
                                            }

                                            final success = await widget
                                                .controller!
                                                .provideTipsHandler(rideId);

                                            if (success) {
                                              Navigator.pop(context);
                                              Get.snackbar("Success",
                                                  "Tip sent successfully");
                                            } else {
                                              Get.snackbar("Error",
                                                  "Failed to send tip");
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          width: double.maxFinite,
                          height: 56.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.r),
                            border: Border.all(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Provide a Tip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
