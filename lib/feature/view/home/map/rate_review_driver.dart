import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:ricardo/feature/controllers/home/map/rate_review_controller.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_primary_button.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';

class RateReviewDriver extends StatelessWidget {
  RateReviewDriver({super.key});

  final controller = Get.put(RateAndReviewController());
  final cnt = Get.find<MapOPTController>();

  final String? name = Get.arguments?['name'];
  final String? driverId = Get.arguments?['driverId'];
  final String? rideId = Get.arguments['rideId'];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Rate & Review Driver',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 88.h),
            Center(
              child: CustomHeadingText(
                firstText: 'Rate',
                secondText: 'Your Driver',
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                'How was your ride with Driver?',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.poppins,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ),
            SizedBox(height: 78.h),
            _buildRattingField(),
            SizedBox(height: 48.h),
            CustomTextField(
              controller: controller.feedBackTEController,
              labelText: 'Write your feedback (optional)',
              hintText: 'Add Note',
              minLines: 5,
            ),
            SizedBox(height: 110.h),
            Obx(() {
              return GestureDetector(
                onTap: cnt.isAddedFavouriteRiderStatus.value
                    ? null
                    : () async {
                        if (driverId == null) {
                          Get.snackbar("Error", "Driver ID not found");
                          return;
                        }

                        final success = await cnt.addedFavouriteRide(driverId!);

                        if (success) {
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding:
                                  EdgeInsets.symmetric(horizontal: 24.w),
                              child: GlassBackgroundWidget(
                                borderLeftRightRadius: 24,
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                        Assets.images.congratulations.path),
                                    Text(
                                      'Congratulations!',
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: FontFamily.poppins,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: '${name ?? 'N/A'} ',
                                        style: TextStyle(
                                          color: AppColors.successColor,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'is now your favorite rider!',
                                            style: TextStyle(
                                              color: AppColors.primaryTextColor,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 26.h),
                                    CustomPrimaryButton(
                                      title: 'Okay',
                                      onHandler: () {
                                        Get.back(); // closes the dialog
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: cnt.isAddedFavouriteRiderStatus.value
                      ? CircularProgressIndicator(
                          color: Colors.green,
                        )
                      : Text(
                          'Add to Favourite',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.sp,
                          ),
                        ),
                ),
              );
            }),
            SizedBox(height: 21.h),
            Obx(
              () {
                if (controller.isRattingLoading.value) {
                  return CircularProgressIndicator();
                }
                return CustomPrimaryButton(
                  title: 'Submit Review',
                  onHandler: () {
                    controller.rateAndReviewDriverHandler(rideId!, driverId!);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRattingField() {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (_) {},
          child: RatingBar.builder(
            glow: false,
            allowHalfRating: true,
            itemCount: 5,
            initialRating: controller.driverRating.value,
            itemBuilder: (context, index) {
              return Icon(Icons.star, color: Colors.amber);
            },
            onRatingUpdate: (double value) {
              controller.driverRating.value = value;
            },
          ),
        ),
      ],
    );
  }
}
