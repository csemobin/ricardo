import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/models/home/nearest_driver_model.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/routes/app_routes.dart';
import 'package:ricardo/widgets/glass_background_multiple_children_widget.dart';

class RequestRideHandler extends StatefulWidget {
  const RequestRideHandler({
    super.key,
    required this.cnt,
    required this.cardDetails,
  });

  final RideController cnt;
  final NearestDrivers cardDetails;

  @override
  State<RequestRideHandler> createState() => _RequestRideHandlerState();
}

class _RequestRideHandlerState extends State<RequestRideHandler> {
  Worker? _rideAcceptedWorker;
  bool _isWaitingDialogOpen = false;

  // ✅ Timer for auto-cancel after 2 minutes
  Timer? _autoCancelTimer;

  @override
  void initState() {
    super.initState();

    _rideAcceptedWorker = ever(widget.cnt.isRideAccepted, (bool accepted) {
      if (accepted && _isWaitingDialogOpen && mounted) {
        // ✅ Ride accepted — cancel the auto-cancel timer immediately
        _cancelAutoTimer();

        _isWaitingDialogOpen = false;
        widget.cnt.isRideAccepted.value = false;
        Navigator.of(context).pop(); // close waiting dialog
        _showAcceptedDialog(widget.cnt.acceptedRideDriverName.value);
      }
    });
  }

  @override
  void dispose() {
    _rideAcceptedWorker?.dispose();
    _cancelAutoTimer(); // ✅ Always clean up timer on dispose
    super.dispose();
  }

  // ── Cancel & clear the timer safely ─────────────────────────────────────────
  void _cancelAutoTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = null;
  }

  // ── Start 2-minute auto-cancel timer ────────────────────────────────────────
  void _startAutoCancelTimer(String rideId, String driverId, RideController cnt) {
    _cancelAutoTimer(); // cancel any existing timer first
    final timeoutMinutes = int.tryParse(dotenv.env['RIDE_MODAL_EXPIRE_TIME'] ?? '') ?? 2;
    _autoCancelTimer = Timer(Duration(minutes:  timeoutMinutes ), () {
      // Only fire if the dialog is still open (not yet accepted/cancelled)
      if (_isWaitingDialogOpen && mounted) {
        print('====== AUTO CANCEL FIRED AFTER 2 MIN ======');

        cnt.cancelRequest(rideId, driverId); // ✅ hits cancelRequest once

        _isWaitingDialogOpen = false;

        // Close the waiting dialog if still showing
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // ✅ Show a snackbar so driver knows it was auto-cancelled
        Get.snackbar(
          'Request Expired',
          'No driver accepted your request. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  void _showWaitingDialog(String rideId, String cardDetails, RideController cnt) {
    _isWaitingDialogOpen = true;

    // ✅ Start the 2-minute auto-cancel timer when dialog opens
    _startAutoCancelTimer(rideId, cardDetails, cnt);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: GlassBackgroundMultipleChildrenWidget(
            blurOne: 10,
            blurTwo: 10,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.waiting.path,
                fit: BoxFit.contain,
                height: 150.h,
              ),
              SizedBox(height: 12.h),
              Text(
                'Sending your ride request…',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.poppins,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Waiting for driver to accept.',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // ✅ Manual cancel — stop the auto-cancel timer too
                    _cancelAutoTimer();
                    cnt.cancelRequest(rideId, cardDetails);
                    _isWaitingDialogOpen = false;
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel Request'),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // ✅ Dialog closed by any means — cancel timer and reset flag
      _isWaitingDialogOpen = false;
      _cancelAutoTimer();
    });
  }

  void _showAcceptedDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: GlassBackgroundMultipleChildrenWidget(
            blurOne: 10,
            blurTwo: 10,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.congratulations.path,
                fit: BoxFit.contain,
                height: 150.h,
              ),
              SizedBox(height: 12.h),
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  fontFamily: FontFamily.poppins,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greenColor,
                ),
              ),
              Text(
                'Your ride request has been accepted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    final cnt = Get.find<CustomBottomNavBarController>();
                    final riderController = Get.find<RideController>();
                    final googleSearchLocationController =
                    Get.find<GoogleSearchLocationController>();

                    cnt.selectedIndex.value = 0;
                    Get.offAllNamed(AppRoutes.homeScreen);
                    googleSearchLocationController.isModalOn.value = false;
                    riderController.isSwippedButtonShow.value = true;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Okay'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          widget.cnt.fetchSendPickUpRequest(
              widget.cnt.rideId.value, widget.cardDetails.sId!);
          _showWaitingDialog(
              widget.cnt.rideId.value, widget.cardDetails.sId!, widget.cnt);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF34A853),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Request Ride',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}