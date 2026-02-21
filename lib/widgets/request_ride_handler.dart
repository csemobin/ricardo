import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
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

  @override
  void initState() {
    super.initState();

    // ✅ Listen OUTSIDE of build using ever()
    _rideAcceptedWorker = ever(widget.cnt.isRideAccepted, (bool accepted) {
      if (accepted && _isWaitingDialogOpen && mounted) {
        _isWaitingDialogOpen = false;
        widget.cnt.isRideAccepted.value = false; // reset
        Navigator.of(context).pop(); // close waiting dialog
        _showAcceptedDialog(widget.cnt.acceptedRideDriverName.value);
      }
    });
  }

  @override
  void dispose() {
    _rideAcceptedWorker?.dispose(); // ✅ Always clean up
    super.dispose();
  }

  void _showWaitingDialog() {
    _isWaitingDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: GlassBackgroundMultipleChildrenWidget(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.waiting.path,
                fit: BoxFit.contain,
                height: 150.h, // ✅ Fix overflow
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
                  child: Text('Cancel Request'),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => _isWaitingDialogOpen = false);
  }

  void _showAcceptedDialog( String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: GlassBackgroundMultipleChildrenWidget(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.congratulations.path,
                fit: BoxFit.contain,
                height: 150.h, // ✅ Fix overflow
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
                  onPressed: (){
                    Navigator.of(dialogContext).pop();

                    final cnt = Get.find<CustomBottomNavBarController>();
                    cnt.selectedIndex.value = 0;

                    Get.offAllNamed(AppRoutes.homeScreen);
                    final googleSearchLocationController =
                    Get.find<GoogleSearchLocationController>();
                    googleSearchLocationController.isModalOn.value = false;

                    final riderController = Get.find<RideController>();
                    riderController.isSwippedButtonShow.value = true;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Okay'),
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
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.cnt.fetchSendPickUpRequest(
              widget.cnt.rideId.value, widget.cardDetails.sId!);
          _showWaitingDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF34A853),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Request Ride',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}