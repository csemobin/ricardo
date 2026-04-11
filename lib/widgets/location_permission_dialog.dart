import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/services/location_permission_service.dart';
import 'package:ricardo/widgets/glass_background_widget.dart';

class LocationPermissionDialog extends StatelessWidget {
  final LocationStatus status;

  const LocationPermissionDialog({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: GlassBackgroundWidget(
        borderRadius: 24,
        borderLeftRightRadius: 24,
        child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Icon
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off,
                size: 48.sp,
                color: Colors.red,
              ),
            ),

            SizedBox(height: 16.h),

            // ✅ Title
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: FontFamily.poppins,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // ✅ Message
            Text(
              _getMessage(),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // ✅ Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('Cancel',style: TextStyle(
                      color: AppColors.whiteColor,
                    ),),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      _getButtonText(),
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      )
    );
  }

  String _getTitle() {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return 'Help us guide you better';
      case LocationStatus.permissionDenied:
        return 'Location Permission Required';
      case LocationStatus.permissionDeniedForever:
        return 'Location Permission Blocked';
      default:
        return 'Enable Location';
    }
  }

  String _getMessage() {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return 'Pick your location and begin finding cars near you.';
      case LocationStatus.permissionDenied:
        return 'We need location permission to show nearby rides and drivers. Please grant permission.';
      case LocationStatus.permissionDeniedForever:
        return 'Location permission is permanently denied. Please enable it from app settings.';
      default:
        return 'Please enable location to continue';
    }
  }

  String _getButtonText() {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return 'Open Settings';
      case LocationStatus.permissionDenied:
        return 'Grant Permission';
      case LocationStatus.permissionDeniedForever:
        return 'Open Settings';
      default:
        return 'Enable';
    }
  }

  void _handleAction() {
    Get.back();

    switch (status) {
      case LocationStatus.serviceDisabled:
        LocationPermissionService.openLocationSettings();
        break;
      case LocationStatus.permissionDenied:
        LocationPermissionService.requestPermission();
        break;
      case LocationStatus.permissionDeniedForever:
        LocationPermissionService.openAppSettings();
        break;
      default:
        break;
    }
  }
}