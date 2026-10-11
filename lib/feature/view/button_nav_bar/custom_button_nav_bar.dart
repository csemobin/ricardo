import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/app/utils/app_constants.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/map_opt_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
import 'package:ricardo/feature/controllers/user_controller.dart';
import 'package:ricardo/feature/view/history/history_screen.dart';
import 'package:ricardo/feature/view/home/home_screen.dart';
import 'package:ricardo/feature/view/profile/profile_screen.dart';
import 'package:ricardo/feature/view/wallet/wallet_screen.dart';
import 'package:ricardo/gen/assets.gen.dart';

class CustomButtonNavBar extends GetView<CustomBottomNavBarController> {
  CustomButtonNavBar({super.key});

  final List<Widget> _screenList = [
    const HomeScreen(),
    const WalletScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {"icon": Assets.images.activeHome, "label": "Home"},
    {"icon": Assets.images.activeWallet, "label": "Wallet"},
    {"icon": Assets.images.activeHistory, "label": "History"},
    {"icon": Assets.images.activeProfile, "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final googleSLController = Get.find<GoogleSearchLocationController>();
      final userCnt = Get.find<UserController>();
      final mapOPTController = Get.find<MapOPTController>();
      final rideCnt = Get.find<RideController>();

      final role = userCnt.userModel.value?.userProfile?.role;
      final isPassenger = role == AppConstants.passenger;

      // ── only apply passenger hide logic for passenger role ────────────
      bool showNavBar = true;

      if (isPassenger) {
        final rideStatus = mapOPTController.rideStatusData.value;
        final isModalShowing = googleSLController.isModalOn.value;
        final inMapFullscreen = rideCnt.viewInMap.value == false;
        // completeRide keeps the bar hidden behind the completion card; the
        // card's "Back to Home" button is what returns the passenger to it.
        final rideInProgress =
            rideCnt.isRideAccepted.value == true ||
            rideStatus?.acceptRide == true ||
            rideStatus?.ongoingRide == true ||
            rideStatus?.arrivingRide == true ||
            rideStatus?.startRide == true ||
            rideStatus?.completeRide == true;

        if (isModalShowing || inMapFullscreen || rideInProgress) {
          showNavBar = false;
        }
      }

      return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: _screenList,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
        floatingActionButton: Visibility(
          visible: showNavBar,
          child: Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w),
            height: 65.h,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0x99FFFFFF), width: 2),
              color: AppColors.navBarBackgroundColor,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                bool isSelected = controller.selectedIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.onChange(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /*Image.asset(
                          item['icon'],
                          width: 24.w,
                          height: 24.h,
                          color: isSelected
                              ? AppColors.activeIconColor
                              : AppColors.deActiveIconColor,
                        ),*/
                        SvgPicture.asset(
                          item['icon'],
                          width: 24.w,
                          height: 24.h,
                          color: isSelected
                              ? AppColors.activeIconColor
                              : AppColors.deActiveIconColor,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8.w),
                          Text(
                            item['label'],
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.activeIconColor
                                  : AppColors.deActiveIconColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }
}
