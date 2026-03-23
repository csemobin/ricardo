import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ricardo/app/utils/app_colors.dart';
import 'package:ricardo/feature/controllers/custom_bottom_nav_bar_controller.dart';
import 'package:ricardo/feature/controllers/home/google_search_location_controller.dart';
import 'package:ricardo/feature/controllers/home/map/ride_controller.dart';
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
    {"icon": Assets.images.activeHome.path, "label": "Home"},
    {"icon": Assets.images.activeWallet.path, "label": "Wallet"},
    {"icon": Assets.images.activeHistory.path, "label": "History"},
    {"icon": Assets.images.activeProfile.path, "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get controllers
      final googleSLController = Get.find<GoogleSearchLocationController>();
      final rideCnt = Get.find<RideController>();

      // Determine if navigation bar should be visible
      bool showNavBar = true;

      // Hide navigation bar when:
      // 1. Modal is on AND
      // 2. View in map is true AND
      // 3. View in map return is false
      if (googleSLController.isModalOn.value == true &&
          rideCnt.viewInMap.value == true &&
          rideCnt.viewInMapReturn.value == false) {
        showNavBar = false;
      }

      // Also hide when viewInMap is false (map fullscreen mode)
      if (rideCnt.viewInMap.value == false) {
        showNavBar = false;
      }

      return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: _screenList[controller.selectedIndex.value],
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        floatingActionButtonAnimator:
        FloatingActionButtonAnimator.noAnimation,
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
                        Image.asset(
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