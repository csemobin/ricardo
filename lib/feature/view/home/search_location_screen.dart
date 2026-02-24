import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/models/home/place_suggestion.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/services/location_permission_service.dart';
import 'package:ricardo/widgets/custom_loader.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class SearchLocationScreen extends StatelessWidget {
  SearchLocationScreen({super.key});

  final controller = Get.put(GoogleSearchLocationController());
  final googleSearchLocationController =
      Get.find<GoogleSearchLocationController>();

  final pickupFocus = FocusNode();
  final dropFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            controller.cleanField();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Let's Go...",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        forceMaterialTransparency: true,
        backgroundColor: AppColors.bgColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildPickupField(),
              _buildPickupSuggestions(),
              SizedBox(height: 16.h),
              _buildDropField(),
              _buildDropSuggestions(),
              SizedBox(height: 16.h),
              _buildNoteField(),
              SizedBox(height: 24.h),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickupField() {
    return Obx(() => CustomTextField(
          focusNode: pickupFocus,
          controller: controller.pickupController,
          labelText: 'Pick-up Location',
          hintText: 'Enter pick-up location',
          prefixIcon: Image.asset(
            Assets.images.greenPin.path,
            width: 20.w,
            height: 20.h,
          ),
          suffixIcon: controller.showClearPickup.value
              ? IconButton(
                  onPressed: () {
                    controller.clearPickup();
                    pickupFocus.unfocus();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[700],
                    size: 20.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 40.w,
                    minHeight: 40.h,
                  ),
                )
              : SizedBox(width: 40.w), // Keep space for alignment
        ));
  }

  Widget _buildDropField() {
    return Obx(() => CustomTextField(
          focusNode: dropFocus,
          controller: controller.dropController,
          labelText: 'Drop-off Location',
          hintText: 'Enter drop-off location',
          prefixIcon: Image.asset(
            Assets.images.greyMap.path,
            width: 20.w,
            height: 20.h,
          ),
          suffixIcon: controller.showClearDrop.value
              ? IconButton(
                  onPressed: () {
                    controller.clearDrop();
                    dropFocus.unfocus();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[700],
                    size: 20.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 40.w,
                    minHeight: 40.h,
                  ),
                )
              : SizedBox(width: 40.w),
        ));
  }

  Widget _buildNoteField() {
    return CustomTextField(
      controller: controller.noteController,
      labelText: 'Note for Driver (Optional)',
      hintText: 'Any special instructions for driver?',
      maxLines: 3,
      minLines: 3,
    );
  }

  Widget _buildPickupSuggestions() {
    return Obx(() {
      if (controller.isLoadingPickup.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.greenColor,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (controller.pickupPlaces.isEmpty) {
        return SizedBox();
      }

      return _buildPlaceList(
        places: controller.pickupPlaces,
        onSelect: (place) {
          controller.selectPickup(place);
          pickupFocus.unfocus();
          Future.delayed(Duration(milliseconds: 100), () {
            dropFocus.requestFocus();
          });
        },
        title: 'Pick-up Suggestions',
        iconColor: AppColors.greenColor,
      );
    });
  }

  Widget _buildDropSuggestions() {
    return Obx(() {
      if (controller.isLoadingDrop.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (controller.dropPlaces.isEmpty) {
        return SizedBox();
      }

      return _buildPlaceList(
        places: controller.dropPlaces,
        onSelect: (place) {
          controller.selectDrop(place);
          dropFocus.unfocus();
        },
        title: 'Drop-off Suggestions',
        iconColor: Colors.red,
      );
    });
  }

  Widget _buildPlaceList({
    required List<PlaceSuggestion> places,
    required Function(PlaceSuggestion) onSelect,
    required String title,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: places.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final place = places[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                leading: Icon(
                  Icons.location_on,
                  color: iconColor,
                  size: 22.w,
                ),
                title: Text(
                  place.mainText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: place.secondaryText.isNotEmpty
                    ? Text(
                        place.secondaryText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      )
                    : null,
                onTap: () => onSelect(place),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _buildFareCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        content: Obx(
          () {
            if (!controller.hasFare) return const SizedBox();
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 6,
                  sigmaY: 6,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *
                        0.9, // Limit height to 90% of screen
                  ),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.whiteColor.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -4),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    // Make content scrollable
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ... rest of your dialog content remains the same
                        // Header with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Confirm Request',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greenColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close,
                                color: AppColors.blackColor,
                                size: 24.w,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 40.w,
                                minHeight: 40.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Trip distance row
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Trip',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                controller.distance.value.isNotEmpty
                                    ? controller.distance.value
                                    : '0.0 Km',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.greenColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Location details
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pickup location row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: AppColors.greenColor,
                                    size: 16.w,
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PICKUP',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          controller.pickupController.text
                                                  .isNotEmpty
                                              ? controller.pickupController.text
                                              : ' ',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Dotted line
                              Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: Container(
                                  width: 2,
                                  height: 20.h,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),

                              // Drop location row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'DROP',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          controller.dropController.text
                                                  .isNotEmpty
                                              ? controller.dropController.text
                                              : ' ',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Fare row
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ride fare:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${controller.fare.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.greenColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Information section
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Before you confirm',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[700],
                                  ),
                                  children: [
                                    TextSpan(text: '• If you are late, a '),
                                    TextSpan(
                                      text:
                                          '\$${dotenv.env['LATE_FINE_CHARGE']}/min',
                                      style: TextStyle(
                                          color: AppColors.errorColor),
                                    ),
                                    TextSpan(text: ' delay fee will apply.'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '• If you cancel after a driver is on the way, a cancellation fee will be charged.',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        Text(
                          'Do you want to continue?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.grey[800],
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Obx(
                                () {
                                  return controller.isBookRideState.value ==
                                          true
                                      ? CustomLoader()
                                      : ElevatedButton(
                                          onPressed: () {
                                            controller.bookRideHandler();
                                            googleSearchLocationController
                                                .isModalOn.value = true;
                                            Navigator.pop(context);
                                            // Navigator.pop(context);
                                            // // Add your confirm action here
                                            // Get.snackbar(
                                            //   'Success',
                                            //   'Ride confirmed successfully!',
                                            //   backgroundColor: AppColors.greenColor,
                                            //   colorText: Colors.white,
                                            //   snackPosition: SnackPosition.TOP,
                                            // );
                                            // controller.showPopUpStatus
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.greenColor,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 14.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                          ),
                                          child: Text(
                                            'Yes, Send',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                },
                              ),
                            ),
                          ],
                        ),

                        // Note section if exists
                        if (controller.noteController.text.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  color: Colors.orange,
                                  size: 18.w,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    controller.noteController.text,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 12.h),
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 12.h),

                        // Estimated fare
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Fare',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '\$${controller.fare.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.greenColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h), // Add bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget _buildFareRow(String label, String value, IconData icon,
  //     {Color color = Colors.grey}) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Icon(
  //         icon,
  //         size: 18.w,
  //         color: color,
  //       ),
  //       SizedBox(width: 10.w),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: TextStyle(
  //                 fontSize: 12.sp,
  //                 color: Colors.grey[600],
  //               ),
  //             ),
  //             SizedBox(height: 2.h),
  //             Text(
  //               value,
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildActionButton() {
    return Obx(() {
      if (controller.hasFare) {
        return Column(
          children: [
            CustomPrimaryButton(
              onHandler: () {
                pickupFocus.unfocus();
                dropFocus.unfocus();
                _buildFareCard(Get.context!);
              },
              title: 'Confirm Ride',
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () {
                // Clear fare and recalculate
                // controller.distance.value = '';
                // controller.duration.value = '';
                // controller.fare.value = 0.0;
                pickupFocus.unfocus();
                dropFocus.unfocus();
                _buildFareCard(Get.context!);
              },
              child: Text(
                'Recalculate Fare',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      } else {
        return CustomPrimaryButton(
          onHandler: () async {
            // Check location permission
            final status =
                await LocationPermissionService.checkAndRequestLocation();

            if (status != LocationStatus.granted) {
              showDialog(
                context: Get.context!,
                builder: (context) => AlertDialog(
                  title: Text('Location Permission Required'),
                  content: Text(
                      'Please enable location permissions to calculate fare.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }

            if (!controller.canCalculateFare) {
              Get.snackbar(
                'Missing Information',
                'Please select both pick-up and drop-off locations',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: Duration(seconds: 2),
              );
              return;
            }

            // Calculate fare
            await controller.calculateFare();

            // ✅ ADDED: Automatically open popup after fare calculation
            if (controller.hasFare) {
              _buildFareCard(Get.context!);
            }
          },
          title:
              controller.isLoadingFare.value ? 'Calculating...' : 'Find Ride',
        );
      }
    });
  }

  void dispose() {
    pickupFocus.dispose();
    dropFocus.dispose();
  }
}
