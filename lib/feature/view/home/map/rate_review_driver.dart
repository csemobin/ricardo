import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ricardo/feature/controllers/home/map/rate_review_controller.dart';
import 'package:ricardo/feature/view/home/link_export_file.dart';
import 'package:ricardo/widgets/custom_heading_text.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';
import 'package:ricardo/widgets/custom_text_field.dart';
import 'package:ricardo/app/helpers/snackbar_helper.dart';

class RateReviewDriver extends StatelessWidget {
  RateReviewDriver({super.key}) {
    if (Get.isRegistered<RateAndReviewController>()) {
      Get.delete<RateAndReviewController>();
    }
  }

  late final RateAndReviewController controller =
      Get.put(RateAndReviewController());
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
            SizedBox(height: 28.h),
            Center(
              child: CustomHeadingText(
                firstText: 'Rate',
                secondText: 'Your Driver',
              ),
            ),
            SizedBox(height: 8.h),
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
            SizedBox(height: 28.h),
            Obx(() {
              final locked = controller.alreadyReviewed.value;
              return IgnorePointer(
                ignoring: locked,
                child: Opacity(
                  opacity: locked ? 0.55 : 1,
                  child: _buildRattingField(),
                ),
              );
            }),
            SizedBox(height: 28.h),
            Obx(() {
              final locked = controller.alreadyReviewed.value;
              return IgnorePointer(
                ignoring: locked,
                child: Opacity(
                  opacity: locked ? 0.55 : 1,
                  child: CustomTextField(
                    controller: controller.feedBackTEController,
                    labelText: 'Write your feedback (optional)',
                    hintText: 'Add Note',
                    minLines: 5,
                  ),
                ),
              );
            }),
            SizedBox(height: 36.h),
            Obx(() {
              final loading = cnt.isAddedFavouriteRiderStatus.value;
              final already = cnt.addedFavourite.value;
              final disabled = loading || already;

              return GestureDetector(
                onTap: disabled
                    ? null
                    : () async {
                        if (driverId == null) {
                          showSnackbar("Error", "Driver ID not found");
                          return;
                        }

                        final success =
                            await cnt.addedFavouriteRide(driverId!);

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
                                            text:
                                                'is now your favorite rider!',
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
                                        Get.back();
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
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    color: already
                        ? const Color(0xFFF0F2F4)
                        : Colors.transparent,
                    border: Border.all(
                      color: already
                          ? const Color(0xFFB8BCC3)
                          : const Color(0xff1BB600),
                      width: 1,
                    ),
                  ),
                  child: loading
                      ? SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: Colors.green,
                          ),
                        )
                      : Text(
                          already
                              ? 'Already Favourite'
                              : 'Add to Favourite',
                          style: TextStyle(
                            color: already
                                ? AppColors.secondaryTextColor
                                : const Color(0xff1BB600),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),
            SizedBox(height: 21.h),
            Obx(
              () {
                final loading = controller.isRattingLoading.value;
                final already = controller.alreadyReviewed.value;
                return CustomPrimaryButton(
                  title: already ? 'Review Submitted' : 'Submit Review',
                  isLoading: loading,
                  onHandler: (already || loading)
                      ? null
                      : () async {
                          final role = Get.find<UserController>()
                              .userModel
                              .value
                              ?.userProfile
                              ?.role;
                          if (role != AppConstants.passenger) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Only passengers can submit a review',
                                  ),
                                  backgroundColor: AppColors.errorColor,
                                ),
                              );
                            return;
                          }

                          if (rideId == null || driverId == null) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Ride or driver information missing',
                                  ),
                                  backgroundColor: AppColors.errorColor,
                                ),
                              );
                            return;
                          }

                          final value =
                              await controller.rateAndReviewDriverHandler(
                            rideId!,
                            driverId!,
                          );
                          if (value) {
                            Get.back();
                            return;
                          }

                          final message = controller.errorMessage.value;
                          if (message.isNotEmpty) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: AppColors.errorColor,
                                ),
                              );
                          }
                        },
                );
              },
            ),
            SizedBox(height: 21.h),
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
            itemSize: 42.r,
            itemPadding: EdgeInsets.symmetric(horizontal: 6.w),
            unratedColor: const Color(0xFFD5D5D5),
            itemBuilder: (context, index) {
              return const Icon(Icons.star, color: Color(0xFFFFC107));
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
