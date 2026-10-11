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
import 'package:ricardo/app/helpers/snackbar_helper.dart';

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
  Timer? _autoCancelTimer;

  @override
  void initState() {
    super.initState();

    // Use addPostFrameCallback to avoid building during frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rideAcceptedWorker = ever(widget.cnt.isRideAccepted, (bool accepted) {
        if (accepted && _isWaitingDialogOpen && mounted) {
          _cancelAutoTimer();
          _isWaitingDialogOpen = false;
          widget.cnt.isRideAccepted.value = false;
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop(); // close waiting dialog
          }
          _showAcceptedDialog(widget.cnt.acceptedRideDriverName.value);
        }
      });
    });
  }

  @override
  void dispose() {
    _rideAcceptedWorker?.dispose();
    _cancelAutoTimer();
    super.dispose();
  }

  void _cancelAutoTimer() {
    _autoCancelTimer?.cancel();
    _autoCancelTimer = null;
  }

  void _startAutoCancelTimer(String rideId, String driverId, RideController cnt) {
    _cancelAutoTimer();
    final timeoutMinutes = int.tryParse(dotenv.env['RIDE_MODAL_EXPIRE_TIME'] ?? '') ?? 2;
    _autoCancelTimer = Timer(Duration(minutes: timeoutMinutes), () {
      if (_isWaitingDialogOpen && mounted && context.mounted) {
        debugPrint('Auto-cancelling ride request after $timeoutMinutes minute(s)');
        cnt.cancelRequest(rideId, driverId);
        _isWaitingDialogOpen = false;
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        showSnackbar(
          'Request Expired',
          'No driver accepted your request. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  void _showWaitingDialog(String rideId, String driverId, RideController cnt) {
    // Guard against null driverId (should never happen, but safety first)
    if (driverId.isEmpty) {
      showSnackbar('Error', 'Driver information missing. Cannot request ride.');
      return;
    }

    _isWaitingDialogOpen = true;
    _startAutoCancelTimer(rideId, driverId, cnt);

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
              // Safe image – if asset missing, show fallback
              _buildSafeImage(Assets.images.waiting.path, height: 150.h),
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
                    _cancelAutoTimer();
                    cnt.cancelRequest(rideId, driverId);
                    _isWaitingDialogOpen = false;
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
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
              _buildSafeImage(Assets.images.congratulations.path, height: 150.h),
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
                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                    final cnt = Get.find<CustomBottomNavBarController>();
                    final riderController = Get.find<RideController>();
                    final googleSearchLocationController =
                    Get.find<GoogleSearchLocationController>();

                    cnt.selectedIndex.value = 0;
                    Get.offAllNamed(AppRoutes.customBottomNavBar);
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

  /// Safely loads an asset image; if missing, shows a coloured box (or you can return SizedBox.shrink())
  Widget _buildSafeImage(String assetPath, {double? height, double? width, BoxFit fit = BoxFit.contain}) {
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: a simple container with a placeholder icon
        return Container(
          height: height ?? 50,
          width: width ?? 50,
          color: Colors.grey.shade300,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guard against null driver ID before building the button
    final driverId = widget.cardDetails.sId;
    if (driverId == null || driverId.isEmpty) {
      return const SizedBox.shrink(); // or show an error widget
    }

    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          // Ensure rideId is not empty
          final rideId = widget.cnt.rideId.value;
          if (rideId.isEmpty) {
            showSnackbar('Error', 'Ride ID missing. Please try again.');
            return;
          }

          widget.cnt.fetchSendPickUpRequest(rideId, driverId);
          _showWaitingDialog(rideId, driverId, widget.cnt);
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