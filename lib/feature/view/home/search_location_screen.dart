import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/models/home/place_suggestion.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/services/location_permission_service.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';

class SearchLocationScreen extends StatelessWidget {
  SearchLocationScreen({super.key});

  final controller = Get.put(GoogleSearchLocationController());
  final pickupFocus = FocusNode();
  final dropFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
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
              _buildFareCard(),
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

  Widget _buildFareCard() {
    return Obx(() {
      if (!controller.hasFare) return SizedBox();

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.greenColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.greenColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fare Details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenColor,
                  ),
                ),
                Icon(
                  Icons.price_check,
                  color: AppColors.greenColor,
                  size: 20.w,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildFareRow(
              'Distance',
              controller.distance.value,
              Icons.directions_car,
            ),
            SizedBox(height: 8.h),
            _buildFareRow(
              'Duration',
              controller.duration.value,
              Icons.access_time,
            ),
            SizedBox(height: 8.h),
            _buildFareRow(
              'Pickup',
              controller.pickupController.text,
              Icons.location_on,
              color: AppColors.greenColor,
            ),
            SizedBox(height: 8.h),
            _buildFareRow(
              'Drop-off',
              controller.dropController.text,
              Icons.location_on,
              color: Colors.red,
            ),
            if (controller.noteController.text.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildFareRow(
                'Note',
                controller.noteController.text,
                Icons.note,
                color: Colors.orange,
              ),
            ],
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 12.h),
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
                  '₹${controller.fare.value}',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFareRow(String label, String value, IconData icon,
      {Color color = Colors.grey}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.w,
          color: color,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
      if (controller.hasFare) {
        return Column(
          children: [
            CustomPrimaryButton(
              onHandler: () {
                print('=== CONFIRMING RIDE ===');
                print('Pickup: ${controller.selectedPickup.value?.address}');
                print('Drop: ${controller.selectedDrop.value?.address}');
                print('Note: ${controller.noteController.text}');
                print('Distance: ${controller.distance.value}');
                print('Duration: ${controller.duration.value}');
                print('Fare: ₹${controller.fare.value}');
                print('=======================');

                // Navigate to next screen
                // Get.to(() => RideConfirmationScreen());
              },
              title: 'Confirm Ride',
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () {
                // Clear fare and recalculate
                controller.distance.value = '';
                controller.duration.value = '';
                controller.fare.value = 0.0;
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

            await controller.calculateFare();
          },
          title: controller.isLoadingFare.value ? 'Calculating...' : 'Calculate Fare',
        );
      }
    });
  }

  @override
  void dispose() {
    pickupFocus.dispose();
    dropFocus.dispose();
    // super.dispose();
  }
}