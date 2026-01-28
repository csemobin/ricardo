import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/history_controller.dart';
import 'package:ricardo/feature/models/history/complete_ride_history.dart';
import 'package:ricardo/gen/assets.gen.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import 'package:ricardo/widgets/custom_scaffold.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final controller = Get.put(HistoryController());

  @override
  void initState() {
    super.initState();
    controller.fetchHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isHistoryFetchStatus.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyDatas.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchHistoryData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Text(
                    'No ride history available',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.primaryHeadingTextColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchHistoryData();
          },
          child: ListView.builder(
            itemCount: controller.historyDatas.length,
            padding: EdgeInsets.only(bottom: 85.h),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, dateIndex) {
              final dateGroup = controller.historyDatas[dateIndex];
              final date = dateGroup?.date;
              final rides = dateGroup?.rides;

              // Get the day heading based on date difference
              final heading = _getDayHeading(date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Container(
                    width: double.infinity,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: AppColors.navBarBackgroundColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 5.h,
                      ),
                      child: Text(
                        heading,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackBText,
                          fontFamily: FontFamily.poppins,
                        ),
                      ),
                    ),
                  ),

                  // Rides List for this date
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rides!.length,
                    separatorBuilder: (context, index) => SizedBox(height: 4.h),
                    itemBuilder: (context, rideIndex) {
                      final ride = rides[rideIndex];
                      return _buildRiddingHistoryCard(ride: ride);
                    },
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  String _getDayHeading(String? dateString) {
    if (dateString == null) return 'Previous Days';

    try {
      // Parse the date from API (format: "dd/MM/yyyy")
      final dateFormat = DateFormat('dd/MM/yyyy');
      final rideDate = dateFormat.parse(dateString);

      // Get current local date
      final now = DateTime.now();

      // Create DateTime objects with only date part (ignore time)
      final rideDateLocal = DateTime(
        rideDate.year,
        rideDate.month,
        rideDate.day,
      );

      final todayLocal = DateTime(
        now.year,
        now.month,
        now.day,
      );

      // Calculate difference in days
      final difference = todayLocal.difference(rideDateLocal).inDays;

      // Return appropriate heading
      switch (difference) {
        case 0:
          return 'Today';
        case 1:
          return 'Yesterday';
        case 2:
          return '2 days ago';
        case 3:
          return '3 days ago';
        case 4:
          return '4 days ago';
        case 5:
          return '5 days ago';
        case 6:
          return '6 days ago';
        case 7:
          return '1 week ago';
        default:
          if (difference <= 14) {
            return '$difference days ago';
          } else if (difference <= 30) {
            final weeks = (difference / 7).floor();
            return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
          } else if (difference <= 365) {
            final months = (difference / 30).floor();
            return '$months ${months == 1 ? 'month' : 'months'} ago';
          } else {
            final years = (difference / 365).floor();
            return '$years ${years == 1 ? 'year' : 'years'} ago';
          }
      }
    } catch (e) {
      // If date parsing fails, show the original date
      return dateString;
    }
  }

  Widget _buildRiddingHistoryCard({required Rides ride}) {
    // Parse the completed date and time
    DateTime? completedAt;
    try {
      if (ride.createdAt != null && ride.createdAt!.isNotEmpty) {
        // Parse from UTC string and convert to local time
        final utcTime = DateTime.parse(ride.createdAt!);
        completedAt = utcTime.toLocal();  // Convert UTC to local time
      } else if (ride.createdAt != null && ride.createdAt!.isNotEmpty) {
        // Parse from UTC string and convert to local time
        final utcTime = DateTime.parse(ride.createdAt!);
        completedAt = utcTime.toLocal();  // Convert UTC to local time
      } else {
        completedAt = DateTime.now();
      }
    } catch (e) {
      completedAt = DateTime.now();
    }

    // Format for display in local timezone
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final formattedDateTime = dateFormat.format(completedAt);

    // Format fare amount
    final fare = ride.totalPayAmount ?? 0.0;
    final formattedFare = '\$${fare.toStringAsFixed(2)}';

    return Container(
      decoration: BoxDecoration(color: AppColors.whiteColor),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 25.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDateTime,
                  style: textStyle(),
                ),
                Text(
                  formattedFare,
                  style: textStyle(),
                )
              ],
            ),
            SizedBox(
              height: 12.h,
            ),
            Row(
              children: [
                Image.asset(Assets.images.directRight.path),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PICK UP',
                        style: TextStyle(
                          color: AppColors.labelTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.poppins,
                        ),
                      ),
                      Text(
                        ride.pickupAddress ?? 'Pickup location not specified',
                        style: textStyle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                top: 4.h,
                bottom: 4.h,
              ),
              child: Container(
                width: 2.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.separaterBgColor,
                ),
              ),
            ),
            Row(
              children: [
                Image.asset(Assets.images.location.path),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DROP OFF',
                        style: TextStyle(
                          color: AppColors.labelTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.poppins,
                        ),
                      ),
                      Text(
                        ride.destinationAddress ?? 'Destination not specified',
                        style: textStyle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle textStyle() {
    return TextStyle(
      color: AppColors.primaryHeadingTextColor,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.poppins,
    );
  }
}