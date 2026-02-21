import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/gen/fonts.gen.dart';

// ===== RIDE STATUS ENUM =====
enum RideStatus { driverOnWay, driverArrived, riderArrive, provideReview }

// ===== MAIN RIDE TRACKING BOTTOM SHEET =====
class RideTrackingBottomSheet extends StatefulWidget {
  final RideStatus status;
  final String driverName;
  final String driverRating;
  final String driverTrips;
  final String driverPhone;
  final String carName;
  final String carSeats;
  final String carPlate;
  final String distanceAway;
  final String eta; // e.g. "1 min"
  final String driverImage;
  final String carImage;
  final VoidCallback? onClose;
  final VoidCallback? onCall;
  final VoidCallback? onReport;
  final VoidCallback? onReview;
  final VoidCallback? onTip;
  final VoidCallback? onConfirmRide;

  const RideTrackingBottomSheet({
    super.key,
    required this.status,
    required this.driverName,
    required this.driverRating,
    required this.driverTrips,
    required this.driverPhone,
    required this.carName,
    required this.carSeats,
    required this.carPlate,
    required this.distanceAway,
    required this.eta,
    required this.driverImage,
    required this.carImage,
    this.onClose,
    this.onCall,
    this.onReport,
    this.onReview,
    this.onTip,
    this.onConfirmRide,
  });

  @override
  State<RideTrackingBottomSheet> createState() =>
      _RideTrackingBottomSheetState();
}

class _RideTrackingBottomSheetState extends State<RideTrackingBottomSheet> {
  int _waitingSeconds = 0; // for waiting timer

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──
          Container(
            margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // ── Status Bar ──
          _buildStatusBar(),

          Divider(height: 1, color: Colors.grey.shade200),

          // ── Driver Info ──
          _buildDriverInfo(),

          Divider(height: 1, color: Colors.grey.shade200),

          // ── Car Info ──
          _buildCarInfo(),

          // ── Extra content based on status ──
          if (widget.status == RideStatus.driverArrived)
            _buildWaitingTimer(),

          if (widget.status == RideStatus.provideReview)
            _buildReviewButtons(),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── STATUS BAR (top green pill) ──
  Widget _buildStatusBar() {
    String label = '';
    String etaText = widget.eta;
    Color dotColor = Colors.green;

    switch (widget.status) {
      case RideStatus.driverOnWay:
        label = 'Rider is on the way to pickup';
        break;
      case RideStatus.driverArrived:
      case RideStatus.riderArrive:
        label = 'Rider Arrive';
        etaText = '0 min';
        break;
      case RideStatus.provideReview:
        label = 'Rider Arrive';
        etaText = '';
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: FontFamily.poppins,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (etaText.isNotEmpty)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    etaText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (widget.status == RideStatus.provideReview) ...[
                GestureDetector(
                  onTap: widget.onReport,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined,
                            color: Colors.red, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Report',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (widget.onClose != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── DRIVER INFO ROW ──
  Widget _buildDriverInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Driver Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              widget.driverImage,
              width: 55.w,
              height: 55.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.person, size: 55.sp, color: Colors.grey),
            ),
          ),
          SizedBox(width: 12.w),

          // Driver Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driverName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                    fontFamily: FontFamily.poppins,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14.sp),
                    SizedBox(width: 3.w),
                    Text(
                      '${widget.driverRating} (${widget.driverTrips})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '  |  ${widget.driverTrips} Trips',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.phone, color: AppColors.greenColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      widget.driverPhone,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Call Button
          GestureDetector(
            onTap: widget.onCall,
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Icon(Icons.call, color: AppColors.greenColor, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── CAR INFO ROW ──
  Widget _buildCarInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.carName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: FontFamily.poppins,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${widget.carSeats} Seat',
                style:
                TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              Text(
                widget.carPlate,
                style:
                TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 2.h),
              Text(
                widget.distanceAway,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.greenColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              widget.carImage,
              width: 100.w,
              height: 75.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.directions_car, size: 75.sp, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ── WAITING TIMER (driver arrived state) ──
  Widget _buildWaitingTimer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Waiting Time ',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
              Text(
                'WAIT: 00:07',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'If you have entered the car, please confirm with your\ndriver to start the ride in the app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ── REVIEW BUTTONS ──
  Widget _buildReviewButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          // Provide a Review
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Provide a review',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Provide a Tip
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onTip,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.greenColor),
                foregroundColor: AppColors.greenColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                ),
              ),
              child: Text(
                'Provide a Tip',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ===== HOW TO SHOW IT =====
void showRideTrackingSheet(BuildContext context, RideStatus status) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,       // ✅ Allows variable height
    backgroundColor: Colors.transparent,
    isDismissible: false,            // ✅ User can't dismiss by tapping outside
    enableDrag: true,
    builder: (context) {
      return RideTrackingBottomSheet(
        status: status,
        driverName: 'Rakibul Hasa.K',
        driverRating: '4.5',
        driverTrips: '253',
        driverPhone: '+123 456 789',
        carName: 'Suzuki Alto 800',
        carSeats: '4',
        carPlate: 'DHK METRO HA 64-8888',
        distanceAway: '1 km away from you.',
        eta: '1 min',
        driverImage: 'YOUR_DRIVER_IMAGE_URL',
        carImage: 'YOUR_CAR_IMAGE_URL',
        onClose: () => Navigator.pop(context),
        onCall: () { /* launch phone call */ },
        onReport: () { /* handle report */ },
        onReview: () { /* handle review */ },
        onTip: () { /* handle tip */ },
      );
    },
  );
}